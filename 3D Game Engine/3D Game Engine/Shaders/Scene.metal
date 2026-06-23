//
//  Scene.metal
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/20/25.
//

#include <metal_stdlib>
using namespace metal;

#include "ShaderTypes.h"
#include "Phong.metal"

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float4 worldPos;
    float4 normal;
    float2 uv;
};

vertex VertexOut vertexShader(uint vertexID [[vertex_id]],
                              uint instanceID [[instance_id]],
                              constant Vertex *vertices [[buffer(VertexBufferIndexForVertexData)]],
                              constant CameraUniforms *uniforms [[buffer(VertexBufferIndexForCameraUniforms)]],
                              constant float4x4 *instanceMatrices [[buffer(VertexBufferIndexForModelMatrices)]]) {
    VertexOut out;
    float4x4 model = instanceMatrices[instanceID];
    float4 worldPos = model * float4(vertices[vertexID].position.xyz, 1.0);
    out.worldPos = worldPos;
    out.position = uniforms->projectionMatrix * uniforms->viewMatrix * worldPos;
    out.normal = model * vertices[vertexID].normal;
    out.uv = vertices[vertexID].uv;
    out.color = vertices[vertexID].color;
    return out;
}
fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               texture2d<float> tex [[texture(0)]],
                               sampler samp [[sampler(0)]],
                               constant LightUniforms* lightUniforms [[buffer(FragmentBufferIndexForLightUniforms)]],
                               constant MaterialUniforms* materialUniforms [[buffer(FragmentBufferIndexForMaterialUniforms)]],
                               constant CameraUniforms* cameraUniforms [[buffer(FragmentBufferIndexForCameraUniforms)]])
{
    float4 texColor = tex.sample(samp, in.uv);
      
    float3 lit = Phong::getPhongLighting(
        lightUniforms,
        materialUniforms,
        cameraUniforms->position.xyz,
        in.worldPos.xyz,
        normalize(in.normal.xyz),
        texColor.xyz
    );

    // Fog
    float3 skyColor = float3(0.678, 1.0, 0.984); // match your clear color
    float dist = distance(cameraUniforms->position.xyz, in.worldPos.xyz);
    float fogStart = 50.0;
    float fogEnd   = 200.0;
    float fogFactor = clamp((dist - fogStart) / (fogEnd - fogStart), 0.0, 1.0);

    float3 finalColor = mix(lit, skyColor, fogFactor);
    return float4(finalColor, 1.0);

}

