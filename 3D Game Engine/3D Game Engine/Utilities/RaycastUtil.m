//
//  RaycastUtil.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 6/23/26.
//
//

#import "RaycastUtil.h"

// Unprojects an NDC point (x, y in [-1,1], z = depth in [0,1] for Metal's
// clip space) back into world space using the inverse view proj matrix.
static simd_float4 UnprojectNDC(simd_float3 ndc, matrix_float4x4 invViewProj) {
    simd_float4 clip = simd_make_float4(ndc.x, ndc.y, ndc.z, 1.0f);
    simd_float4 world = matrix_multiply(invViewProj, clip);
    if (world.w != 0.0f) {
        world.x /= world.w;
        world.y /= world.w;
        world.z /= world.w;
    }
    return world;
}

Ray RayFromCameraClick(Camera *camera, float ndcX, float ndcY) {
    matrix_float4x4 viewMatrix = [camera getViewMatrix];
    matrix_float4x4 projMatrix = [camera getProjectionMatrix];
    matrix_float4x4 viewProj = matrix_multiply(projMatrix, viewMatrix);
    matrix_float4x4 invViewProj = matrix_invert(viewProj);

    // Near plane (z=0) and far plane (z=1) points in clip space, unprojected.
    simd_float4 nearPoint = UnprojectNDC(simd_make_float3(ndcX, ndcY, 0.0f), invViewProj);
    simd_float4 farPoint  = UnprojectNDC(simd_make_float3(ndcX, ndcY, 1.0f), invViewProj);

    simd_float3 origin = simd_make_float3(nearPoint.x, nearPoint.y, nearPoint.z);
    simd_float3 farPos  = simd_make_float3(farPoint.x, farPoint.y, farPoint.z);
    simd_float3 direction = simd_normalize(farPos - origin);

    Ray ray;
    ray.origin = simd_make_float4(origin.x, origin.y, origin.z, 1.0f);
    ray.direction = simd_make_float4(direction.x, direction.y, direction.z, 0.0f);
    return ray;
}

BlockPickResult PickBlock(Ray ray, BlockGrid *world) {
    BlockPickResult result;
    result.didHit = NO;
    result.hitGridCoord = simd_make_int3(0, 0, 0);
    result.placementGridCoord = simd_make_int3(0, 0, 0);

    float closestDistance = FLT_MAX;
    Cube *closestCube = nil;
    RayHit closestHit;

    for (Cube *cube in world.allCubes) {
        RayHit hit;
        if ([cube.collider intersectsRay:ray hit:&hit]) {
            if (hit.distance < closestDistance) {
                closestDistance = hit.distance;
                closestCube = cube;
                closestHit = hit;
            }
        }
    }

    if (!closestCube) {
        return result;
    }

    simd_float3 hitCubePos = simd_make_float3(closestCube.position.x,
                                               closestCube.position.y,
                                               closestCube.position.z);
    simd_int3 hitGridCoord = [BlockGrid gridCoordForWorldPosition:hitCubePos];

    // The collider gives us the world space normal of the face we hit
    // We have to step one cell out along that normal to find where a placed cube goes
    simd_float3 normal = simd_make_float3(closestHit.normal.x,
                                           closestHit.normal.y,
                                           closestHit.normal.z);
    simd_int3 step = simd_make_int3((int)roundf(normal.x),
                                     (int)roundf(normal.y),
                                     (int)roundf(normal.z));

    result.didHit = YES;
    result.hitGridCoord = hitGridCoord;
    result.placementGridCoord = simd_make_int3(hitGridCoord.x + step.x,
                                                 hitGridCoord.y + step.y,
                                                 hitGridCoord.z + step.z);
    return result;
}
