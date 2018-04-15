import std / [math]

# --------------------------------------------------------------------------------------------------

type Vec4* = object
  ## Homogeneous vector with four components.
  x*, y*, z*, w*: float32

# --------------------------------------------------------------------------------------------------

func vec4*(x, y, z, w: float32): Vec4 {.inline.} =
  ## returns vector with components set to [``x``, ``y``, ``z``, ``w``]
  result = Vec4(x: x, y: y, z: z, w: w)


func vec4*(c: float32): Vec4 {.inline.} =
  ## returns vector with all components set to ``c``
  result = Vec4(x: c, y: c, z: c, w: c)


func vec4*(): Vec4 {.inline.} =
  ## returns vector with all components set to ``0.0f``
  result = Vec4(x: 0.0f, y: 0.0f, z: 0.0f, w: 0.0f)

# --------------------------------------------------------------------------------------------------

func xxxx*(v: Vec4): Vec4 {.inline.} =
  ## returns swizzled vector [x, y, z, w] -> [x, x, x, x]
  result = Vec4(x: v.x, y: v.x, z: v.x, w: v.x)


func yyyy*(v: Vec4): Vec4 {.inline.} =
  ## returns swizzled vector [x, y, z, w] -> [y, y, y, y]
  result = Vec4(x: v.y, y: v.y, z: v.y, w: v.y)


func zzzz*(v: Vec4): Vec4 {.inline.} =
  ## returns swizzled vector [x, y, z, w] -> [z, z, z, z]
  result = Vec4(x: v.z, y: v.z, z: v.z, w: v.z)


func wwww*(v: Vec4): Vec4 {.inline.} =
  ## returns swizzled vector [x, y, z, w] -> [w, w, w, w]
  result = Vec4(x: v.w, y: v.w, z: v.w, w: v.w)


func xyz0*(v: Vec4): Vec4 {.inline.} =
  ## returns swizzled vector [x, y, z, w] -> [x, y, z, 0]
  result = Vec4(x: v.x, y: v.y, z: v.z, w: 0.0f)


func xyz1*(v: Vec4): Vec4 {.inline.} =
  ## returns swizzled vector [x, y, z, w] -> [x, y, z, 1]
  result = Vec4(x: v.x, y: v.y, z: v.z, w: 1.0f)

# --------------------------------------------------------------------------------------------------

func `==`*(a, b: Vec4): bool =
  result = (a.x == b.x) and (a.y == b.y) and (a.z == b.z) and (a.w == b.w)


func `!=`*(a, b: Vec4): bool =
  result = (a.x != b.x) or (a.y != b.y) or (a.z != b.z) or (a.w != b.w)

# --------------------------------------------------------------------------------------------------

func `-`*(a: Vec4): Vec4 {.inline.} =
  result = vec4(-a.x, -a.y, -a.z, -a.w)

# --------------------------------------------------------------------------------------------------

func `+`*(a, b: Vec4): Vec4 {.inline.} =
  ## component wise addition
  result = vec4(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)


func `-`*(a, b: Vec4): Vec4 {.inline.} =
  ## component wise substraction
  result = vec4(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)


func `*`*(a, b: Vec4): Vec4 {.inline.} =
  ## component wise multiply
  result = vec4(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w)


func `/`*(a, b: Vec4): Vec4 {.inline.} =
  ## component wise division
  result = vec4(a.x / b.x, a.y / b.y, a.z / b.z, a.w / b.w)

# --------------------------------------------------------------------------------------------------

func `+`*(a: Vec4; b: float32): Vec4 {.inline.} =
  ## scalar addition
  result = vec4(a.x + b, a.y + b, a.z + b, a.w + b)


func `-`*(a: Vec4; b: float32): Vec4 {.inline.} =
  ## scalar substraction
  result = vec4(a.x - b, a.y - b, a.z - b, a.w - b)


func `*`*(a: Vec4; b: float32): Vec4 {.inline.} =
  ## scalar multiply
  result = vec4(a.x * b, a.y * b, a.z * b, a.w * b)


func `/`*(a: Vec4; b: float32): Vec4 {.inline.} =
  ## scalar division
  result = vec4(a.x / b, a.y / b, a.z / b, a.w / b)

# --------------------------------------------------------------------------------------------------

