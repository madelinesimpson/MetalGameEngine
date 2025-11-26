//
//  Renderer.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/16/25.
//

#import "RendererProtocol.h"
#import "Mesh.h"

@interface Renderer : NSObject<RendererProtocol>

@property (nonatomic, readonly) id<MTLDevice> _Nonnull device;
@property (nonatomic, readonly) id<MTLLibrary> _Nonnull defaultLibrary;
@property (nonatomic, strong) Mesh* triangleMesh;

// Setup
- (nonnull id<MTL4ArgumentTable>) makeArgumentTable;

// Encoding
- (void) submitCommandBuffer:(nonnull id<MTL4CommandBuffer>) commandBuffer
                toCommandQueue:(nonnull id<MTL4CommandQueue>) commandQueue
                     forView:(nonnull MTKView *) view;

// Compilation
- (_Nonnull id<MTLRenderPipelineState>) compileRenderPipeline:(MTLPixelFormat) colorPixelFormat;

@end

