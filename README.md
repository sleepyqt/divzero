# DivZero
A simple vector math library for computer graphics.

## Features
+ *vec2*, *mat3* - 2d vector and transformation matrix
+ *vec4*, *mat4* - 3d homogeneous vector and transformation matrix
+ *shapes2* - various 2d shapes (Circles, Segments, AABB, ConvexHull ...), with functions for checking overlaps and raycasting
+ *aabb3* - 3d axis-aligned bounding box
+ syntax similar to *glsl*

## Examples
### 2d vectors
```nim
import divzero / [vec2, mat3]

let a = vec2(1f, 2f) # (1, 2) vector
let m = mat3T(10f, 20f) # build translation matrix
echo m * a # (11, 22)
echo mat3T(1f, 2f) * mat3R(1f) * mat3S(0.5f) * vec2(1, 2) # scale rotate and translate vector
```
### shapes
```nim
import divzero / [shapes2, vec2]
let a = circle(0f, 0f, 1f) # circle at (0, 0) with radius 1f
let b = circle(1f, 0f, 1f)
echo overlaps(a, b) # true
var manifold: CollisionInfo
overlaps(a, b, manifold)
echo manifold # (hit: true, normal: (x: -1.0, y: 0.0), depth: 1.0)
```
### 3d
```nim
import divzero / [mat4, vec4]

let P = persp(45f, 4f / 3f, 0.1f, 100f)
let V = viewLookAt(vec4(4f, 3f, 3f, 1f), vec4(1f, 2f, 3f, 1f), vec4(0f, 1f, 0f, 0f))
let M = mat4T(vec4(1f, 2f, 3f, 0f)) * mat4RZ(0.5f) * mat4S(vec4(2f, 2f, 2f, 0f))
let PVM = P * V * M * vec4(0f, 0f, 0f, 1f)
```

## License
Licensed under the MIT license. [LICENSE](LICENSE)
