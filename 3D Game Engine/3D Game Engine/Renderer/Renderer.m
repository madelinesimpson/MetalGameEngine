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
    id<MTLTexture> _texture;

    Mesh* _mesh;
    Camera* _camera;

    id<MTLBuffer> _cameraUniformsBuffer;
    id<MTLBuffer> _objectUniformsBuffer;
    
    id<MTLBuffer> _lightUniformsBuffer;
    id<MTLBuffer> _materialUniformsBuffer;
}

- (nonnull instancetype) initWithMetalKitView:(nonnull MTKView *)view {
    self = [super init];
    if (nil == self) { return nil; }

    _device = view.device;
    _defaultLibrary = [self.device newDefaultLibrary];

    view.depthStencilPixelFormat = MTLPixelFormatDepth32Float;
    MTLDepthStencilDescriptor *descriptor = [MTLDepthStencilDescriptor new];
    descriptor.depthCompareFunction = MTLCompareFunctionLess;
    descriptor.depthWriteEnabled = YES;
    depthStencilState = [self.device newDepthStencilStateWithDescriptor:descriptor];
    
    commandQueue = [self.device newCommandQueue];
    renderPipelineState = [self compileRenderPipeline:view.colorPixelFormat];

    _camera = [[Camera alloc] init];
    
    MTLSamplerDescriptor *samplerDesc = [MTLSamplerDescriptor new];
    samplerDesc.minFilter = MTLSamplerMinMagFilterLinear;
    samplerDesc.magFilter = MTLSamplerMinMagFilterLinear;
    samplerDesc.mipFilter = MTLSamplerMipFilterLinear;
    samplerDesc.sAddressMode = MTLSamplerAddressModeRepeat;
    samplerDesc.tAddressMode = MTLSamplerAddressModeRepeat;
    _samplerState = [self.device newSamplerStateWithDescriptor:samplerDesc];

    [self drawStuff];

    return self;
}

- (void) drawStuff {
    _mesh = [Mesh meshFromOBJNamed:@"teapot" device:self.device];

    _cameraUniformsBuffer = [self.device newBufferWithLength:sizeof(CameraUniforms)
                                                     options:MTLResourceStorageModeShared];
    _objectUniformsBuffer = [self.device newBufferWithLength:sizeof(ObjectUniforms)
                                                     options:MTLResourceStorageModeShared];

    ObjectUniforms color = { .color = simd_make_float4(1, 0, 0, 1) };
    memcpy(_objectUniformsBuffer.contents, &color, sizeof(ObjectUniforms));
    
    _lightUniformsBuffer = [self.device newBufferWithLength:sizeof(LightUniforms)
                                            options:MTLResourceStorageModeShared];
    _materialUniformsBuffer = [self.device newBufferWithLength:sizeof(MaterialUniforms)
                                               options:MTLResourceStorageModeShared];

    LightUniforms lightUniforms;
    lightUniforms.position = simd_make_float4(5.0, 5.0, 10.0, 0.0);
    lightUniforms.ambient  = simd_make_float4(0.3, 0.3, 0.3, 0.0);
    lightUniforms.diffuse  = simd_make_float4(1.0, 1.0, 1.0, 0.0);
    lightUniforms.specular = simd_make_float4(1.0, 1.0, 1.0, 0.0);

    MaterialUniforms materialUniforms;
    materialUniforms.ambient   = simd_make_float4(0.3, 0.3, 0.3, 0.0);
    materialUniforms.diffuse   = simd_make_float4(1.0, 1.0, 1.0, 0.0);
    materialUniforms.specular  = simd_make_float4(0.8, 0.8, 0.8, 0.0);
    materialUniforms.shininess = simd_make_float4(64.0f, 0.0, 0.0, 0.0);
    memcpy(_lightUniformsBuffer.contents, &lightUniforms, sizeof(LightUniforms));
    memcpy(_materialUniformsBuffer.contents, &materialUniforms, sizeof(MaterialUniforms));
    
    _texture = [self loadTextureNamed:@"ceramic.jpg"];
}

