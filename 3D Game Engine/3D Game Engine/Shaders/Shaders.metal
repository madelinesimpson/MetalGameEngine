//
//  Shaders.metal
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/20/25.
//

#include <metal_stdlib>
using namespace metal;

#include "ShaderTypes.h"

struct VertexOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]],
                              constant Vertex *vertices [[buffer(InputBufferIndexForVertexData)]],
                              constant CameraUniforms *uniforms [[buffer(InputBufferIndexForCameraUniforms)]]) {
    
    VertexOut out;
    out.color = vertices[vertexID].color;

    float4 worldPos = uniforms->modelMatrix * float4(vertices[vertexID].position, 1.0);
    out.position = uniforms->projectionMatrix * uniforms->viewMatrix * worldPos;
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]])
{
    if (in.position.x == 0 && in.position.y == 0 && in.position.z == 0) {
        return float4(0.0, 1.0, 0.0, 1.0);
    }
    
    return in.color;
}

