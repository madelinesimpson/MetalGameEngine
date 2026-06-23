//
//  Light.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 4/6/26.
//

#ifndef LIGHT_H
#define LIGHT_H

#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "ShaderTypes.h"

@interface Light : NSObject

@property (nonatomic) simd_float3 position;
@property (nonatomic) simd_float4 ambient;
@property (nonatomic) simd_float4 diffuse;
@property (nonatomic) simd_float4 specular;

- (LightUniforms) uniforms;

+ (instancetype) defaultLight;
+ (instancetype) lightWithPosition:(simd_float3)position
                           ambient:(simd_float4)ambient
                           diffuse:(simd_float4)diffuse
                          specular:(simd_float4)specular;

@end

#endif
