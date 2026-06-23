//
//  Light.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 4/6/26.
//

#include "Light.h"

@implementation Light {
    
}

- (instancetype) init {
    if (self = [super init]) {
        _position = simd_make_float3(5, 5, 10);
        _ambient  = simd_make_float4(0.3, 0.3, 0.3, 0.0);
        _diffuse  = simd_make_float4(1.0, 1.0, 1.0, 0.0);
        _specular = simd_make_float4(1.0, 1.0, 1.0, 0.0);
    }
    return self;
}

- (LightUniforms) uniforms {
    return (LightUniforms){
        .position = simd_make_float4(self.position, 0.0),
        .ambient  = self.ambient,
        .diffuse  = self.diffuse,
        .specular = self.specular
    };
}

+ (instancetype) defaultLight {
    return [[Light alloc] init];
}

+ (instancetype) lightWithPosition:(simd_float3)position
                           ambient:(simd_float4)ambient
                           diffuse:(simd_float4)diffuse
                          specular:(simd_float4)specular {
    Light *l = [[Light alloc] init];
    l.position = position;
    l.ambient  = ambient;
    l.diffuse  = diffuse;
    l.specular = specular;
    return l;
}

@end
