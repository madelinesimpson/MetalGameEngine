//
//  Plane.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 6/12/26.
//

#include "Plane.h"

@implementation Plane

- (instancetype)initWithMaterial:(Material *)material
                        position:(simd_float4)position
                           scale:(simd_float4)scale
                          device:(id<MTLDevice>)device {
    self = [super init];
    if (!self) return nil;

    self.material = material;
    self.position = position;
    self.scale = scale;

    // 2 triangles, flat on XZ plane
    Vertex vertices[] = {
        { .position = {-0.5, 0,  0.5, 1}, .normal = {0,1,0,0}, .uv = {0,  25}, .color = {1,1,1,1} },
        { .position = { 0.5, 0,  0.5, 1}, .normal = {0,1,0,0}, .uv = {25, 25}, .color = {1,1,1,1} },
        { .position = { 0.5, 0, -0.5, 1}, .normal = {0,1,0,0}, .uv = {25, 0},  .color = {1,1,1,1} },
        { .position = {-0.5, 0, -0.5, 1}, .normal = {0,1,0,0}, .uv = {0,  0},  .color = {1,1,1,1} },
    };
    uint32_t indices[] = { 0, 1, 2, 0, 2, 3 };

    self.mesh = [Mesh meshWithVertices:vertices
                           vertexCount:4
                               indices:indices
                           indexCount:6
                               device:device];
    return self;
}

@end
