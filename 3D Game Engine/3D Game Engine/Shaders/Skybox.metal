//
//  Skybox.metal
//  3D Game Engine
//
//  Created by Madeline Simpson on 5/10/26.


#include <metal_stdlib>
using namespace metal;

#include "ShaderTypes.h"

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float4 worldPos;
    float4 normal;
    float2 uv;
};

vertex VertexOut skyboxVertex(uint vertexID [[vertex_id]],
                              constant Vertex *vertices [[buffer(0)]],
                              constant CameraUniforms *uniforms [[buffer(1)]]) {
    
    VertexOut out;
    float4x4 viewMatrix = uniforms->viewMatrix;
    viewMatrix.columns[3] = float4(0, 0, 0, 1);
    float4 worldPos = vertices[vertexID].position * 100.0f;
    float4 clipPos = uniforms->projectionMatrix * viewMatrix * worldPos;
    out.position = clipPos.xyww;
    out.normal = vertices[vertexID].normal;
    out.uv = vertices[vertexID].uv;
    out.color = float4(166.0/255.0, 254.0/255.0, 255.0/255.0, 1.0);
    
    return out;
}

fragment float4 skyboxFragment(VertexOut in [[stage_in]]) {
    return in.color;
}
