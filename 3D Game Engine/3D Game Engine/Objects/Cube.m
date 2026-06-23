//
//  Cube.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 5/23/26.
//

#import "Cube.h"

@implementation Cube

- (instancetype) initWithMaterial:(Material *)material
                         position:(simd_float4)position
                            scale:(simd_float4)scale
                         rotation:(simd_float4)rotation
                           device:(id<MTLDevice>)device {

    if (self = [super initWithDevice:device]) {
        self.material = material;
        self.position = position;
        self.scale = scale;
        self.rotation = rotation;

        // GameObject's initWithDevice: calls buildCollider BEFORE this
        // subclass initializer sets the real position/scale (it runs
        // right after the (0,0,0)/(1,1,1) defaults are assigned), so
        // the collider built by super's init is centered at the origin
        // with unit size, not the cube's actual transform. Rebuild it
        // now that position/scale are correct.
        self.collider = [self buildCollider];
    }
    
    return self;
}

- (instancetype) initWithPosition:(simd_float4)position
                            scale:(simd_float4)scale
                         rotation:(simd_float4)rotation
                           device:(id<MTLDevice>)device {
    
    return [self initWithMaterial:nil position:position scale:scale rotation:rotation device:device];
}

- (Mesh *) buildMesh:(id<MTLDevice>)device {
    return [Mesh meshFromOBJNamed:@"Cube" device:device];
}

- (Collider *) buildCollider {
    return [Collider colliderWithCenter:self.position size:self.scale];
}

@end
