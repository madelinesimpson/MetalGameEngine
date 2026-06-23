//
//  Plane.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 6/12/26.
//

#ifndef PLANE_H
#define PLANE_H

#import "GameObject.h"

@interface Plane : GameObject
- (instancetype)initWithMaterial:(Material *)material
                        position:(simd_float4)position
                           scale:(simd_float4)scale
                          device:(id<MTLDevice>)device;
@end
#endif

