# 3D Game Engine

A small Metal based 3D game engine for macOS, built around a scene graph, a Phong shaded instanced renderer, and a block grid (left click to place, right click to delete like Minecraft).

---

## Requirements

- macOS with Metal support
- Xcode (AppKit + MetalKit; this project is **macOS only**)

## Running it

Open `3D Game Engine.xcodeproj` in Xcode and run. You should see a flat grass block grid stretching out toward the horizon, with a crosshair fixed at the center of the screen.

**Controls:**

| `W` `A` `S` `D` | Move the camera |
| Mouse movement | Look around (mouse look) |
| Left click | Place a block on the face you're looking at |
| Right click | Delete the block you're looking at |

---

## How it works

At a high level, one frame of this engine goes:

1. **`MetalKitViewDelegate`** gets called by MetalKit once per frame (`drawInMTKView:`).
2. It reads the current **`InputState`** from `MetalView` (keys held, mouse movement, click flags).
3. It hands that input to **`Renderer.updateWithInput:`**, which forwards it to **`Minecraft.updateWithInput:`**. This is where the camera moves and where left/right clicks get resolved into block placement/deletion.
4. It calls **`Renderer.renderFrameToView:`**, which walks the scene and issues the actual Metal draw calls.

Everything else in the project supports one of those four steps

---

## Project structure

```
3D Game Engine/
├── App/                entry point, view controller, crosshair overlay
├── Descriptors/        plain data containers passed between scene building objects
├── Managers/           SceneManager - the way scenes get populated with objects
├── Objects/            the scene graph object hierarchy (GameObject, Cube, Camera, Light, Material, Mesh, Collider, BlockGrid)
├── Renderer/           Metal setup, per frame draw loop, input plumbing
├── Resources/          Meshes (.obj), Textures (.png) used by Material/Mesh
├── Scenes/             concrete Scene subclasses (currently just Minecraft but you can make your own scene)
├── Shaders/            .metal shader source + the CPU/GPU-shared struct definitions
└── Utilities/          InputState, MathUtils, RaycastUtil (small stateless helpers)
```

### App/

- **`main`** — process entry point.
- **`Main`** (storyboard/xib) — the window/view hierarchy.
- **`ViewController`** — creates the `MTKView`, assigns a Metal device, creates the `MetalKitViewDelegate`, and adds the `CrosshairView` overlay. Also makes the Metal view the first responder so it receives keyboard events.
- **`CrosshairView`** — draws the fixed center-screen crosshair.

### Descriptors/

- **`SceneDescriptor`** — a plain data object (`rootObjects`, `lights`, `skybox`) that `SceneManager` builds up while a `Scene` is constructing itself, before that data gets handed off to the renderer. Sort of a staging area between "a Scene built some stuff" and "the Renderer can draw it."

### Managers/

- **`SceneManager`** — the only API a `Scene` subclass uses to populate itself with stuff: `addObject:`, `addObject:withParent:`, `addLight:`, `setSkybox:`, and finally `submit:` to hand the finished scene off. Keeping this as the single entry point means `Scene` subclasses never touch rendering internals directly.

### Objects/

Things you can put in your scene

