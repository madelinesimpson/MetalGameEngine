//
//  MetalView.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/26/25.
//

#include "MetalView.h"

@implementation MetalView {
    bool keyW;
    bool keyA;
    bool keyS;
    bool keyD;
    float mouseDx;
    float mouseDy;
    
    NSPoint lastMouseLocation;
    bool hasInitialMouse;
}

- (void)commonInit {
    keyW = false;
    keyA = false;
    keyS = false;
    keyD = false;
    mouseDx = 0;
    mouseDy = 0;
    lastMouseLocation.x = 0;
    lastMouseLocation.y = 0;
    hasInitialMouse = false;
    
    [self.window setAcceptsMouseMovedEvents:YES];
    [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:self.bounds
                                                       options:NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow | NSTrackingInVisibleRect
                                                         owner: self
                                                      userInfo: nil]];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect device:(id<MTLDevice>)device {
    self = [super initWithFrame:frameRect device:device];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)event
{
    switch (event.keyCode) {
        case 13: keyW = true; break;
        case 0:  keyA = true; break;
        case 1:  keyS = true; break;
        case 2:  keyD = true; break;
    }
}

- (void)keyUp:(NSEvent *)event
{
    switch (event.keyCode) {
        case 13: keyW = false; break;
        case 0:  keyA = false; break;
        case 1:  keyS = false; break;
        case 2:  keyD = false; break;
    }
}

- (void)mouseMoved:(NSEvent *)event
{
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    if (!hasInitialMouse) {
        lastMouseLocation = location;
        hasInitialMouse = true;
        return;
    }
    
    float dx = location.x - lastMouseLocation.x;
    float dy = location.y - lastMouseLocation.y;
    
    mouseDx += dx;
    mouseDy += dy;
    
    lastMouseLocation = location;
}

- (void)mouseExited:(NSEvent *)event {
    hasInitialMouse = false;
    mouseDx = 0;
    mouseDy = 0;
}

- (void)mouseEntered:(NSEvent *)event {
    hasInitialMouse = false;
}

- (InputState)getInputState {
    InputState state;
    state.W = keyW;
    state.A = keyA;
    state.S = keyS;
    state.D = keyD;
    state.mouseDx = mouseDx;
    state.mouseDy = mouseDy;
    mouseDx = 0;
    mouseDy = 0;
    return state;
}


@end
