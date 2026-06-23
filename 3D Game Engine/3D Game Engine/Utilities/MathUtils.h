//
//  MathUtils.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 4/6/26.
//
#ifndef MATHUTILS_H
#define MATHUTILS_H

#import <simd/simd.h>

static inline simd_float4x4 translationMatrix(simd_float4 t) {
    simd_float4x4 m = matrix_identity_float4x4;
    m.columns[3] = simd_make_float4(t.x, t.y, t.z, 1.0);
    return m;
}

static inline simd_float4x4 scaleMatrix(simd_float4 s) {
    simd_float4x4 m = matrix_identity_float4x4;
    m.columns[0].x = s.x;
    m.columns[1].y = s.y;
    m.columns[2].z = s.z;
    return m;
}

static inline simd_float4x4 rotationMatrix(simd_float4 r) {
    simd_float4x4 m = matrix_identity_float4x4;
     
     // Rotate around X
     float cx = cosf(r.x), sx = sinf(r.x);
     simd_float4x4 rx = {{
         {1,   0,  0, 0},
         {0,  cx, sx, 0},
         {0, -sx, cx, 0},
         {0,   0,  0, 1}
     }};
     
     // Rotate around Y
     float cy = cosf(r.y), sy = sinf(r.y);
     simd_float4x4 ry = {{
         {cy, 0, -sy, 0},
         { 0, 1,   0, 0},
         {sy, 0,  cy, 0},
         { 0, 0,   0, 1}
     }};
     
     // Rotate around Z
     float cz = cosf(r.z), sz = sinf(r.z);
     simd_float4x4 rz = {{
         { cz, sz, 0, 0},
         {-sz, cz, 0, 0},
         {  0,  0, 1, 0},
         {  0,  0, 0, 1}
     }};
     
     return matrix_multiply(m, matrix_multiply(rz, matrix_multiply(ry, rx)));
}

#endif
