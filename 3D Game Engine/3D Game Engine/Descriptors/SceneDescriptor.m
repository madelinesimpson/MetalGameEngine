//
//  SceneDescriptor.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 5/25/26.
//

#include "SceneDescriptor.h"

@implementation SceneDescriptor

- (instancetype) init {
    if (self = [super init]) {
        _rootObjects = [NSMutableArray array];
        _lights = [NSMutableArray array];
    }
    
    return self;
}

@end
