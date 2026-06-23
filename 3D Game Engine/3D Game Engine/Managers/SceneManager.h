//
//  SceneManager.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 5/25/26.
//


#ifndef SCENEMANAGER_H
#define SCENEMANAGER_H

#import <MetalKit/MetalKit.h>
#import "Scene.h"
#import "GameObject.h"
#import "Light.h"
#import "SceneDescriptor.h"

@interface SceneManager:NSObject

@property (nonatomic) Scene* scene;

- (void)addObject:(GameObject *)object;
- (void)addObject:(GameObject *)object
       withParent:(GameObject *)parent;
- (void)addLight:(Light *)light;
- (void)setSkybox:(GameObject *)skybox;
- (void)submit:(Scene *)scene;

@end

#endif
