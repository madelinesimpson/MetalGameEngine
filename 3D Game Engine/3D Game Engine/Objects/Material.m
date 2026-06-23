//
//  Material.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 4/6/26.
//

#include "Material.h"

@implementation Material {
    
}

- (instancetype) init {
    if (self = [super init]) {
        _color = simd_make_float4(0.5, 0.5, 0.5, 1.0);
        _ambient = 0.3f;
        _diffuse = 1.0f;
        _specular = 0.8f;
        _shininess = 64.0f;
        _texture = nil;
    }
    return self;
}

- (BOOL) hasTexture {
    return _texture != nil;
}

- (MaterialUniforms) uniforms {
    return (MaterialUniforms){
        .ambient = simd_make_float4(_ambient, _ambient, _ambient, 0),
        .diffuse = simd_make_float4(_diffuse, _diffuse, _diffuse, 0),
        .specular = simd_make_float4(_specular, _specular, _specular, 0),
        .shininess = simd_make_float4(_shininess, 0, 0, 0)
    };
}

+ (instancetype) materialWithColor:(simd_float4) color {
    Material *m = [[Material alloc] init];
    m.color = color;
    return m;
}

+ (instancetype) materialWithTexture:(NSString *) textureName
                              device:(id<MTLDevice>) device {
    Material *m = [[Material alloc] init];
    m.texture = [m loadTextureNamed:textureName device:device];
    return m;
}

+ (instancetype) defaultMaterial {
    return [[Material alloc] init];
}

- (id<MTLTexture>) loadTextureNamed:(NSString *) name
                             device:(id<MTLDevice>) device {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSAssert(path, @"Texture '%@' not found", name);
    
    MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:device];
    NSError *error = nil;
    
    id<MTLTexture> texture = [loader newTextureWithContentsOfURL:[NSURL fileURLWithPath:path]
                                                         options:@{MTKTextureLoaderOptionSRGB: @NO, MTKTextureLoaderOptionGenerateMipmaps: @YES}
                                                          error:&error];
    
    NSAssert(texture, @"Failed to load texture: %@", error);
    return texture;
}

@end
