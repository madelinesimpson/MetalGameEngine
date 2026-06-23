//
//  Material.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 4/6/26.
//

#import <MetalKit/MetalKit.h>
#import "ShaderTypes.h"

@interface Material : NSObject

// Shading properties
@property (nonatomic) simd_float4 color;
@property (nonatomic) float ambient;
@property (nonatomic) float diffuse;
@property (nonatomic) float specular;
@property (nonatomic) float shininess;

// Texture
@property (nonatomic, strong) id<MTLTexture> texture;

// Whether to use texture or flat color
@property (nonatomic, readonly) BOOL hasTexture;

// Get GPU-ready struct
- (MaterialUniforms) uniforms;

// Factories
+ (instancetype) materialWithColor:(simd_float4)color;

+ (instancetype) materialWithTexture:(NSString *) textureName
                              device:(id<MTLDevice>) device;

+ (instancetype) defaultMaterial;

@end
