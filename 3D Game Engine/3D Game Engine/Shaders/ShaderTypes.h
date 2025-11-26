//
//  ShaderTypes.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/20/25.
//

#ifndef ShaderTypes_h
#define ShaderTypes_h

#import <simd/simd.h>

typedef enum InputBufferIndex {
    InputBufferIndexForVertexData = 0,
    InputBufferIndexForCameraUniforms = 1,
} InputBufferIndex;

typedef struct {
    simd_float3 position;
    simd_float3 normal;
    simd_float2 uv;
    simd_float4 color;
} Vertex;

typedef struct {
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 modelMatrix;
} CameraUniforms;

#endif
