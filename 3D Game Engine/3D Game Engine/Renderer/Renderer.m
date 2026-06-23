//
//  Renderer.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/16/25.
//

#import "Renderer.h"
#import "Camera.h"
#import "Mesh.h"

@implementation Renderer {
    id<MTLCommandQueue> commandQueue;
    id<MTLRenderPipelineState> renderPipelineState;
    id<MTLDepthStencilState> depthStencilState;
    id<MTLSamplerState> _samplerState;

    id<MTLBuffer> _cameraUniformsBuffer;
    id<MTLBuffer> _objectUniformsBuffer;
    id<MTLBuffer> _lightUniformsBuffer;
    id<MTLBuffer> _materialUniformsBuffer;
    
    // Skybox
    id<MTLRenderPipelineState> skyboxPipelineState;
    id<MTLDepthStencilState> skyboxDepthStencilState;
}

- (nonnull instancetype) initWithMetalKitView:(nonnull MTKView *)view {
    self = [super init];
    if (nil == self) { return nil; }

    _device = view.device;
    _defaultLibrary = [self.device newDefaultLibrary];

    view.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
    MTLDepthStencilDescriptor *depthDesc = [MTLDepthStencilDescriptor new];
    depthDesc.depthCompareFunction = MTLCompareFunctionLess;
    depthDesc.depthWriteEnabled = YES;
    depthStencilState = [self.device newDepthStencilStateWithDescriptor:depthDesc];

    commandQueue = [self.device newCommandQueue];
    renderPipelineState = [self compileRenderPipeline:view.colorPixelFormat];

    MTLSamplerDescriptor *samplerDesc = [MTLSamplerDescriptor new];
    samplerDesc.minFilter = MTLSamplerMinMagFilterLinear;
    samplerDesc.magFilter = MTLSamplerMinMagFilterLinear;
    samplerDesc.mipFilter = MTLSamplerMipFilterLinear;
    samplerDesc.sAddressMode = MTLSamplerAddressModeRepeat;
    samplerDesc.tAddressMode = MTLSamplerAddressModeRepeat;
    _samplerState = [self.device newSamplerStateWithDescriptor:samplerDesc];

    _cameraUniformsBuffer   = [self.device newBufferWithLength:sizeof(CameraUniforms) options:MTLResourceStorageModeShared];
    _lightUniformsBuffer    = [self.device newBufferWithLength:sizeof(LightUniforms) options:MTLResourceStorageModeShared];
    _materialUniformsBuffer = [self.device newBufferWithLength:sizeof(MaterialUniforms) options:MTLResourceStorageModeShared];
    
    // Skybox stuff
    NSError *error = nil;
    MTLRenderPipelineDescriptor *desc = [MTLRenderPipelineDescriptor new];
    desc.label = @"Skybox Pipeline";
    desc.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    desc.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    desc.vertexFunction   = [self.defaultLibrary newFunctionWithName:@"skyboxVertex"];
    desc.fragmentFunction = [self.defaultLibrary newFunctionWithName:@"skyboxFragment"];
    skyboxPipelineState = [self.device newRenderPipelineStateWithDescriptor:desc error:&error];

    MTLDepthStencilDescriptor *skyboxDepthDesc = [MTLDepthStencilDescriptor new];
    skyboxDepthDesc.depthCompareFunction = MTLCompareFunctionLessEqual;
    skyboxDepthDesc.depthWriteEnabled = NO;
    skyboxDepthStencilState = [self.device newDepthStencilStateWithDescriptor:skyboxDepthDesc];

    return self;
}

