//
//  BlockGrid.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 6/23/26.
//


#ifndef BLOCKGRID_H
#define BLOCKGRID_H
 
#import <Foundation/Foundation.h>
#import <simd/simd.h>
#import "Cube.h"
#import "Material.h"
 
// Size of one block in world units. Cubes are placed on a grid
static const float kVoxelSize = 2.0f;
 
@interface BlockGrid : NSObject
 
// All currently-placed cubes (ground + player placed), keyed internally
// by grid coordinate
@property (nonatomic, strong, readonly) NSArray<Cube *> *allCubes;
 
- (instancetype)init;
 
// Grid coordinate to world position (and vice versa) helpers
// Grid coords are integers and world position is the cube's center
+ (simd_int3)gridCoordForWorldPosition:(simd_float3)worldPosition;
+ (simd_float3)worldPositionForGridCoord:(simd_int3)gridCoord;
 
// Returns the cube at a grid coordinate
- (Cube *)cubeAtGridCoord:(simd_int3)gridCoord;
 
// Places a new cube at gridCoord if empty
// Returns the new cube
- (Cube *)placeCubeAtGridCoord:(simd_int3)gridCoord
                       material:(Material *)material
                         device:(id<MTLDevice>)device;
 
// Removes the cube at gridCoord if any exists
- (void)removeCubeAtGridCoord:(simd_int3)gridCoord;
 
@end
 
#endif
