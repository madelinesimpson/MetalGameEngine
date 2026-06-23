//
//  MetalKitViewDelegate.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/17/25.
//


#import "MetalKitViewDelegate.h"
#import "MetalView.h"
#import "Renderer.h"
#import "SceneManager.h"

/// A class that renders each of the app's video frames.
@implementation MetalKitViewDelegate
{
@protected
    Renderer* renderer;
    MTKView *metalKitView;
}

/// Creates a delegate for a view.
///
/// The method detects whether the system supports Metal 4 and creates an
/// instance of the appropriate renderer type.
- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view
{
    self = [super init];
    if (nil == self) { return nil; }
    
    metalKitView = view;
    renderer = [[Renderer alloc] initWithMetalKitView:view];
    NSAssert(renderer, @"Failed to create renderer.");

    renderer.minecraft = [[Minecraft alloc] initWithDevice:view.device];
    SceneManager* sceneManager = [[SceneManager alloc] init];
    [renderer.minecraft build:sceneManager];

    return self;
}

/// Notifies the app when the system adjusts the size of its viewable area.
- (void) mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize) size
{
    NSAssert(metalKitView == view, @"The delegate only works with one view.");
}

/// Notifies the app when the system is ready draw a frame into a view.
- (void) drawInMTKView:(nonnull MTKView *) view
{
    // Get input from keys before rendering frame to view
    MetalView *mv = (MetalView *)view;
    InputState input = [mv getInputState];
    [renderer updateWithInput:input];
    NSAssert(metalKitView == view, @"The delegate only works with one view.");
    [renderer renderFrameToView:view];
}

@end
