//
//  Renderer.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/16/25.
//

#import "Renderer.h"
#import "Camera.h"
#import "PrimitiveData.h"

@implementation Renderer {
    
    id<MTL4CommandQueue> commandQueue;
    
    id<MTL4CommandBuffer> commandBuffer;
    
    // Resource bindings for render encoder
    id<MTL4ArgumentTable> argumentTable;
    
    id<MTLRenderPipelineState> renderPipelineState;
    
    // Triangle mesh
    Mesh* _triangleMesh;
    
    Camera* _camera;
    id<MTLBuffer> _cameraUniformsBuffer;
}

- (nonnull instancetype) initWithMetalKitView:(nonnull MTKView *) view {
    
    self = [super init];
    if (nil == self) {return nil;}
    
    // Setup all of our rendering objects
    _device = view.device;
    commandQueue = [self.device newMTL4CommandQueue];
    commandBuffer = [self.device newCommandBuffer];
    _defaultLibrary = [self.device newDefaultLibrary];
    
    argumentTable = [self makeArgumentTable];
    
    renderPipelineState = [self compileRenderPipeline:view.colorPixelFormat];
    
    _camera = [[Camera alloc] init];
    _cameraUniformsBuffer = [self.device newBufferWithLength:sizeof(CameraUniforms)
                                                     options:MTLResourceStorageModeShared];
    
    [self drawStuff];
    
    return self;
}

// Function where you add all the stuff you want to draw
- (void) drawStuff {
    // Make a triangle mesh
    Vertex verts[3];
    makeTriangle((simd_float3){  0.0f,  0.5f, -1.0f },
                 (simd_float3){ -0.5f, -0.5f, -1.0f },
                 (simd_float3){  0.5f, -0.5f, -1.0f },
                 verts);
    
    _triangleMesh = [[Mesh alloc] initWithDevice:self.device
                                        vertices:verts
                                     vertexCount:3
                                         indices:NULL
                                      indexCount:0];
}

- (void) renderFrameToView:(MTKView *)view {
    
    [_camera setAspectRatio:view.drawableSize.width/view.drawableSize.height];
    
    id<MTL4CommandBuffer> commandBuffer = [self.device newCommandBuffer];
    id<MTL4CommandAllocator> commandAllocator = [self.device newCommandAllocator];

    [commandBuffer beginCommandBufferWithAllocator:commandAllocator];
    
    CameraUniforms uniforms = [_camera getUniforms];
    memcpy(_cameraUniformsBuffer.contents, &uniforms, sizeof(CameraUniforms));
    
    // Create our render pass encoder
    id<MTL4RenderCommandEncoder> renderPassEncoder;
    // Reuse current drawable's render pass descriptor
    MTL4RenderPassDescriptor *configuration = view.currentMTL4RenderPassDescriptor;
    renderPassEncoder = [commandBuffer renderCommandEncoderWithDescriptor:configuration];
    renderPassEncoder.label = @"Render Pass Encoder";
    
    // Set our render pipeline state
    [renderPassEncoder setRenderPipelineState:renderPipelineState];
    [argumentTable setAddress:_triangleMesh.vertexBuffer.gpuAddress atIndex:InputBufferIndexForVertexData];
    [argumentTable setAddress:_cameraUniformsBuffer.gpuAddress atIndex:InputBufferIndexForCameraUniforms];
    
    [renderPassEncoder setArgumentTable:argumentTable atStages:MTLRenderStageVertex];

    // Draw the triangle
    [renderPassEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                          vertexStart:0
                          vertexCount:3];
    
    // End encoding
    [renderPassEncoder endEncoding];
    [commandBuffer endCommandBuffer];
    
    // Submit what we encoded to the buffer to be rendered
    [self submitCommandBuffer:commandBuffer
                 toCommandQueue:commandQueue
                      forView:view];
}

- (id<MTL4ArgumentTable>) makeArgumentTable
{
    NSError *error = nil;
    
    MTL4ArgumentTableDescriptor *argumentTableDescriptor;
    argumentTableDescriptor = [MTL4ArgumentTableDescriptor new];
    argumentTableDescriptor.maxBufferBindCount = 2;

    id<MTL4ArgumentTable> argumentTable;
    argumentTable = [self.device newArgumentTableWithDescriptor:argumentTableDescriptor
                                                          error:&error];
    return argumentTable;
}

- (void) submitCommandBuffer:(id<MTL4CommandBuffer>) commandBuffer
              toCommandQueue:(id<MTL4CommandQueue>) commandQueue
                     forView:(nonnull MTKView *) view
{
    // A drawable from the view that the method renders the frame to.
    id<CAMetalDrawable> currentDrawable = view.currentDrawable;

    // Instruct the queue to wait until the drawable is ready to receive output from the render pass.
    [commandQueue waitForDrawable:currentDrawable];

    // Submit command to the Metal device's queue.
    [commandQueue commit:&commandBuffer count:1];

    // Notify the drawable that the GPU is done running the render pass.
    [commandQueue signalDrawable:currentDrawable];

    // Instruct the drawable to show itself on the device's display when the render pass completes.
    [currentDrawable present];
}

