//
//  ViewController.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/17/25.
//

#import "ViewController.h"
#import "MetalView.h"
#import "MetalKitViewDelegate.h"
#import "CrosshairView.h"

@implementation ViewController
{
    MTKView *view;
    MetalKitViewDelegate *delegate;
}

- (void) viewDidLoad
{
    // Call the super class's method first.
    [super viewDidLoad];

    // Store a reference to the app's main view.
    view = (MTKView *)self.view;

    // Set the view's device property to the system's default Metal device.
    view.device = MTLCreateSystemDefaultDevice();
    NSAssert(view.device, @"Metal doesn't support this device.");

    delegate = [[MetalKitViewDelegate alloc] initWithMetalKitView:view];
    NSAssert(delegate, @"The view controller can't make a delegate for the MetalKit view.");

    view.delegate = delegate;
    
    CrosshairView *crosshair = [[CrosshairView alloc] initWithFrame:self.view.bounds];
    crosshair.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.view addSubview:crosshair];
}

// For keyboard input
- (void) viewDidAppear
{
    [super viewDidAppear];
    [self.view.window makeFirstResponder:(MetalView *)self.view];
}

@end
