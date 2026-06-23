//
//  BlockGrid.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 6/23/26.
//

#import "BlockGrid.h"

// Encode a grid coord into a string key
static inline NSString * BlockKeyForGridCoord(simd_int3 c) {
    return [NSString stringWithFormat:@"%d,%d,%d", c.x, c.y, c.z];
}

@implementation BlockGrid {
    NSMutableDictionary<NSString *, Cube *> *_cubesByGridCoord;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cubesByGridCoord = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSArray<Cube *> *)allCubes {
    return _cubesByGridCoord.allValues;
}

+ (simd_int3)gridCoordForWorldPosition:(simd_float3)worldPosition {
    // Round to nearest cube pos to avoid floating point error
    return simd_make_int3((int)roundf(worldPosition.x / kVoxelSize),
                          (int)roundf(worldPosition.y / kVoxelSize),
                          (int)roundf(worldPosition.z / kVoxelSize));
}

+ (simd_float3)worldPositionForGridCoord:(simd_int3)gridCoord {
    return simd_make_float3(gridCoord.x * kVoxelSize,
                             gridCoord.y * kVoxelSize,
                             gridCoord.z * kVoxelSize);
}

- (Cube *)cubeAtGridCoord:(simd_int3)gridCoord {
    return _cubesByGridCoord[BlockKeyForGridCoord(gridCoord)];
}

- (Cube *)placeCubeAtGridCoord:(simd_int3)gridCoord
                       material:(Material *)material
                         device:(id<MTLDevice>)device {
    NSString *key = BlockKeyForGridCoord(gridCoord);
    Cube *existing = _cubesByGridCoord[key];
    if (existing) {
        return existing;
    }

    simd_float3 worldPos = [BlockGrid worldPositionForGridCoord:gridCoord];
    Cube *cube = [[Cube alloc] initWithMaterial:material
                                        position:simd_make_float4(worldPos.x, worldPos.y, worldPos.z, 1)
                                           scale:simd_make_float4(1, 1, 1, 1)
                                        rotation:simd_make_float4(0, 0, 0, 0)
                                          device:device];
    _cubesByGridCoord[key] = cube;
    return cube;
}

- (void)removeCubeAtGridCoord:(simd_int3)gridCoord {
    [_cubesByGridCoord removeObjectForKey:BlockKeyForGridCoord(gridCoord)];
}

@end
