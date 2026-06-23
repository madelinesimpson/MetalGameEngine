
//  PhongShading.metal
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/27/25.


#import "ShaderTypes.h"
using namespace metal;

class Phong {
public:
    static float3 getPhongLighting(constant LightUniforms* lightUniforms,
                                   constant MaterialUniforms* materialUniforms,
                                   float3 eye,
                                   float3 point,
                                   float3 normal,
                                   float3 color) {
        
        float3 l = normalize(lightUniforms->position.xyz);
        float3 v = normalize(eye - point);
        float3 r = reflect(-l, normal);
        
        float3 ambient = materialUniforms->ambient.xyz * lightUniforms->ambient.xyz * color;
        float3 diffuse = color * materialUniforms->diffuse.xyz * lightUniforms->diffuse.xyz * max(dot(normal, l), 0.0);
        float3 specular = materialUniforms->specular.xyz * lightUniforms->specular.xyz * pow(max(dot(v, r), 0.0), materialUniforms->shininess.x);
        
        color = ambient + diffuse + specular;

        return color;
    }
};
