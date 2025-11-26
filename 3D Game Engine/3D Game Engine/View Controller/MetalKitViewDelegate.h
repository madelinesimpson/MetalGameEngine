//
//  MetalKitViewDelegate.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/17/25.
//

#import <MetalKit/MetalKit.h>

@interface MetalKitViewDelegate : NSObject<MTKViewDelegate>

- (nonnull instancetype) initWithMetalKitView:(nonnull MTKView *) view;

@end
