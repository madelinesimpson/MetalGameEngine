//
//  Collider.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 5/20/26.
//

#ifndef COLLIDER_H
#define COLLIDER_H

#import <simd/simd.h>
#import <MetalKit/MetalKit.h>

typedef struct {
    simd_float4 origin;
    simd_float4 direction;
} Ray;

typedef struct {
    simd_float4 point;
    simd_float4 normal;
    float distance;
} RayHit;


@interface Collider: NSObject

@property (nonatomic) simd_float4 center;
@property (nonatomic) simd_float4 size;

+ (instancetype)colliderWithCenter:(simd_float4)center
                              size:(simd_float4)size;

- (BOOL)intersectsRay:(Ray)ray
                  hit:(RayHit *)hit;

@end

#endif
