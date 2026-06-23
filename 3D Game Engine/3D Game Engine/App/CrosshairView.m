//
//  CrosshairView.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 5/20/26.
//

#import "CrosshairView.h"

@implementation CrosshairView

- (instancetype)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Make background transparent
        self.wantsLayer = YES;
        self.layer.backgroundColor = NSColor.clearColor.CGColor;
    }
    return self;
}

- (BOOL)isOpaque {
    return NO;
}

- (NSView *)hitTest:(NSPoint)point {
    return nil;
}

// Draw crosshair
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    CGFloat cx = self.bounds.size.width  / 2.0;
    CGFloat cy = self.bounds.size.height / 2.0;
    CGFloat size = 10.0;

    NSBezierPath *path = [NSBezierPath bezierPath];
    path.lineWidth = 1.5;

    [path moveToPoint:NSMakePoint(cx - size, cy)];
    [path lineToPoint:NSMakePoint(cx + size, cy)];
    [path moveToPoint:NSMakePoint(cx, cy - size)];
    [path lineToPoint:NSMakePoint(cx, cy + size)];

    [[NSColor whiteColor] setStroke];
    [path stroke];
}

@end
