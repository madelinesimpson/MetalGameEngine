//
//  SceneDescriptor.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 5/25/26.
//

#ifndef SCENEDESCRIPTOR_H
#define SCENEDESCRIPTOR_H

#import "GameObject.h"
#import "Light.h"

@interface SceneDescriptor:NSObject

@property (nonatomic, strong) NSMutableArray<GameObject *> *rootObjects;
@property (nonatomic, strong) NSMutableArray<Light *> *lights;
@property (nonatomic, strong) GameObject *skybox;

@end

#endif
