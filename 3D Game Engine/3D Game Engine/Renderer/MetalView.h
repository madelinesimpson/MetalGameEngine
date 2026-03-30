//
//  MetalView.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/26/25.
//

#import <MetalKit/MetalKit.h>
#import "Renderer.h"

@class Renderer;

// Custom MTKView implementation to accept keypress as input
@interface MetalView: MTKView

@property (nonatomic, weak) Renderer* renderer;

- (InputState)getInputState;

@end
