import math

# --------------------------------------------------------------------------------------------------

type Vec2* = object
  x*, y*: float32

# --------------------------------------------------------------------------------------------------

proc vec2*(x, y: float32): Vec2 {.inline.} =
  result = Vec2(x: x, y: y)


proc vec2*(c: float32): Vec2 {.inline.} =
  result = Vec2(x: c, y: c)


proc vec2*(): Vec2 {.inline.} =
  result = Vec2(x: 0.0f, y: 0.0f)

# --------------------------------------------------------------------------------------------------

proc xx*(v: Vec2): Vec2 {.inline.} =
  result = Vec2(x: v.x, y: v.x)


proc yy*(v: Vec2): Vec2 {.inline.} =
  result = Vec2(x: v.y, y: v.y)

# --------------------------------------------------------------------------------------------------

proc `==`*(a, b: Vec2): bool =
  result = (a.x == b.x) and (a.y == b.y)


proc `!=`*(a, b: Vec2): bool =
  result = (a.x != b.x) or (a.y != b.y)

# --------------------------------------------------------------------------------------------------

proc `-`*(a: Vec2): Vec2 {.inline.} =
  result.x = -a.x
  result.y = -a.y

# --------------------------------------------------------------------------------------------------

proc `+`*(a, b: Vec2): Vec2 {.inline.} =
  result.x = a.x + b.x
  result.y = a.y + b.y


proc `-`*(a, b: Vec2): Vec2 {.inline.} =
  result.x = a.x - b.x
  result.y = a.y - b.y


proc `*`*(a, b: Vec2): Vec2 {.inline.} =
  result.x = a.x * b.x
  result.y = a.y * b.y


proc `/`*(a, b: Vec2): Vec2 {.inline.} =
  result.x = a.x / b.x
  result.y = a.y / b.y

# --------------------------------------------------------------------------------------------------

proc `+`*(a: Vec2; b: float32): Vec2 {.inline.} =
  result.x = a.x + b
  result.y = a.y + b


proc `-`*(a: Vec2; b: float32): Vec2 {.inline.} =
  result.x = a.x - b
  result.y = a.y - b


proc `*`*(a: Vec2; b: float32): Vec2 {.inline.} =
  result.x = a.x * b
  result.y = a.y * b


proc `/`*(a: Vec2; b: float32): Vec2 {.inline.} =
  result.x = a.x / b
  result.y = a.y / b

# --------------------------------------------------------------------------------------------------

proc `+`*(a: float32; b: Vec2): Vec2 {.inline.} =
  result.x = a + b.x
  result.y = a + b.y


proc `-`*(a: float32; b: Vec2): Vec2 {.inline.} =
  result.x = a - b.x
  result.y = a - b.y


proc `*`*(a: float32; b: Vec2): Vec2 {.inline.} =
  result.x = a * b.x
  result.y = a * b.y


proc `/`*(a: float32; b: Vec2): Vec2 {.inline.} =
  result.x = a / b.x
  result.y = a / b.y

# --------------------------------------------------------------------------------------------------

proc `+=`*(a: var Vec2; b: Vec2) {.inline.} =
  a.x = a.x + b.x
  a.y = a.y + b.y


proc `-=`*(a: var Vec2; b: Vec2) {.inline.} =
  a.x = a.x - b.x
  a.y = a.y - b.y

# --------------------------------------------------------------------------------------------------

proc `<`*(a, b: Vec2): bool {.inline.} =
  result = (a.x < b.x) and (a.y < b.y)


proc `<=`*(a, b: Vec2): bool {.inline.} =
  result = (a.x <= b.x) and (a.y <= b.y)

# --------------------------------------------------------------------------------------------------

proc min*(a, b: Vec2): Vec2 {.inline.} =
  result.x = min(a.x, b.x)
  result.y = min(a.y, b.y)


proc max*(a, b: Vec2): Vec2 {.inline.} =
  result.x = max(a.x, b.x)
  result.y = max(a.y, b.y)


proc clamp*(v, min, max: Vec2): Vec2 {.inline.} =
  result.x = clamp(v.x, min.x, max.x)
  result.y = clamp(v.y, min.y, max.y)

# --------------------------------------------------------------------------------------------------

proc len*(a: Vec2): float32 {.inline.} =
  result = sqrt(a.x * a.x + a.y * a.y)
  assert(result >= 0.0f)


proc len_sq*(a: Vec2): float32 {.inline.} =
  result = a.x * a.x + a.y * a.y
  assert(result >= 0.0f)


proc normalize*(a: Vec2): Vec2 =
  var l = len(a)
  assert(classify(l) != fcNan)
  assert(l > 0.0f)
  result = a / l
  assert(classify(a.x) != fcNan)
  assert(classify(a.y) != fcNan)

# --------------------------------------------------------------------------------------------------

proc distance*(start, goal: Vec2): float32 {.inline.} =
  result = len(start - goal)


proc distance_sq*(start, goal: Vec2): float32 {.inline.} =
  result = len_sq(start - goal)


proc distance_manhattan*(start, goal: Vec2): float32 {.inline.} =
  result = abs(start.x - goal.x) + abs(start.y - goal.y)


proc distance_chebushev*(start, goal: Vec2): float32 {.inline.} =
  result = max(abs(start.x - goal.x), abs(start.y - goal.y))

# --------------------------------------------------------------------------------------------------

proc dot*(a, b: Vec2): float32 =
  ## returns the dot product of two vectors
  result = a.x * b.x + a.y * b.y


proc cross*(a, b: Vec2): float32 =
  ## returns the magnitude if cross product of two vectors
  result = a.x * b.y - a.y * b.x

# --------------------------------------------------------------------------------------------------

proc reflect*(incident, normal: Vec2): Vec2 =
  ## returns the reflection direction for an incident vector
  ## ``normal`` surface normal vector
  ## ``incident`` incident vector
  ## ``normal`` should be normalized in order to achieve the desired result
  result = incident - 2.0f * dot(normal, incident) * normal


proc reflect*(incident, normal: Vec2; restitution: float32): Vec2 =
  result = incident - (1f + restitution) * normal * dot(normal, incident)


proc direction*(a, b: Vec2): Vec2 =
  result = normalize(b - a)

# --------------------------------------------------------------------------------------------------

proc outside*(p, min, max: Vec2): bool =
  if p.x < min.x: return true
  if p.y < min.y: return true
  if p.x > max.x: return true
  if p.y > max.y: return true

# --------------------------------------------------------------------------------------------------

proc round*(a: Vec2): Vec2 {.inline.} =
  result.x = round(a.x)
  result.y = round(a.y)


proc trunc*(a: Vec2): Vec2 {.inline.} =
  result.x = trunc(a.x)
  result.y = trunc(a.y)


proc floor*(a: Vec2): Vec2 {.inline.} =
  result.x = floor(a.x)
  result.y = floor(a.y)


proc ceil*(a: Vec2): Vec2 {.inline.} =
  result.x = ceil(a.x)
  result.y = ceil(a.y)

# --------------------------------------------------------------------------------------------------

proc left*(a: Vec2): Vec2 {.inline.} =
  ## return vector rotated by -90 degrees
  result = vec2(-a.y, a.x)


proc right*(a: Vec2): Vec2 {.inline.} =
  ## return vector rotated by 90 degrees
  result = vec2(a.y, -a.x)

# --------------------------------------------------------------------------------------------------

proc low*(a: typedesc[Vec2]): Vec2 =
  result.x = low(float32)
  result.y = low(float32)


proc high*(a: typedesc[Vec2]): Vec2 =
  result.x = high(float32)
  result.y = high(float32)
