//
//  ShaderTypes.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/20/25.
//

// Define structs used by both CPU and GPU

#ifndef ShaderTypes_h
#define ShaderTypes_h

#import <simd/simd.h>

typedef enum VertexInputBufferIndex {
    VertexBufferIndexForVertexData = 0,
    VertexBufferIndexForCameraUniforms = 1,
} VertexInputBufferIndex;

typedef enum FragmentInputBufferIndex {
    FragmentBufferIndexForLightUniforms = 0,
    FragmentBufferIndexForMaterialUniforms = 1,
    FragmentBufferIndexForCameraUniforms = 2,
    FragmentBufferIndexForObjectUniforms = 3,
} FragmentInputBufferIndex;

typedef struct {
    simd_float4 position;
    simd_float4 normal;
    simd_float2 uv;
    simd_float4 color;
} Vertex;

typedef struct {
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 modelMatrix;
    simd_float4 position;
} CameraUniforms;

typedef struct {
    simd_float4 color;
} ObjectUniforms;

typedef struct {
    simd_float4 position;
    simd_float4 direction;
    simd_float4 ambient;
    simd_float4 diffuse;
    simd_float4 specular;
} LightUniforms;

typedef struct {
    simd_float4 ambient;
    simd_float4 diffuse;
    simd_float4 specular;
    simd_float4 shininess;
} MaterialUniforms;

#endif
