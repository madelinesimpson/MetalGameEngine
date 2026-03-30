//
//  Renderer.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/16/25.
//

#import <MetalKit/MetalKit.h>
#import "InputState.h"

@interface Renderer : NSObject

@property (nonatomic, readonly) id<MTLDevice> _Nonnull device;
@property (nonatomic, readonly) id<MTLLibrary> _Nonnull defaultLibrary;

- (nonnull instancetype) initWithMetalKitView:(nonnull MTKView *)view;
- (void) renderFrameToView:(nonnull MTKView *)view;
- (void) updateWithInput:(InputState)inputState;

@end