- **`GameObject`** — base class for anything placeable in the world. Holds `position`/`rotation`/`scale`, a `mesh`, a `material`, an optional `collider`, and a `children` array (objects can be parented to other objects; world transforms compose recursively via `getWorldMatrix`). Subclasses override `buildMesh:` and `buildCollider` to supply their actual geometry/collision shape.
- **`Cube`** — a `GameObject` whose mesh is the `Cube.obj` resource. Note the mesh is **2×2×2 units** at `scale = (1,1,1)`, not a 1-unit cube — this matters anywhere you're reasoning about world-space sizes (see `BlockGrid`'s `kVoxelSize`).
- **`Plane`** — a flat quad `GameObject`, used for simple ground/backdrop geometry outside the voxel system.
- **`Camera`** — a standalone object holding `position`/`rotation`/`scale`/`fov`/`near`/`far`/`aspectRatio`, with `getViewMatrix`, `getProjectionMatrix`, and `getUniforms` (packages everything into the GPU-ready `CameraUniforms` struct).
- **`Light`** — a simple point/directional light source (position + ambient/diffuse/specular color), packaged into `LightUniforms` for the shader.
- **`Material`** — shading parameters (ambient/diffuse/specular/shininess, flat `color` or a `texture`), packaged into `MaterialUniforms`. Materials aren't tied to a single object. The same `Material` instance (e.g. the shared grass material) can be reused across many cubes to avoid redundant texture loads.
- **`Mesh`** — wraps a Metal vertex/index buffer pair. Can be loaded from an `.obj` (`meshFromOBJNamed:device:`) or built directly from vertex/index arrays (`meshWithVertices:`).
- **`Collider`** — axis aligned box collider (`center` + `size`) with `intersectsRay:hit:` for ray-box intersection, returning a `RayHit` (point, normal, distance). This is what makes block picking possible (see `RaycastUtil` below.)
- **`BlockGrid`** — tracks every placed/ground cube by **integer grid coordinate** in a dictionary, rather than a flat list, so lookup/place/remove are all O(1) instead of an O(n) scan. World position to grid coordinate conversion and vice versa is handled by `+gridCoordForWorldPosition:` / `+worldPositionForGridCoord:`, using a fixed `kVoxelSize` (currently `2.0`, matching the Cube mesh's real size). `BlockGrid` is intentionally separate from the `GameObject` scene graph (`gameObjects`/`children`) because cubes here are added and removed constantly at runtime, unlike the rest of the scene.

### Renderer/

- **`Renderer`** — owns the Metal pipeline state, depth/stencil state, sampler, and per-frame uniform buffers. `renderFrameToView:` is the actual draw loop: it uploads camera/light uniforms, draws the skybox first (inverted winding, no depth write), then draws every object in the scene — both the static `gameObjects` graph and `minecraft.blockGrid.allCubes` — grouped and instanced by shared mesh, so e.g. all     ground cubes render in a single instanced draw call rather than one draw call each.
- **`MetalKitViewDelegate`** — the `MTKViewDelegate`. Creates the `Renderer` and the `Minecraft` scene once (`initWithMetalKitView:`), then every frame: reads input from the view, forwards it to the renderer, and tells the renderer to draw.
- **`MetalView`** — the `MTKView` subclass that actually captures input: `keyDown:`/`keyUp:` for WASD, `mouseMoved:` for look deltas, `mouseDown:`/`rightMouseDown:` for click flags. Packages all of it into an `InputState` struct each frame via `getInputState`, which also resets the per-frame deltas/flags after reading them.

### Resources/

- **`Meshes/`** — `.obj` files (`Cube`, `Skybox`) loaded via `Mesh.meshFromOBJNamed:`.
- **`Textures/`** — `.png` files (`Grass_Block_TEX`, `Grass_Block_Top_TEX`) loaded via `Material.materialWithTexture:`.

### Scenes/

- **`Minecraft`** — a `Scene` subclass (`Scene` itself lives in this folder structure conceptually, declared with `camera`/`gameObjects`/`lights`/`device`/`skybox` and an `initWithDevice:` you inherit). `Minecraft` overrides `initWithDevice:` to additionally create its `BlockGrid`, and overrides `build:` to set up the camera, sun light, skybox, generate the ground grid, and submit everything through the `SceneManager`. `updateWithInput:` is where per-frame camera movement and click-driven block placement/deletion both happen.

  Want a different scene? Subclass `Scene` the same way `Minecraft` does, then change `MetalKitViewDelegate.initWithMetalKitView:` to instantiate your subclass instead.

### Shaders/

- **`ShaderTypes.h`** — struct definitions shared between Swift/Obj-C and Metal shader code (`Vertex`, `CameraUniforms`, `LightUniforms`, `MaterialUniforms`) plus the buffer-index enums that keep CPU-side `setVertexBuffer:atIndex:` calls and GPU-side `[[buffer(N)]]` attributes in sync.
- **`Scene.metal`** — the main `vertexShader`/`fragmentShader` pair. Vertex shader transforms by the per-instance model matrix (via instancing, indexed by `instance_id`); fragment shader applies Phong lighting (see `Phong.metal`) and a distance-based fog blend toward the sky color, so distant geometry fades out instead of hard-clipping.
- **`Phong.metal`** — the actual Phong lighting math, factored out so `Scene.metal` just calls into it.
- **`Skybox.metal`** — vertex/fragment pair for the skybox, drawn with inverted culling and no depth write so it always sits "behind" everything else.

### Utilities/

- **`InputState`** — plain C struct (not a class) describing one frame's input: WASD bools, mouse deltas, and `mouseClicked`/`rightMouseClicked` flags with the click's NDC coordinates. Built fresh every frame by `MetalView.getInputState`.
- **`MathUtils`** — matrix helpers (`translationMatrix`, `rotationMatrix`, `scaleMatrix`, etc.) used by `GameObject.getModelMatrix` and elsewhere.
- **`RaycastUtil`** — turns a click into a placed/deleted block. `RayFromCameraClick` unprojects a click (in NDC space) through the camera's inverse view-projection matrix into a world-space ray. `PickVoxel` sweeps every cube in a `BlockGrid`, finds the closest one the ray intersects (via each cube's `Collider`), and returns both the grid coordinate that was hit and the adjacent empty cell — the one just outside the face you clicked — where a new block should go if you place one.

  Note: because this is a mouse-look game (cursor hidden/locked), block interaction always raycasts from screen center (NDC `0, 0`) — i.e. straight down the crosshair — rather than from the actual OS cursor position, which is irrelevant here.

---

## To build a new scene

Subclass `Scene`, override `build:` to populate it via `SceneManager`, then point `MetalKitViewDelegate` at your subclass instead of `Minecraft`.
