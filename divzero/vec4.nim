import std / [math]

# --------------------------------------------------------------------------------------------------

type Vec4* = object
  ## Coordinate in projective geometry
  x*, y*, z*, w*: float32

# --------------------------------------------------------------------------------------------------

proc vec4*(x, y, z, w: float32): Vec4 {.inline.} =
  result = Vec4(x: x, y: y, z: z, w: w)


proc vec4*(c: float32): Vec4 {.inline.} =
  ## returns new coordinate with all components set to ``c``
  result = Vec4(x: c, y: c, z: c, w: c)


proc vec4*(): Vec4 {.inline.} =
  ## returns new coordinate with all components set to ``0.0f``
  result = Vec4(x: 0.0f, y: 0.0f, z: 0.0f, w: 0.0f)

# --------------------------------------------------------------------------------------------------

proc xxxx*(v: Vec4): Vec4 {.inline.} =
  ## swizle [1, 2, 3, 4] -> [1, 1, 1, 1]
  result = Vec4(x: v.x, y: v.x, z: v.x, w: v.x)


proc yyyy*(v: Vec4): Vec4 {.inline.} =
  ## swizle [1, 2, 3, 4] -> [2, 2, 2, 2]
  result = Vec4(x: v.y, y: v.y, z: v.y, w: v.y)


proc zzzz*(v: Vec4): Vec4 {.inline.} =
  ## swizle [1, 2, 3, 4] -> [3, 3, 3, 3]
  result = Vec4(x: v.z, y: v.z, z: v.z, w: v.z)


proc wwww*(v: Vec4): Vec4 {.inline.} =
  ## swizle [1, 2, 3, 4] -> [4, 4, 4, 4]
  result = Vec4(x: v.w, y: v.w, z: v.w, w: v.w)


proc xyz0*(v: Vec4): Vec4 {.inline.} =
  ## swizle [1, 2, 3, 4] -> [1, 2, 3, 0]
  result = Vec4(x: v.x, y: v.y, z: v.z, w: 0.0f)


proc xyz1*(v: Vec4): Vec4 {.inline.} =
  ## swizle [1, 2, 3, 4] -> [1, 2, 3, 1]
  result = Vec4(x: v.x, y: v.y, z: v.z, w: 1.0f)

# --------------------------------------------------------------------------------------------------

proc `==`*(a, b: Vec4): bool =
  result = (a.x == b.x) and (a.y == b.y) and (a.z == b.z) and (a.w == b.w)


proc `!=`*(a, b: Vec4): bool =
  result = (a.x != b.x) or (a.y != b.y) or (a.z != b.z) or (a.w != b.w)

# --------------------------------------------------------------------------------------------------

proc `-`*(a: Vec4): Vec4 {.inline.} =
  result = vec4(-a.x, -a.y, -a.z, -a.w)

# --------------------------------------------------------------------------------------------------

proc `+`*(a, b: Vec4): Vec4 {.inline.} =
  ## component wise addition
  result = vec4(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)


proc `-`*(a, b: Vec4): Vec4 {.inline.} =
  ## component wise substraction
  result = vec4(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)


proc `*`*(a, b: Vec4): Vec4 {.inline.} =
  ## component wise multiply
  result = vec4(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w)


proc `/`*(a, b: Vec4): Vec4 {.inline.} =
  ## component wise division
  result = vec4(a.x / b.x, a.y / b.y, a.z / b.z, a.w / b.w)

# --------------------------------------------------------------------------------------------------

proc `+`*(a: Vec4; b: float32): Vec4 {.inline.} =
  result = vec4(a.x + b, a.y + b, a.z + b, a.w + b)


proc `-`*(a: Vec4; b: float32): Vec4 {.inline.} =
  result = vec4(a.x - b, a.y - b, a.z - b, a.w - b)


proc `*`*(a: Vec4; b: float32): Vec4 {.inline.} =
  result = vec4(a.x * b, a.y * b, a.z * b, a.w * b)


proc `/`*(a: Vec4; b: float32): Vec4 {.inline.} =
  result = vec4(a.x / b, a.y / b, a.z / b, a.w / b)

# --------------------------------------------------------------------------------------------------

proc `+`*(a: float32; b: Vec4): Vec4 {.inline.} =
  result = vec4(a + b.x, a + b.y, a + b.z, a + b.w)


proc `-`*(a: float32; b: Vec4): Vec4 {.inline.} =
  result = vec4(a - b.x, a - b.y, a - b.z, a - b.w)


proc `*`*(a: float32; b: Vec4): Vec4 {.inline.} =
  result = vec4(a * b.x, a * b.y, a * b.z, a * b.w)


proc `/`*(a: float32; b: Vec4): Vec4 {.inline.} =
  result = vec4(a / b.x, a / b.y, a / b.z, a / b.w)

# --------------------------------------------------------------------------------------------------