func `+`*(a: float32; b: Vec4): Vec4 {.inline.} =
  result = vec4(a + b.x, a + b.y, a + b.z, a + b.w)


func `-`*(a: float32; b: Vec4): Vec4 {.inline.} =
  result = vec4(a - b.x, a - b.y, a - b.z, a - b.w)


func `*`*(a: float32; b: Vec4): Vec4 {.inline.} =
  result = vec4(a * b.x, a * b.y, a * b.z, a * b.w)


func `/`*(a: float32; b: Vec4): Vec4 {.inline.} =
  result = vec4(a / b.x, a / b.y, a / b.z, a / b.w)

# --------------------------------------------------------------------------------------------------

func dot*(a, b: Vec4): float32 =
  ## returns the dot product of two vectors
  result = (a.x * b.x) + (a.y * b.y) + (a.z * b.z) + (a.w * b.w)


func cross*(a, b: Vec4): Vec4 =
  ## returns a vector that is perpendicular to both vectors.
  ## The magnitude of cross product is area of parallelogram formed by both vectors as sides.
  result.x = a.y * b.z - b.y * a.z
  result.y = a.z * b.x - b.z * a.x
  result.z = a.x * b.y - b.x * a.y
  result.w = 0.0f

# --------------------------------------------------------------------------------------------------

func min*(a, b: Vec4): Vec4 {.inline.} =
  ## component wise `min` function
  result.x = min(a.x, b.x)
  result.y = min(a.y, b.y)
  result.z = min(a.z, b.z)
  result.w = min(a.w, b.w)


func max*(a, b: Vec4): Vec4 {.inline.} =
  ## component wise `max` function
  result.x = max(a.x, b.x)
  result.y = max(a.y, b.y)
  result.z = max(a.z, b.z)
  result.w = max(a.w, b.w)

# --------------------------------------------------------------------------------------------------

func len*(v: Vec4): float32 =
  ## returns length(magnitude) of vector
  let x2: float32 = v.x * v.x
  let y2: float32 = v.y * v.y
  let z2: float32 = v.z * v.z
  let a:  float32 = x2 + y2 + z2
  result = sqrt(a)


func len_sq*(v: Vec4): float32 =
  ## returns squared length of vector
  result = v.x * v.x + v.y * v.y + v.z * v.z

# --------------------------------------------------------------------------------------------------

func normalize*(v: Vec4): Vec4 =
  ## returns vector with same direction as ``v`` and magnitude ``1.0`` (unit vector)
  let im = 1f / v.len
  result = vec4(v.x * im, v.y * im, v.z * im, 0.0f)

# --------------------------------------------------------------------------------------------------

func distance*(a, b: Vec4): float32 =
  ## returns distance between two points
  result = len(a - b)


func reflect*(incident, normal: Vec4): Vec4 =
  ## returns the reflection direction for an incident vector
  ## ``normal`` surface normal vector
  ## ``incident`` incident vector
  ## ``normal`` should be normalized in order to achieve the desired result
  result = incident - 2.0f * dot(normal, incident) * normal


func refract*(incident, normal: Vec4; eta: float32): Vec4 =
  ## returns the refraction direction for an incident vector
  ## ``normal`` surface normal vector
  ## ``incident`` incident vector
  ## ``eta`` ratio of indices of refraction
  var k: float32 = 1.0f - eta * eta * (1.0f - dot(normal, incident) * dot(normal, incident))
  if k < 0.0f: vec4() else: eta * incident - (eta * dot(normal, incident) + sqrt(k)) * normal


func direction*(a, b: Vec4): Vec4 =
  result = normalize(b - a)


func clamp*(v, min, max: Vec4): Vec4 =
  result.x = clamp(v.x, min.x, max.x)
  result.y = clamp(v.y, min.y, max.y)
  result.z = clamp(v.z, min.z, max.z)
  result.w = clamp(v.w, min.w, max.w)


func saturate*(a: Vec4): Vec4 =
  ## returns vector with elements clamped in range [0, 1]
  result = clamp(a, vec4(0, 0, 0, 0), vec4(1, 1, 1, 1))

# --------------------------------------------------------------------------------------------------

func cos*(a: Vec4): Vec4 =
  ## component wise cosine function
  result.x = cos(a.x)
  result.y = cos(a.y)
  result.z = cos(a.z)
  result.w = cos(a.w)


