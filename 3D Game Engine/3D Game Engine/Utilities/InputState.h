
//
//  InputState.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 3/30/26.
//

#ifndef INPUTSTATE_H
#define INPUTSTATE_H
 
typedef struct {
    bool W;
    bool A;
    bool S;
    bool D;
    float mouseDx;
    float mouseDy;
    bool mouseClicked; // left click (place block)
    bool rightMouseClicked; // right click (delete block)
} InputState;

#endif
