//
//  RendererProtocol.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/16/25.
//

#import <MetalKit/MetalKit.h>

typedef struct {
    bool W;
    bool A;
    bool S;
    bool D;
    float mouseDx;
    float mouseDy;
} InputState;

@protocol RendererProtocol<NSObject>

- (nonnull instancetype) initWithMetalKitView:(nonnull MTKView *) view;

- (void) renderFrameToView:(nonnull MTKView *) view;

- (void)updateWithInput:(InputState)inputState;

@end


