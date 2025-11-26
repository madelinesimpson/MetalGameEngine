//
//  PrimitiveData.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/16/25.
//

#ifndef PrimitiveData_h
#define PrimitiveData_h

#include "ShaderTypes.h"

void makeTriangle(simd_float3 vertex1,
                  simd_float3 vertex2,
                  simd_float3 vertex3,
                  Vertex* outVerts);

#endif
