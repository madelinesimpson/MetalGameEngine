//
//  Shaders.metal
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/20/25.
//

#include <metal_stdlib>
using namespace metal;

#include "ShaderTypes.h"
#include "PhongShading.metal"

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float4 worldPos;
    float4 normal;
    float2 uv;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]],
                              constant Vertex *vertices [[buffer(VertexBufferIndexForVertexData)]],
                              constant CameraUniforms *uniforms [[buffer(VertexBufferIndexForCameraUniforms)]]) {
    
    VertexOut out;
    
    out.color = vertices[vertexID].color;
    out.normal = uniforms->modelMatrix * vertices[vertexID].normal;

    float4 worldPos = uniforms->modelMatrix * float4(vertices[vertexID].position.xyz, 1.0);
    out.worldPos = worldPos;
    out.position = uniforms->projectionMatrix * uniforms->viewMatrix * worldPos;
    
    out.uv = vertices[vertexID].uv;
    
    return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               texture2d<float> tex [[texture(0)]],
                               sampler samp [[sampler(0)]],
                               constant LightUniforms* lightUniforms [[buffer(FragmentBufferIndexForLightUniforms)]],
                               constant MaterialUniforms* materialUniforms [[buffer(FragmentBufferIndexForMaterialUniforms)]],
                               constant CameraUniforms* cameraUniforms [[buffer(FragmentBufferIndexForCameraUniforms)]],
                               constant ObjectUniforms* objectUniforms [[buffer(FragmentBufferIndexForObjectUniforms)]])
{
    
    float4 texColor = tex.sample(samp, in.uv);
    
    float3 lit = PhongShading::getPhongLighting(
          lightUniforms,
          materialUniforms,
          cameraUniforms->position.xyz,
          in.worldPos.xyz,
          normalize(in.normal.xyz),
          texColor.xyz
      );

      return float4(lit, 1.0);

}

