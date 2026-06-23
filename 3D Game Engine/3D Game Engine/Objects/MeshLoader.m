//
//  MeshLoader.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 3/10/26.
//

#import "MeshLoader.h"

// Calculate normals for each face
static void computeNormals(Vertex* verts, int count) {
    // Zero out all normals first
    for (int i = 0; i < count; i++) {
        verts[i].normal = simd_make_float4(0, 0, 0, 0);
    }

    // Get vertices for a face
    for (int i = 0; i < count; i += 3) {
        simd_float3 a = verts[i].position.xyz;
        simd_float3 b = verts[i+1].position.xyz;
        simd_float3 c = verts[i+2].position.xyz;
        
        // Cross product two vectors between vertices
        simd_float3 normal = simd_normalize(simd_cross(b - a, c - a));
        
        // Add normal to vertex struct
        verts[i].normal   += simd_make_float4(normal, 0);
        verts[i+1].normal += simd_make_float4(normal, 0);
        verts[i+2].normal += simd_make_float4(normal, 0);
    }
    
    // Normalize normals
    for (int i = 0; i < count; i++) {
        verts[i].normal = simd_make_float4(simd_normalize(verts[i].normal.xyz), 0);
    }
}

// Parse OBJ files
MeshData MeshLoader_loadOBJ(NSString* path) {
    NSString* contents = [NSString stringWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
    // Max amount of mesh vertices
    int maxElems = 65536;
    simd_float3* positions = malloc(sizeof(simd_float3) * maxElems);
    simd_float3* normals = malloc(sizeof(simd_float3) * maxElems);
    simd_float2* uvs = malloc(sizeof(simd_float2) * maxElems);
    int posCount = 0, normCount = 0, uvCount = 0;

    typedef struct {
        int p, t, n;
    } OBJIndex;
    
    OBJIndex* faces = malloc(sizeof(OBJIndex) * maxElems * 3);
    int faceCount = 0;
    
    // OBJ FILES: v (vertex), vt (uvs), vn (vertex normals), f (faces), l (lines)
    // Go line by line and parse info
    for (NSString* line in [contents componentsSeparatedByString:@"\n"]) {
        const char* l = [line UTF8String];
        // If line is blank continue
        if (!l) continue;

        if (strncmp(l, "v ", 2) == 0) {  // Vertex
            float x, y, z;
            sscanf(l+2, "%f %f %f", &x, &y, &z);
            positions[posCount++] = simd_make_float3(x, y, z);
        } else if (strncmp(l, "vn ", 3) == 0) { // Vertex normal
            float x, y, z;
            sscanf(l+3, "%f %f %f", &x, &y, &z);
            normals[normCount++] = simd_make_float3(x, y, z);
        } else if (strncmp(l, "vt ", 3) == 0) { // UV coord
            float u, v;
            sscanf(l+3, "%f %f", &u, &v);
            uvs[uvCount++] = simd_make_float2(u, 1.0f - v); // flip V for Metal
        } else if (strncmp(l, "f ", 2) == 0) { // Face
            OBJIndex face[4];
            int count = 0;
            const char* ptr = l + 2;
            while (*ptr && count < 4) {
                int p=0, t=0, n=0;
                int consumed = 0;
                if (sscanf(ptr, "%d/%d/%d%n", &p,&t,&n,&consumed) == 3) {
                    face[count++] = (OBJIndex){p-1,t-1,n-1};
                }
                else if (sscanf(ptr, "%d//%d%n", &p,&n,&consumed) == 2) {
                    face[count++] = (OBJIndex){p-1,-1,n-1};
                }
                else if (sscanf(ptr, "%d/%d%n", &p,&t,&consumed) == 2) {
                    face[count++] = (OBJIndex){p-1,t-1,-1};
                }
                else if (sscanf(ptr, "%d%n", &p,&consumed) == 1) {
                    face[count++] = (OBJIndex){p-1,-1,-1};
                }
                else break;
                
                ptr += consumed;
                while (*ptr == ' ') ptr++;
            }
            // Fan triangulation (handles quads)
            for (int i = 1; i < count-1; i++) {
                faces[faceCount*3+0] = face[0];
                faces[faceCount*3+1] = face[i];
                faces[faceCount*3+2] = face[i+1];
                faceCount++;
            }
        }
    }

    int totalVerts = faceCount * 3;
    Vertex* outVerts = malloc(sizeof(Vertex) * totalVerts);
    uint32_t* outIndices = malloc(sizeof(uint32_t) * totalVerts);

    for (int i = 0; i < totalVerts; i++) {
        OBJIndex idx = faces[i];
        outVerts[i].position = simd_make_float4(positions[idx.p], 1.0f);
        outVerts[i].normal = simd_make_float4(idx.n >= 0 ? normals[idx.n] : simd_make_float3(0,1,0), 0.0f);
        
        if (idx.t >= 0 && uvCount > 0) {
            outVerts[i].uv = uvs[idx.t];
        } else {
            simd_float3 n = simd_normalize(positions[idx.p]);
            outVerts[i].uv = simd_make_float2(
                atan2f(n.x, n.z) / (2.0f * M_PI) + 0.5f,
                n.y * 0.5f + 0.5f
            );
        }
        
        outVerts[i].color = simd_make_float4(1, 1, 1, 1);
        outIndices[i] = (uint32_t) i;
    }
    
    // If obj file doesn't have normals, calculate them
    if (normCount == 0) {
        computeNormals(outVerts, totalVerts);
    }
    
    free(positions); free(normals); free(uvs); free(faces);
    return (MeshData){ outVerts, totalVerts, outIndices, totalVerts };
}

void MeshLoader_free(MeshData* data) {
    free(data->vertices);
    free(data->indices);
    data->vertices = NULL;
    data->indices  = NULL;
}


