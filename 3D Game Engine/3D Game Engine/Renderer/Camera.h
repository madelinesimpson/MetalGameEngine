//
//  Camera.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/24/25.
//

#ifndef Camera_h
#define Camera_h

#import <simd/simd.h>
#import <MetalKit/MetalKit.h>
#import "ShaderTypes.h"

@interface Camera : NSObject

@property (nonatomic) simd_float3 position;
@property (nonatomic) simd_float3 rotation;
@property (nonatomic) simd_float3 scale;
@property (nonatomic) float aspectRatio;
@property (nonatomic) float fov;
@property (nonatomic) float near;
@property (nonatomic) float far;
@property (nonatomic) simd_float3 forwardVector;

-(CameraUniforms)getUniforms;
-(matrix_float4x4)getViewMatrix;
-(matrix_float4x4)getProjectionMatrix;
-(simd_float3)getPosition;
-(simd_float3)getRotation;

@end


#endif
