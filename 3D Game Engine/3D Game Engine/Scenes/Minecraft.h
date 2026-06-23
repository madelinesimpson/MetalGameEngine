//
//  Minecraft.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 5/25/26.
//

#ifndef MINECRAFT_H
#define MINECRAFT_H

#import "Scene.h"
#import "BlockGrid.h"
#import "InputState.h"

@interface Minecraft : Scene

// Ground and player placed cubes live here, separate from the inherited
// gameObjects scene graph, since they're added & removed dynamically
// at runtime (every left/right click)
@property (nonatomic, strong, readonly) BlockGrid *blockGrid;

// Called once per frame with fresh input. Handles camera movement
// (existing behavior) plus left click place / right click delete.
- (void)updateWithInput:(InputState)inputState;

@end

#endif
