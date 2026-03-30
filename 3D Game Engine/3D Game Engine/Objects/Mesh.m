//
//  Mesh.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/23/25.
//

#include "Mesh.h"

@implementation Mesh {
    id<MTLDevice> _device;
}

-(instancetype) initWithDevice:(id<MTLDevice>) device
                      vertices:(const Vertex*) vertices
                   vertexCount:(NSUInteger) vertexCount
                       indices:(const uint16_t *) indices
                    indexCount:(NSUInteger) indexCount {
    if (self = [super init]) {
        _device = device;
        _vertexBuffer = [device newBufferWithBytes:vertices
                                            length:sizeof(Vertex) * vertexCount
                                           options:MTLResourceStorageModeShared];
        _vertexCount = vertexCount;
        if (indices && indexCount > 0) {
            _indexBuffer = [device newBufferWithBytes:indices
                                               length:sizeof(uint16_t) * indexCount
                                              options:MTLResourceStorageModeShared];
            _indexCount = indexCount;
        }
    }
    
    return self;
}

// Get the obj file
+ (instancetype)meshFromOBJNamed:(NSString*)name device:(id<MTLDevice>)device {
    NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:@"obj"];
    NSAssert(path, @"OBJ file '%@.obj' not found", name);
    return [Mesh meshFromFile:path device:device];
}

+ (instancetype)meshFromFile:(NSString*)path device:(id<MTLDevice>)device {
    MeshData data = MeshLoader_loadOBJ(path);
    Mesh* mesh = [[Mesh alloc] initWithDevice:device
                                     vertices:data.vertices
                                  vertexCount:data.vertexCount
                                      indices:data.indices
                                   indexCount:data.indexCount];
    MeshLoader_free(&data);
    return mesh;
}

@end
