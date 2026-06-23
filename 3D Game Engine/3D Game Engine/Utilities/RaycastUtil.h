//
//  RayCastUtil.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 6/23/26.
//

#ifndef RAYCASTUTIL_H
#define RAYCASTUTIL_H

#import <simd/simd.h>
#import "Camera.h"
#import "Collider.h"
#import "BlockGrid.h"
#import "Cube.h"

// Builds a world-space ray from a click in NDC
// (ndcX, ndcY both in [-1, 1]) using the camera's view & projection matrices.
Ray RayFromCameraClick(Camera *camera, float ndcX, float ndcY);

// Result of picking a cube: the cube that was hit, and the grid coordinate
// directly outside the hit face (i.e. where a new cube should be placed).
typedef struct {
    BOOL didHit;
    simd_int3 hitGridCoord; // grid coord of the cube that was hit
    simd_int3 placementGridCoord; // adjacent empty cell, face out from the hit
} BlockPickResult;

// Sweeps every cube currently in the world and returns the closest one
// the ray intersects, plus where a new cube would go if you placed one
// against the hit face. didHit is NO if nothing was hit.
BlockPickResult PickBlock(Ray ray, BlockGrid *world);

#endif
