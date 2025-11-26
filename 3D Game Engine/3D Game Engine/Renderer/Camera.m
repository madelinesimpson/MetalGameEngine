//
//  Camera.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/24/25.
//

#include "Camera.h"
#define PI 3.14159265

@implementation Camera {
    simd_float3 forwardVector;
    simd_float3 rightVector;
}

- (instancetype) init {
    // Set default camera position
    if (self = [super init]) {
        self.position = simd_make_float3(0, 0, 0);
        self.rotation = simd_make_float3(0, 0, 0);
        self.scale = simd_make_float3(1, 1, 1);
        self.near = 0.1f;
        self.far = 1000.0f;
        self.fov = 70.0f;
        
        forwardVector = simd_normalize(simd_make_float3(sin(self.rotation.y) * cos(self.rotation.x), -sin(self.rotation.x), -cos(self.rotation.y) * cos(self.rotation.x)));
        
        rightVector = simd_normalize(simd_make_float3(sin(self.rotation.y + PI*0.5), 0, -cos(self.rotation.y + PI*0.5)));
    }
    
    return self;
}

- (CameraUniforms) getUniforms {
    CameraUniforms cameraUniforms;
    
    // Identity for model matrix
    matrix_float4x4 modelMatrix = matrix_identity_float4x4;
    
    cameraUniforms.modelMatrix = modelMatrix;
    cameraUniforms.projectionMatrix = [self getProjectionMatrix];
    cameraUniforms.viewMatrix = [self getViewMatrix];
    
    return cameraUniforms;
}

- (matrix_float4x4)getViewMatrix {
    matrix_float4x4 viewMatrix = matrix_identity_float4x4;

    viewMatrix= matrix_rotate(viewMatrix, self.rotation.x, simd_make_float3(1,0,0));
    viewMatrix = matrix_rotate(viewMatrix, self.rotation.y, simd_make_float3(0,1,0));
    viewMatrix = matrix_rotate(viewMatrix, self.rotation.z, simd_make_float3(0,0,1));

    // Apply translation (camera at position = view is -position)
    viewMatrix = matrix_translate(viewMatrix, -self.position);
    
    return viewMatrix;
}

- (matrix_float4x4)getProjectionMatrix {
    float aspectRatio = self.aspectRatio;
    
    // Convert degrees to radians
    float fov = (self.fov * PI) / 180;
    float t = tan(fov / 2);
    float x = 1 / (aspectRatio * t);
    float y = 1 / t;
    float z = -((self.far + self.near) / (self.far - self.near));
    float w = ((-2 * self.far * self.near) / (self.far - self.near));
    
    matrix_float4x4 projectionMatrix = {
        simd_make_float4(x, 0, 0, 0),
        simd_make_float4(0, y, 0, 0),
        simd_make_float4(0, 0, z, -1),
        simd_make_float4(0, 0, w, 0)
    };
    
    return projectionMatrix;
}

matrix_float4x4 matrix_rotate(matrix_float4x4 m, float direction, simd_float3 axis) {
    float x = axis.x;
    float y = axis.y;
    float z = axis.z;

    float c = cos(direction);
    float s = sin(direction);
    float mc = 1.0f - c;

    float r1c1 = x * x * mc + c;
    float r1c2 = x * y * mc + z * s;
    float r1c3 = x * z * mc - y * s;
    float r1c4 = 0.0f;

    float r2c1 = y * x * mc - z * s;
    float r2c2 = y * y * mc + c;
    float r2c3 = y * z * mc + x * s;
    float r2c4 = 0.0f;

    float r3c1 = z * x * mc + y * s;
    float r3c2 = z * y * mc - x * s;
    float r3c3 = z * z * mc + c;
    float r3c4 = 0.0f;

    float r4c1 = 0.0f;
    float r4c2 = 0.0f;
    float r4c3 = 0.0f;
    float r4c4 = 1.0f;

    matrix_float4x4 result;

    result.columns[0] = (simd_float4){ r1c1, r1c2, r1c3, r1c4 };
    result.columns[1] = (simd_float4){ r2c1, r2c2, r2c3, r2c4 };
    result.columns[2] = (simd_float4){ r3c1, r3c2, r3c3, r3c4 };
    result.columns[3] = (simd_float4){ r4c1, r4c2, r4c3, r4c4 };

    return matrix_multiply(m, result);
}

matrix_float4x4 matrix_translate(matrix_float4x4 m, simd_float3 position) {
    matrix_float4x4 result;
    
    float x = position.x;
    float y = position.y;
    float z = position.z;
    
    result.columns[0] = (simd_float4){ 1, 0, 0, 0 };
    result.columns[1] = (simd_float4){ 0, 1, 0, 0 };
    result.columns[2] = (simd_float4){ 0, 0, 1, 0 };
    result.columns[3] = (simd_float4){ x, y, z, 1 };
    
    return matrix_multiply(m, result);
}

-(simd_float3) getPosition {
    return self.position;
}

-(simd_float3) getRotation {
    return self.rotation;
}

@end
