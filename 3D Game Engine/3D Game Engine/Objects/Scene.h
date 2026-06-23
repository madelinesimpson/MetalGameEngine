//
//  Scene.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 4/6/26.
//

#ifndef SCENE_H
#define SCENE_H

#import "Camera.h"
#import "Light.h"
#import "ShaderTypes.h"
#import "Cube.h"
#import "Plane.h"

@class SceneManager;

@interface Scene: NSObject

@property (nonatomic, strong) Camera *camera;
@property (nonatomic, strong) NSMutableArray<GameObject *> *gameObjects;
@property (nonatomic, strong) NSMutableArray<Light *> *lights;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) GameObject *skybox;

- (instancetype) initWithDevice:(id<MTLDevice>) device;
- (void) build:(SceneManager *) sceneManager;

@end

#endif
