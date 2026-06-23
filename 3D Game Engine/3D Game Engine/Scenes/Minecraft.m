//
//  Minecraft.m
//  3D Game Engine
//
//  Created by Madeline Simpson on 5/25/26.
//

#import "Minecraft.h"
#import "SceneManager.h"
#import "RaycastUtil.h"
#import "Cube.h"

static const int kGroundSize = 32;
static const int kGroundY = 0;

// Maximum reach for placing/breaking blocks
static const float kMaxReachDistance = 50.0f;

@implementation Minecraft {
    BlockGrid *_blockGrid;
    Material *_grassMaterial;
}

- (instancetype)initWithDevice:(id<MTLDevice>)device {
    self = [super initWithDevice:device];
    if (self) {
        _blockGrid = [[BlockGrid alloc] init];
    }
    return self;
}

- (BlockGrid *)blockGrid {
    return _blockGrid;
}

- (void)build:(SceneManager *)sceneManager {

    self.camera.position = simd_make_float3(4, 6, 8);
    self.camera.rotation = simd_make_float3(-0.4, 0, 0);

    Light *sun = [Light lightWithPosition:simd_make_float3(0.4, 1.0, 0.3)
                                  ambient:simd_make_float4(0.4, 0.4, 0.4, 0)
                                  diffuse:simd_make_float4(1, 1, 1, 0)
                                 specular:simd_make_float4(0.3, 0.3, 0.3, 0)];

    [sceneManager addLight:sun];

    self.skybox = [[GameObject alloc] init];
    self.skybox.mesh = [Mesh meshFromOBJNamed:@"Skybox" device:self.device];

    [sceneManager setSkybox:self.skybox];

    // Shared material for every ground/placed cube -- loaded once.
    _grassMaterial = [Material materialWithTexture:@"Grass_Block_TEX.png" device:self.device];

    [self generateGroundGrid];

    [sceneManager submit:self];
}

// Fills a flat kGroundSize x kGroundSize plane of cubes at y = kGroundY
- (void)generateGroundGrid {
    int half = kGroundSize / 2;
    for (int x = -half; x < half; x++) {
        for (int z = -half; z < half; z++) {
            simd_int3 coord = simd_make_int3(x, kGroundY, z);
            [_blockGrid placeCubeAtGridCoord:coord
                                      material:_grassMaterial
                                        device:self.device];
        }
    }
}

- (void)updateWithInput:(InputState)inputState {
    if (!self.camera) { return; }

    [self updateCameraWithInput:inputState];
    [self handleBlockInteractionWithInput:inputState];
}

- (void)updateCameraWithInput:(InputState)inputState {
    Camera *camera = self.camera;
    float movementSpeed = 0.15f;
    float rotationSpeed = 0.007f;

    simd_float3 position = [camera getPosition];
    simd_float3 rotation = [camera getRotation];
    float yRot = rotation.y;

    simd_float3 forwardVector = simd_normalize(simd_make_float3(sinf(yRot), 0, -cosf(yRot)));
    simd_float3 rightVector   = simd_normalize(simd_make_float3(cosf(yRot), 0,  sinf(yRot)));

    if (inputState.W) position += forwardVector * movementSpeed;
    if (inputState.S) position -= forwardVector * movementSpeed;
    if (inputState.A) position -= rightVector * movementSpeed;
    if (inputState.D) position += rightVector * movementSpeed;

    [camera setPosition:position];

    float maxRotX = M_PI_2 - 0.01f;
    float xRot = rotation.x - inputState.mouseDy * rotationSpeed;
    yRot += inputState.mouseDx * rotationSpeed;
    xRot = fmaxf(-maxRotX, fminf(maxRotX, xRot));

    [camera setRotation:simd_make_float3(xRot, yRot, 0)];
}

// Place and delete blocks with raycast from center of screen
- (void)handleBlockInteractionWithInput:(InputState)inputState {
    if (!inputState.mouseClicked && !inputState.rightMouseClicked) {
        return;
    }

    Ray ray = RayFromCameraClick(self.camera, 0.0f, 0.0f);
    BlockPickResult pick = PickBlock(ray, _blockGrid);

    if (!pick.didHit) {
        return;
    }

    simd_float3 camPos = [self.camera getPosition];
    simd_float3 hitWorldPos = [BlockGrid worldPositionForGridCoord:pick.hitGridCoord];
    float distance = simd_distance(camPos, hitWorldPos);
    if (distance > kMaxReachDistance) {
        return;
    }

    if (inputState.rightMouseClicked) {
        [_blockGrid removeCubeAtGridCoord:pick.hitGridCoord];
    } else if (inputState.mouseClicked) {
        [_blockGrid placeCubeAtGridCoord:pick.placementGridCoord
                                  material:_grassMaterial
                                    device:self.device];
    }
}

@end