func sin*(a: Vec4): Vec4 =
  ## component wise sine function
  result.x = sin(a.x)
  result.y = sin(a.y)
  result.z = sin(a.z)
  result.w = sin(a.w)


func tan*(a: Vec4): Vec4 =
  result.x = tan(a.x)
  result.y = tan(a.y)
  result.z = tan(a.z)
  result.w = tan(a.w)


func abs*(a: Vec4): Vec4 =
  result.x = abs(a.x)
  result.y = abs(a.y)
  result.z = abs(a.z)
  result.w = abs(a.w)


func floor*(a: Vec4): Vec4 =
  result.x = floor(a.x)
  result.y = floor(a.y)
  result.z = floor(a.z)
  result.w = floor(a.w)


func ceil*(a: Vec4): Vec4 =
  result.x = ceil(a.x)
  result.y = ceil(a.y)
  result.z = ceil(a.z)
  result.w = ceil(a.w)


func trunc*(a: Vec4): Vec4 =
  result.x = trunc(a.x)
  result.y = trunc(a.y)
  result.z = trunc(a.z)
  result.w = trunc(a.w)


func round*(a: Vec4): Vec4 =
  result.x = round(a.x)
  result.y = round(a.y)
  result.z = round(a.z)
  result.w = round(a.w)

# --------------------------------------------------------------------------------------------------

func to_cartesian*(a: Vec4): Vec4 =
  ## converts homogeneous vector to cartesian vector
  assert(a.w != 0.0f)
  result.x = a.x / a.w
  result.y = a.y / a.w
  result.z = a.z / a.w
  result.w = 0.0f

# --------------------------------------------------------------------------------------------------

proc selftest* =
  template check(cond: untyped) =
    if not cond: echo "check fail ", ast_to_str(cond)

  check vec4(0, 0, 0, 0) == vec4(0, 0, 0, 0)
  check vec4(1, 0, 0, 0) != vec4(0, 0, 0, 0)
  check vec4(0, 1, 0, 0) != vec4(0, 0, 0, 0)
  check vec4(0, 0, 1, 0) != vec4(0, 0, 0, 0)
  check vec4(0, 0, 0, 1) != vec4(0, 0, 0, 0)
  check vec4(1, 2, 3, 4) == vec4(1, 2, 3, 4)

  check vec4(4, 3, 2, 1) + vec4(1, 2, 3, 4)     == vec4(5, 5, 5, 5)
  check vec4(4, 3, 2, 1) - vec4(1, 2, 3, 4)     == vec4(3, 1, -1, -3)
  check vec4(1, 2, 3, 4) * vec4(2, 2, 2, 2)     == vec4(2, 4, 6, 8)
  check vec4(2, 4, 6, 8) / vec4(2, 2, 2, 2)     == vec4(1, 2, 3, 4)
  check min(vec4(1, 2, 3, 4), vec4(4, 3, 2, 1)) == vec4(1, 2, 2, 1)
  check max(vec4(1, 2, 3, 4), vec4(4, 3, 2, 1)) == vec4(4, 3, 3, 4)

  check vec4(1, 2, 3, 4).xxxx == vec4(1, 1, 1, 1)
  check vec4(1, 2, 3, 4).yyyy == vec4(2, 2, 2, 2)
  check vec4(1, 2, 3, 4).zzzz == vec4(3, 3, 3, 3)
  check vec4(1, 2, 3, 4).wwww == vec4(4, 4, 4, 4)
  check vec4(1, 2, 3, 4).xyz0 == vec4(1, 2, 3, 0)
  check vec4(1, 2, 3, 4).xyz1 == vec4(1, 2, 3, 1)

  check len(vec4(1, 2, 3, 0)) == sqrt(14.0f)

  check dot(vec4(1, 2, 3, 0), vec4(4, 5, 6, 0)) == 32.0f

  check cross(vec4(1, 2, 3, 0), vec4(4, 5, 6, 0)) == vec4(-3, 6, -3, 0)
  check cross(vec4(1, 0, 0, 0), vec4(0, 1, 0, 0)) == vec4(0, 0, 1, 0)

  check saturate(vec4(10, 0, 3, 1)) == vec4(1, 0, 1, 1)


