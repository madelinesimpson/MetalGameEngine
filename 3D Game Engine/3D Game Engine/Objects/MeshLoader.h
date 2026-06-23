//
//  MeshLoader.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 3/10/26.
//

#ifndef MeshLoader_h
#define MeshLoader_h

#import "ShaderTypes.h"
#import <Foundation/Foundation.h>

typedef struct {
    Vertex*   vertices;
    uint32_t  vertexCount;
    uint32_t* indices;
    uint32_t  indexCount;
} MeshData;

// Load mesh from obj files
MeshData MeshLoader_loadOBJ(NSString* path);
void MeshLoader_free(MeshData* data);

#endif