- (void) renderFrameToView:(MTKView *)view {
    [_camera setAspectRatio:view.drawableSize.width / view.drawableSize.height];
    view.clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1);

    CameraUniforms uniforms = [_camera getUniforms];
    memcpy(_cameraUniformsBuffer.contents, &uniforms, sizeof(CameraUniforms));

    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    MTLRenderPassDescriptor *configuration = view.currentRenderPassDescriptor;
    configuration.depthAttachment.loadAction = MTLLoadActionClear;
    configuration.depthAttachment.clearDepth = 1.0;
    configuration.colorAttachments[0].loadAction = MTLLoadActionClear;
    configuration.colorAttachments[0].storeAction = MTLStoreActionStore;

    id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:configuration];
    encoder.label = @"Render Pass Encoder";
    [encoder setRenderPipelineState:renderPipelineState];
    [encoder setDepthStencilState:depthStencilState];
    [encoder setCullMode:MTLCullModeNone];

    [encoder setVertexBuffer:_mesh.vertexBuffer offset:0 atIndex:VertexBufferIndexForVertexData];
    [encoder setVertexBuffer:_cameraUniformsBuffer offset:0 atIndex:VertexBufferIndexForCameraUniforms];
    
    [encoder setFragmentTexture:_texture atIndex:0];
    [encoder setFragmentSamplerState:_samplerState atIndex:0];
    [encoder setFragmentBuffer:_cameraUniformsBuffer offset:0 atIndex:FragmentBufferIndexForCameraUniforms];
    [encoder setFragmentBuffer:_objectUniformsBuffer offset:0 atIndex:FragmentBufferIndexForObjectUniforms];
    [encoder setFragmentBuffer:_lightUniformsBuffer offset:0 atIndex:FragmentBufferIndexForLightUniforms];
    [encoder setFragmentBuffer:_materialUniformsBuffer offset:0 atIndex:FragmentBufferIndexForMaterialUniforms];
    [encoder setFragmentBuffer:_cameraUniformsBuffer offset:0 atIndex:FragmentBufferIndexForCameraUniforms];

    [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                        indexCount:_mesh.indexCount
                         indexType:MTLIndexTypeUInt16
                       indexBuffer:_mesh.indexBuffer
                 indexBufferOffset:0];

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
    descriptor.vertexFunction = [self.defaultLibrary newFunctionWithName:@"vertexShader"];
    descriptor.fragmentFunction = [self.defaultLibrary newFunctionWithName:@"fragmentShader"];

    id<MTLRenderPipelineState> pipelineState = [self.device newRenderPipelineStateWithDescriptor:descriptor
                                                                                           error:&error];
    NSAssert(pipelineState, @"Pipeline compile error: %@", error);
    return pipelineState;
}

- (void) updateWithInput:(InputState)inputState {
    float movementSpeed = 0.05f;
    float rotationSpeed = 0.007f;

    simd_float3 position = [_camera getPosition];
    simd_float3 rotation = [_camera getRotation];
    float yRot = rotation.y;

    simd_float3 forwardVector = simd_normalize(simd_make_float3(sinf(yRot), 0, -cosf(yRot)));
    simd_float3 rightVector   = simd_normalize(simd_make_float3(cosf(yRot), 0,  sinf(yRot)));

    if (inputState.W) position += forwardVector * movementSpeed;
    if (inputState.S) position -= forwardVector * movementSpeed;
    if (inputState.A) position -= rightVector   * movementSpeed;
    if (inputState.D) position += rightVector   * movementSpeed;

    [_camera setPosition:position];

    float maxRotX = M_PI_2 - 0.01f;
    float xRot = rotation.x - inputState.mouseDy * rotationSpeed;
    yRot += inputState.mouseDx * rotationSpeed;

    xRot = fmaxf(-maxRotX, fminf(maxRotX, xRot));

    [_camera setRotation:simd_make_float3(xRot, yRot, 0)];
}

- (id<MTLTexture>) loadTextureNamed:(NSString *) name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSAssert(path, @"Texture '%@' not found", name);
    
    MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:self.device];
    NSError *error = nil;
    
    id<MTLTexture> texture = [loader newTextureWithContentsOfURL:[NSURL fileURLWithPath:path]
                                                         options:@{MTKTextureLoaderOptionSRGB: @NO, MTKTextureLoaderOptionGenerateMipmaps: @YES}
                                                          error:&error];
    NSAssert(texture, @"Failed to load texture: %@", error);
    return texture;
}

@end
