//
//  Scene.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 4/6/26.
//
#include "Scene.h"
#include "Mesh.h"

@implementation Scene

- (instancetype) initWithDevice:(id<MTLDevice>) device {
    if (self = [super init]) {
        _device = device;
        _camera = [[Camera alloc] init];
        _gameObjects = [NSMutableArray array];
        _lights = [NSMutableArray array];
        _skybox = nil;
    }
    
    return self;
}

- (void)build:(SceneManager *)sceneManager {
    NSAssert(NO, @"Subclass %@ must override build:", [self class]);
}

@end
