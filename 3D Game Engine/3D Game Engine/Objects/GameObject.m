//
//  GameObject.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 4/6/26.
//

#include "GameObject.h"
#import "MathUtils.h"

@interface GameObject ()
@property (nonatomic, weak, readwrite) GameObject *parent;
@end

@implementation GameObject

- (instancetype) initWithDevice:(id<MTLDevice>)device {
    
    if (self = [super init]) {
        _position = simd_make_float4(0, 0, 0, 0);
        _rotation = simd_make_float4(0, 0, 0, 0);
        _scale = simd_make_float4(1, 1, 1, 1);
        
        _collider = [self buildCollider];
        _mesh = [self buildMesh:device];
        _children = [NSMutableArray array];
    }
    
    return self;
}

- (simd_float4x4) getWorldMatrix {
    if (self.parent != nil) {
        return matrix_multiply([self.parent getWorldMatrix], [self getModelMatrix]);
    }
    
    return [self getModelMatrix];
}

- (simd_float4x4) getModelMatrix {
    simd_float4x4 t = translationMatrix(self.position);
    simd_float4x4 r = rotationMatrix(self.rotation);
    simd_float4x4 s = scaleMatrix(self.scale);
    return matrix_multiply(t, matrix_multiply(r, s));
}

- (Collider*) buildCollider {
//    NSAssert(NO, @"Subclass %@ must override buildMesh", [self class]);
    return nil;
}

- (Mesh*) buildMesh:(id<MTLDevice>)device {
//    NSAssert(NO, @"Subclass %@ must override buildCollider", [self class]);
    return nil;
}

- (void) addChild:(GameObject*)child {
    child.parent = self;
    [self.children addObject:child];
}

- (void)debugPrintWorldMatrix {
    simd_float4x4 m = [self getWorldMatrix];
    NSLog(@"[%@] World Matrix:", self.class);
    NSLog(@"  [ %.2f  %.2f  %.2f  %.2f ]", m.columns[0][0], m.columns[1][0], m.columns[2][0], m.columns[3][0]);
    NSLog(@"  [ %.2f  %.2f  %.2f  %.2f ]", m.columns[0][1], m.columns[1][1], m.columns[2][1], m.columns[3][1]);
    NSLog(@"  [ %.2f  %.2f  %.2f  %.2f ]", m.columns[0][2], m.columns[1][2], m.columns[2][2], m.columns[3][2]);
    NSLog(@"  [ %.2f  %.2f  %.2f  %.2f ]", m.columns[0][3], m.columns[1][3], m.columns[2][3], m.columns[3][3]);
}

@end