proc dot*(a, b: Vec4): float32 =
  ## returns the dot product of two vectors
  result = (a.x * b.x) + (a.y * b.y) + (a.z * b.z) + (a.w * b.w)


proc cross*(a, b: Vec4): Vec4 =
  ## returns the cross product of two vectors
  result.x = a.y * b.z - b.y * a.z
  result.y = a.z * b.x - b.z * a.x
  result.z = a.x * b.y - b.x * a.y
  result.w = 0.0f

# --------------------------------------------------------------------------------------------------

proc min*(a, b: Vec4): Vec4 {.inline.} =
  result.x = min(a.x, b.x)
  result.y = min(a.y, b.y)
  result.z = min(a.z, b.z)
  result.w = min(a.w, b.w)


proc max*(a, b: Vec4): Vec4 {.inline.} =
  result.x = max(a.x, b.x)
  result.y = max(a.y, b.y)
  result.z = max(a.z, b.z)
  result.w = max(a.w, b.w)

# --------------------------------------------------------------------------------------------------

proc len*(v: Vec4): float32 =
  let x2: float32 = v.x * v.x
  let y2: float32 = v.y * v.y
  let z2: float32 = v.z * v.z
  let a:  float32 = x2 + y2 + z2
  result = sqrt(a)


proc len_sq*(v: Vec4): float32 =
  result = v.x * v.x + v.y * v.y + v.z * v.z

# --------------------------------------------------------------------------------------------------

proc normalize*(v: var Vec4) =
  let m = v.len()
  v = Vec4(x: v.x / m, y: v.y / m, z: v.z / m, w: 0.0f)


proc normalize*(v: Vec4): Vec4 =
  let m = v.len()
  result = vec4(v.x / m, v.y / m, v.z / m, 0.0f)

# --------------------------------------------------------------------------------------------------

proc distance*(start, goal: Vec4): float32 =
  result = len(start - goal)


proc reflect*(incident, normal: Vec4): Vec4 =
  ## returns the reflection direction for an incident vector
  ## ``normal`` surface normal vector
  ## ``incident`` incident vector
  ## ``normal`` should be normalized in order to achieve the desired result
  result = incident - 2.0f * dot(normal, incident) * normal


proc refract*(incident, normal: Vec4; eta: float32): Vec4 =
  ## returns the refraction direction for an incident vector
  ## ``normal`` surface normal vector
  ## ``incident`` incident vector
  ## ``eta`` ratio of indices of refraction
  var k: float32 = 1.0f - eta * eta * (1.0f - dot(normal, incident) * dot(normal, incident))
  if k < 0.0f: vec4() else: eta * incident - (eta * dot(normal, incident) + sqrt(k)) * normal


proc direction*(a, b: Vec4): Vec4 =
  result = normalize(b - a)


proc clamp*(v, min, max: Vec4): Vec4 =
  result.x = clamp(v.x, min.x, max.x)
  result.y = clamp(v.y, min.y, max.y)
  result.z = clamp(v.z, min.z, max.z)
  result.w = clamp(v.w, min.w, max.w)


proc saturate*(a: Vec4): Vec4 =
  result = clamp(a, vec4(0, 0, 0, 0), vec4(1, 1, 1, 1))

# --------------------------------------------------------------------------------------------------

proc cos*(a: Vec4): Vec4 =
  result.x = cos(a.x)
  result.y = cos(a.y)
  result.z = cos(a.z)
  result.w = cos(a.w)


proc sin*(a: Vec4): Vec4 =
  result.x = sin(a.x)
  result.y = sin(a.y)
  result.z = sin(a.z)
  result.w = sin(a.w)


proc tan*(a: Vec4): Vec4 =
  result.x = tan(a.x)
  result.y = tan(a.y)
  result.z = tan(a.z)
  result.w = tan(a.w)


proc abs*(a: Vec4): Vec4 =
  result.x = abs(a.x)
  result.y = abs(a.y)
  result.z = abs(a.z)
  result.w = abs(a.w)


proc floor*(a: Vec4): Vec4 =
  result.x = floor(a.x)
  result.y = floor(a.y)
  result.z = floor(a.z)
  result.w = floor(a.w)


proc ceil*(a: Vec4): Vec4 =
  result.x = ceil(a.x)
  result.y = ceil(a.y)
  result.z = ceil(a.z)
  result.w = ceil(a.w)


proc trunc*(a: Vec4): Vec4 =
  result.x = trunc(a.x)
  result.y = trunc(a.y)
  result.z = trunc(a.z)
  result.w = trunc(a.w)


proc round*(a: Vec4): Vec4 =
  result.x = round(a.x)
  result.y = round(a.y)
  result.z = round(a.z)
  result.w = round(a.w)

# --------------------------------------------------------------------------------------------------

proc to_cartesian*(a: Vec4): Vec4 =
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

