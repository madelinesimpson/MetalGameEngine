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
    bool mouseClicked;
    float mouseClickedX;
    float mouseClickedY;
    bool rightMouseClicked;
    
    NSPoint lastMouseLocation;
    bool hasInitialMouse;
}

- (void)commonInit {
    // Mouse and keyboard input controls
    keyW = false;
    keyA = false;
    keyS = false;
    keyD = false;
    mouseDx = 0;
    mouseDy = 0;
    lastMouseLocation.x = 0;
    lastMouseLocation.y = 0;
    hasInitialMouse = false;
    mouseClicked = false;
    mouseClickedX = 0;
    mouseClickedY = 0;
    rightMouseClicked = false;
    
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
    state.mouseClicked = mouseClicked;
    state.rightMouseClicked = rightMouseClicked;
    mouseDx = 0;
    mouseDy = 0;
    mouseClicked = false;
    rightMouseClicked = false;
    mouseClickedX = 0;
    mouseClickedY = 0;
    return state;
}

// Converts a click location to NDC and stashes it, shared by left/right click.
- (void)recordClickAt:(NSEvent *)event {
    NSPoint p = [self convertPoint:event.locationInWindow fromView:nil];
    float ndcX =  (2.0f * p.x / self.bounds.size.width)  - 1.0f;
    float ndcY = -((2.0f * p.y / self.bounds.size.height) - 1.0f);
}

- (void)mouseDown:(NSEvent *)event {
    [self recordClickAt:event];
    mouseClicked = true;
}

- (void)rightMouseDown:(NSEvent *)event {
    [self recordClickAt:event];
    rightMouseClicked = true;
}

@end
