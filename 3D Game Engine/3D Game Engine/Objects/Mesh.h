//
//  Mesh.h
//  3D Game Engine
//
//  Created by Madeline Simpson on 11/23/25.
//
#ifndef Mesh_h
#define Mesh_h

#import <MetalKit/MetalKit.h>
#import "ShaderTypes.h"
#import "MeshLoader.h"

@interface Mesh : NSObject

@property (nonatomic, readonly) id<MTLBuffer> vertexBuffer;
@property (nonatomic, readonly) id<MTLBuffer> indexBuffer;
@property (nonatomic, readonly) NSUInteger vertexCount;
@property (nonatomic, readonly) NSUInteger indexCount;

- (instancetype)initWithDevice:(id<MTLDevice>)device
                      vertices:(const Vertex*)vertices
                   vertexCount:(NSUInteger)vertexCount
                       indices:(const uint16_t*)indices
                    indexCount:(NSUInteger)indexCount;

// File loading
+ (instancetype)meshFromOBJNamed:(NSString*)name device:(id<MTLDevice>)device;
+ (instancetype)meshFromFile:(NSString*)path device:(id<MTLDevice>)device;
+ (instancetype)meshWithVertices:(Vertex *)vertices
                     vertexCount:(NSUInteger)vertexCount
                         indices:(uint32_t *)indices
                      indexCount:(NSUInteger)indexCount
                          device:(id<MTLDevice>)device;

@end

#endif
