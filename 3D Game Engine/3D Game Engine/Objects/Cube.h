//
//  Cube.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 5/23/26.
//

#ifndef CUBE_H
#define CUBE_H

#import "GameObject.h"

@interface Cube: GameObject

// Constructors
- (instancetype) initWithMaterial:(Material *)material
                         position:(simd_float4)position
                            scale:(simd_float4)scale
                         rotation:(simd_float4)rotation
                           device:(id<MTLDevice>)device;

- (instancetype) initWithPosition:(simd_float4)position
                            scale:(simd_float4)scale
                         rotation:(simd_float4)rotation
                           device:(id<MTLDevice>)device;
    
@end

#endif
