//
//  Collider.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 5/20/26.
//

#import "Collider.h"

@implementation Collider

+ (instancetype)colliderWithCenter:(simd_float4)center
                              size:(simd_float4)size {
    
    Collider *c = [Collider new];
    c.center = center;
    c.size = size;
    return c;
}

// 22.7.1 Slabs Method p. 960 in Real Time Rendering 4th Edition
- (BOOL)intersectsRay:(Ray)ray
                  hit:(RayHit *)hit {
    simd_float3 center = self.center.xyz;
    simd_float3 size = self.size.xyz;
    simd_float3 origin = ray.origin.xyz;
    simd_float3 dir = ray.direction.xyz;

    simd_float3 bmin = center - size; // Bouding box min coord
    simd_float3 bmax = center + size; // Bounding box max coord

    simd_float3 tminV = (bmin - origin) / dir;
    simd_float3 tmaxV = (bmax - origin) / dir;

    simd_float3 t1 = simd_min(tminV, tmaxV);
    simd_float3 t2 = simd_max(tminV, tmaxV);

    float tmin = fmaxf(fmaxf(t1.x, t1.y), t1.z);
    float tmax = fminf(fminf(t2.x, t2.y), t2.z);

    if (tmin > tmax || tmin < 0) {
        return NO;
    }

    if (hit) {
        hit->distance = tmin;
        simd_float3 hitPoint = origin + dir * tmin;
        hit->point = simd_make_float4(hitPoint, 1);

        simd_float3 localHit = hitPoint - center;
        simd_float3 absLocal = simd_abs(localHit) / size;
        simd_float3 normal;
        if (absLocal.x > absLocal.y && absLocal.x > absLocal.z)
            normal = simd_make_float3(localHit.x > 0 ? 1 : -1, 0, 0);
        else if (absLocal.y > absLocal.z)
            normal = simd_make_float3(0, localHit.y > 0 ? 1 : -1, 0);
        else
            normal = simd_make_float3(0, 0, localHit.z > 0 ? 1 : -1);

        hit->normal = simd_make_float4(normal, 0);
    }

    return YES;
}

@end
