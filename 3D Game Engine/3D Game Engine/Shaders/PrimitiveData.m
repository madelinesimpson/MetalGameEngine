//
//  TriangleData.c
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/16/25.
//

#include "PrimitiveData.h"
#include <string.h>

void makeTriangle(simd_float3 vertex1,
                  simd_float3 vertex2,
                  simd_float3 vertex3,
                  Vertex* outVerts)
{
    outVerts[0].position = vertex1;
    outVerts[1].position = vertex2;
    outVerts[2].position = vertex3;
    
    // populate with default values for now
    for (int i = 0; i < 3; i++) {
        outVerts[i].normal = (simd_float3){ 0.0f, 0.0f, 1.0f };
        outVerts[i].uv     = (simd_float2){ 0.0f, 0.0f };
        outVerts[i].color  = (simd_float4){ 1.0f, 0.0f, 0.0f, 1.0f };
    }
}
