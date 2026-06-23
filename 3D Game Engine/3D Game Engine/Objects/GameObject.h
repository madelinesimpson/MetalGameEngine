//
//  GameObject.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 4/6/26.
//

#ifndef GAMEOBJECT_H
#define GAMEOBJECT_H

#import "Mesh.h"
#import "ShaderTypes.h"
#import "Material.h"
#import <MetalKit/MetalKit.h>
#import "Collider.h"

@interface GameObject: NSObject

@property (nonatomic) simd_float4 position;
@property (nonatomic) simd_float4 rotation;
@property (nonatomic) simd_float4 scale;

@property (nonatomic, strong) Collider *collider;
@property (nonatomic, strong) Mesh* mesh;
@property (nonatomic, strong) Material* material;

@property (nonatomic, weak, readonly) GameObject* parent;
@property (nonatomic, strong) NSMutableArray<GameObject *> *children;
    
// Get model matrix from position, rotation, and scale
- (simd_float4x4) getWorldMatrix;

-(instancetype)initWithDevice:(id<MTLDevice>)device;
- (Mesh *) buildMesh:(id<MTLDevice>)device;
- (Collider *) buildCollider;
- (void) addChild:(GameObject*)child;
- (void)debugPrintWorldMatrix;


@end


#endif