- (void) renderFrameToView:(MTKView *)view {
    if (!self.minecraft) { return; }

    Camera *camera = self.minecraft.camera;
    [camera setAspectRatio:view.drawableSize.width / view.drawableSize.height];
    
    // Same as sky
    view.clearColor = MTLClearColorMake(0.678, 1.0, 0.984, 1.0);

    // Upload camera uniforms
    CameraUniforms cameraUniforms = [camera getUniforms];
    memcpy(_cameraUniformsBuffer.contents, &cameraUniforms, sizeof(CameraUniforms));

    // Upload first light from scene
    if (self.minecraft.lights.count > 0) {
        Light *light = self.minecraft.lights.firstObject;
        LightUniforms lu = [light uniforms];
        memcpy(_lightUniformsBuffer.contents, &lu, sizeof(LightUniforms));
    }

    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    MTLRenderPassDescriptor *configuration = view.currentRenderPassDescriptor;
    if (!configuration) { return; }
    configuration.depthAttachment.loadAction = MTLLoadActionClear;
    configuration.depthAttachment.clearDepth = 1.0;

    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:configuration];
    encoder.label = @"Render Pass Encoder";
    
    if (self.minecraft.skybox) {
        [encoder setRenderPipelineState:skyboxPipelineState];
        [encoder setDepthStencilState:skyboxDepthStencilState];
        [encoder setCullMode:MTLCullModeFront];

        [encoder setVertexBuffer:self.minecraft.skybox.mesh.vertexBuffer offset:0 atIndex:0];
        [encoder setVertexBytes:&cameraUniforms length:sizeof(CameraUniforms) atIndex:1];
        [encoder setFragmentTexture:self.minecraft.skybox.material.texture atIndex:0];
        [encoder setFragmentSamplerState:_samplerState atIndex:0];

        [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                            indexCount:self.minecraft.skybox.mesh.indexCount
                             indexType:MTLIndexTypeUInt32
                           indexBuffer:self.minecraft.skybox.mesh.indexBuffer
                     indexBufferOffset:0
                         instanceCount:1];
        
        [encoder setRenderPipelineState:renderPipelineState];
        [encoder setDepthStencilState:depthStencilState];
        [encoder setCullMode:MTLCullModeBack];
    }

    
    [encoder setRenderPipelineState:renderPipelineState];
    [encoder setDepthStencilState:depthStencilState];
    [encoder setCullMode:MTLCullModeNone];

    // Perframe bindings shared
    [encoder setVertexBytes:&cameraUniforms
                     length:sizeof(CameraUniforms)
                    atIndex:VertexBufferIndexForCameraUniforms];
    [encoder setFragmentBuffer:_cameraUniformsBuffer offset:0 atIndex:FragmentBufferIndexForCameraUniforms];
    [encoder setFragmentBuffer:_lightUniformsBuffer  offset:0 atIndex:FragmentBufferIndexForLightUniforms];
    [encoder setFragmentSamplerState:_samplerState atIndex:0];
    
    NSMutableArray<GameObject *> *allObjects = [NSMutableArray array];
    for (GameObject *root in self.minecraft.gameObjects) {
        [self collectObjects:root results:allObjects];
    }

    // Ground + player placed cubes live in the Block Grid, not the static
    // gameObjects scene graph, since they're added/removed every frame as
    // the player places/breaks blocks.
    [allObjects addObjectsFromArray:self.minecraft.blockGrid.allCubes];

    NSMutableDictionary<NSString *, NSMutableArray<GameObject *> *> *meshGroups = [NSMutableDictionary dictionary];

    for (GameObject *obj in allObjects) {
        NSString *key = [NSValue valueWithPointer:(__bridge void *)obj.mesh];
        if (!meshGroups[key]) meshGroups[key] = [NSMutableArray array];
        [meshGroups[key] addObject:obj];
    }

    for (NSString *key in meshGroups) {
        NSArray<GameObject *> *group = meshGroups[key];
        
        // Build matrix buffer
        simd_float4x4 *matrices = malloc(group.count * sizeof(simd_float4x4));
        for (NSUInteger i = 0; i < group.count; i++) {
            matrices[i] = group[i].getWorldMatrix;
        }
        
        id<MTLBuffer> instanceBuf = [_device newBufferWithBytes:matrices
                                                         length:group.count * sizeof(simd_float4x4)
                                                        options:MTLResourceStorageModeShared];
        free(matrices);
        
        Mesh *mesh = group[0].mesh;
        Material *mat = group[0].material;
        MaterialUniforms matUniforms = [mat uniforms];
        
        [encoder setVertexBuffer:mesh.vertexBuffer offset:0 atIndex:VertexBufferIndexForVertexData];
        [encoder setVertexBuffer:instanceBuf offset:0 atIndex:VertexBufferIndexForModelMatrices];
        [encoder setFragmentBytes:&matUniforms length:sizeof(MaterialUniforms) atIndex:FragmentBufferIndexForMaterialUniforms];
        [encoder setFragmentTexture:mat.texture atIndex:0];
        
        [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                            indexCount:mesh.indexCount
                             indexType:MTLIndexTypeUInt32
                           indexBuffer:mesh.indexBuffer
                     indexBufferOffset:0
                         instanceCount:group.count];
    }

    [encoder endEncoding];
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

- (id<MTLRenderPipelineState>) compileRenderPipeline:(MTLPixelFormat)colorPixelFormat {
    NSError *error = nil;
    MTLRenderPipelineDescriptor *descriptor = [MTLRenderPipelineDescriptor new];
    descriptor.label = @"Render Pipeline";
    descriptor.colorAttachments[0].pixelFormat = colorPixelFormat;
    descriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    descriptor.vertexFunction   = [self.defaultLibrary newFunctionWithName:@"vertexShader"];
    descriptor.fragmentFunction = [self.defaultLibrary newFunctionWithName:@"fragmentShader"];

    id<MTLRenderPipelineState> pipelineState = [self.device newRenderPipelineStateWithDescriptor:descriptor
                                                                                           error:&error];
    NSAssert(pipelineState, @"Pipeline compile error: %@", error);
    return pipelineState;
}

- (void)collectObjects:(GameObject *)object
               results:(NSMutableArray<GameObject *> *)results {
    [results addObject:object];
    for (GameObject *child in object.children) {
        [self collectObjects:child results:results];
    }
}

- (void) updateWithInput:(InputState)inputState {
    if (!self.minecraft) { return; }

    // Camera movement and block place delete are both handled inside
    // Minecraft since placing/deleting needs the camera's matrices
    // (for raycasting) and the Block Grid it owns.
    [self.minecraft updateWithInput:inputState];
}

@end