- (id<MTLRenderPipelineState>) compileRenderPipeline:(MTLPixelFormat) colorPixelFormat
{
    // A Metal 4 compiler instance with a default configuration.
    NSError *error = nil;
    id<MTL4Compiler> compiler = [self.device newCompilerWithDescriptor:[MTL4CompilerDescriptor new]
                                                error:&error];

    // A configuration for the render pipeline the method compiles.
    MTL4RenderPipelineDescriptor* descriptor;
    descriptor = [self configureRenderPipeline: colorPixelFormat];

    id<MTLRenderPipelineState> renderPipelineState;
    renderPipelineState = [compiler newRenderPipelineStateWithDescriptor:descriptor
                                                     compilerTaskOptions:NULL
                                                                   error:&error];
    
    return renderPipelineState;
}

- (MTL4RenderPipelineDescriptor*) configureRenderPipeline:(MTLPixelFormat) colorPixelFormat
{
    MTL4RenderPipelineDescriptor *renderPipelineDescriptor;
    renderPipelineDescriptor = [MTL4RenderPipelineDescriptor new];
    renderPipelineDescriptor.label = @"Basic Metal 4 render pipeline";

    renderPipelineDescriptor.colorAttachments[0].pixelFormat = colorPixelFormat;
    renderPipelineDescriptor.vertexFunctionDescriptor = [self makeVertexShaderConfiguration];
    renderPipelineDescriptor.fragmentFunctionDescriptor = [self makeFragmentShaderConfiguration];

    return renderPipelineDescriptor;
}


- (MTL4LibraryFunctionDescriptor*) makeVertexShaderConfiguration
{
    MTL4LibraryFunctionDescriptor *vertexFunction;
    vertexFunction = [MTL4LibraryFunctionDescriptor new];
    vertexFunction.library = self.defaultLibrary;
    vertexFunction.name = @"vertexShader";

    return vertexFunction;
}

- (MTL4LibraryFunctionDescriptor*) makeFragmentShaderConfiguration
{
    MTL4LibraryFunctionDescriptor *fragmentFunction;
    fragmentFunction = [MTL4LibraryFunctionDescriptor new];
    fragmentFunction.library = self.defaultLibrary;
    fragmentFunction.name = @"fragmentShader";

    return fragmentFunction;
}

NSString* printMatrix(simd_float4x4 m) {
    return [NSString stringWithFormat:
        @"[%.2f %.2f %.2f %.2f]\n"
         "[%.2f %.2f %.2f %.2f]\n"
         "[%.2f %.2f %.2f %.2f]\n"
         "[%.2f %.2f %.2f %.2f]\n",
        m.columns[0].x, m.columns[0].y, m.columns[0].z, m.columns[0].w,
        m.columns[1].x, m.columns[1].y, m.columns[1].z, m.columns[1].w,
        m.columns[2].x, m.columns[2].y, m.columns[2].z, m.columns[2].w,
        m.columns[3].x, m.columns[3].y, m.columns[3].z, m.columns[3].w];
}

- (void)updateWithInput:(InputState)inputState {
    float movementSpeed = 0.05f;
    float rotationSpeed = 0.002f;

    simd_float3 position = [_camera getPosition];
    simd_float3 rotation = [_camera getRotation];

    // Rotation around y axis
    float yRot = rotation.y;

    simd_float3 forwardVector = simd_normalize(simd_make_float3(sinf(yRot), 0, -cosf(yRot)));
    simd_float3 rightVector = simd_normalize(simd_make_float3(cosf(yRot), 0, sinf(yRot)));

    if (inputState.W) {
        position += forwardVector * movementSpeed;
    }
    if (inputState.S) {
        position -= forwardVector * movementSpeed;
    }
    if (inputState.A) {
        position -= rightVector * movementSpeed;
    }
    if (inputState.D) {
        position += rightVector * movementSpeed;
    }

    [_camera setPosition: position];

    // Clamp x axis rotation, otherwise get gimbal lock glitches
    float maxRotX = (M_PI_2 - 0.01f);

    // Rotation around x axis
    float xRot = rotation.x;
    
    xRot -= inputState.mouseDy * rotationSpeed;
    yRot += inputState.mouseDx * rotationSpeed;

    if (xRot > maxRotX) xRot =  maxRotX;
    if (xRot < -maxRotX) xRot = -maxRotX;

    [_camera setRotation: simd_make_float3(xRot, yRot, 0)];
}


@end
