//
//  SceneManager.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 5/25/26.
//

#import "SceneManager.h"

@implementation SceneManager {
    SceneDescriptor* _sceneDescriptor;
}

- (instancetype) init {
    if (self = [super init]) {
        _sceneDescriptor = [SceneDescriptor new];
    }
    
    return self;
}


- (void)addObject:(GameObject *)object {
    NSAssert(object.parent == nil, @"Only add root objects using addObject. Use addObject:withParent: for children");
    [_sceneDescriptor.rootObjects addObject:object];
}

- (void)addObject:(GameObject *)object
       withParent:(GameObject *)parent {
    [parent addChild:object];
}

- (void)addLight:(Light *)light {
    [_sceneDescriptor.lights addObject:light];
}

- (void)setSkybox:(GameObject *)skybox {
    _sceneDescriptor.skybox = skybox;
}

- (void)submit:(Scene*) scene {
    self.scene = scene;
    self.scene.skybox = _sceneDescriptor.skybox;
    [self.scene.lights addObjectsFromArray:_sceneDescriptor.lights];
    [self.scene.gameObjects addObjectsFromArray:_sceneDescriptor.rootObjects];

    _sceneDescriptor = [SceneDescriptor new];
}

@end

