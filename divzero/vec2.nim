import std / [math]
import divzero / [mathfn]

type Vec2* = object
  ## Vector with two components
  x*, y*: float32

func vec2*(x, y: float32): Vec2 {.inline.} =
  result = Vec2(x: x, y: y)

func vec2*(c: float32): Vec2 {.inline.} =
  result = Vec2(x: c, y: c)

func vec2*(): Vec2 {.inline.} =
  ## returns zero vector (0, 0)
  result = Vec2(x: 0.0f, y: 0.0f)

func xx*(v: Vec2): Vec2 {.inline.} =
  result = Vec2(x: v.x, y: v.x)

func yy*(v: Vec2): Vec2 {.inline.} =
  result = Vec2(x: v.y, y: v.y)

func `-`*(a: Vec2): Vec2 {.inline.} =
  result.x = -a.x
  result.y = -a.y

func `+`*(a, b: Vec2): Vec2 {.inline.} =
  result.x = a.x + b.x
  result.y = a.y + b.y

func `-`*(a, b: Vec2): Vec2 {.inline.} =
  result.x = a.x - b.x
  result.y = a.y - b.y

func `*`*(a, b: Vec2): Vec2 {.inline.} =
  result.x = a.x * b.x
  result.y = a.y * b.y

func `/`*(a, b: Vec2): Vec2 {.inline.} =
  result.x = a.x / b.x
  result.y = a.y / b.y

func `div`*(a, b: Vec2): Vec2 =
  result.x = trunc(a.x / b.x)
  result.y = trunc(a.y / b.y)

func floorDiv*(a, b: Vec2): Vec2 =
  result.x = floor(a.x / b.x)
  result.y = floor(a.y / b.y)

func `+`*(a: Vec2; b: float32): Vec2 {.inline.} =
  result.x = a.x + b
  result.y = a.y + b

func `-`*(a: Vec2; b: float32): Vec2 {.inline.} =
  result.x = a.x - b
  result.y = a.y - b

func `*`*(a: Vec2; b: float32): Vec2 {.inline.} =
  result.x = a.x * b
  result.y = a.y * b

func `/`*(a: Vec2; b: float32): Vec2 {.inline.} =
  result.x = a.x / b
  result.y = a.y / b

func `div`*(a: Vec2; b: float32): Vec2 =
  ## scalar integer division (trunc a/b)
  result.x = trunc(a.x / b)
  result.y = trunc(a.y / b)

func floorDiv*(a: Vec2; b: float32): Vec2 =
  result.x = floor(a.x / b)
  result.y = floor(a.y / b)

func `mod`*(a: Vec2; b: float32): Vec2 =
  result.x = a.x mod b
  result.y = a.y mod b

func `+`*(a: float32; b: Vec2): Vec2 {.inline.} =
  result.x = a + b.x
  result.y = a + b.y

func `-`*(a: float32; b: Vec2): Vec2 {.inline.} =
  result.x = a - b.x
  result.y = a - b.y

func `*`*(a: float32; b: Vec2): Vec2 {.inline.} =
  result.x = a * b.x
  result.y = a * b.y

func `/`*(a: float32; b: Vec2): Vec2 {.inline.} =
  result.x = a / b.x
  result.y = a / b.y

func `+=`*(a: var Vec2; b: Vec2) {.inline.} =
  a.x = a.x + b.x
  a.y = a.y + b.y

func `-=`*(a: var Vec2; b: Vec2) {.inline.} =
  a.x = a.x - b.x
  a.y = a.y - b.y

func `==`*(a, b: Vec2): bool =
  result = (a.x == b.x) and (a.y == b.y)

func `!=`*(a, b: Vec2): bool =
  result = (a.x != b.x) or (a.y != b.y)

func `<`*(a, b: Vec2): bool {.inline.} =
  result = (a.x < b.x) and (a.y < b.y)

func `<=`*(a, b: Vec2): bool {.inline.} =
  result = (a.x <= b.x) and (a.y <= b.y)

func `~=`*(a, b: Vec2): bool =
  a.x ~= b.x and a.y ~= b.y

func min*(a, b: Vec2): Vec2 {.inline.} =
  result.x = min(a.x, b.x)
  result.y = min(a.y, b.y)

func max*(a, b: Vec2): Vec2 {.inline.} =
  result.x = max(a.x, b.x)
  result.y = max(a.y, b.y)

func clamp*(v, min, max: Vec2): Vec2 {.inline.} =
  result.x = clamp(v.x, min.x, max.x)
  result.y = clamp(v.y, min.y, max.y)

func min*(a, b, c: Vec2): Vec2 {.inline.} =
  result.x = min(min(a.x, b.x), c.x)
  result.y = min(min(a.y, b.y), c.y)

func max*(a, b, c: Vec2): Vec2 {.inline.} =
  result.x = max(max(a.x, b.x), c.x)
  result.y = max(max(a.y, b.y), c.y)

func lenSq*(a: Vec2): float32 {.inline.} =
  result = a.x * a.x + a.y * a.y

func len*(a: Vec2): float32 {.inline.} =
  ## returns vector length(magnitude)
  result = sqrt(len_sq(a))

func normalize*(a: Vec2): Vec2 =
  let il = 1f / len(a)
  result = a * il

func distance*(start, goal: Vec2): float32 {.inline.} =
  result = len(start - goal)

func distanceSq*(start, goal: Vec2): float32 {.inline.} =
  result = lenSq(start - goal)

func distanceManhattan*(start, goal: Vec2): float32 {.inline.} =
  result = abs(start.x - goal.x) + abs(start.y - goal.y)

func distanceChebushev*(start, goal: Vec2): float32 {.inline.} =
  result = max(abs(start.x - goal.x), abs(start.y - goal.y))

func dot*(a, b: Vec2): float32 {.inline.} =
  ## returns the dot product of two vectors
  result = a.x * b.x + a.y * b.y

func cross*(a, b: Vec2): float32 {.inline.} =
  ## returns the magnitude of cross product
  result = a.x * b.y - a.y * b.x

func reflect*(incident, normal: Vec2): Vec2 =
  ## returns the reflection direction for an incident vector
  ## ``normal`` surface normal vector
  ## ``incident`` incident vector
  ## ``normal`` should be normalized in order to achieve the desired result
  result = incident - 2.0f * dot(normal, incident) * normal

func reflect*(incident, normal: Vec2; restitution: float32): Vec2 =
  result = incident - (1f + restitution) * normal * dot(normal, incident)

func direction*(a, b: Vec2): Vec2 {.inline.} =
  result = normalize(b - a)

func slide*(incident, normal: Vec2): Vec2 =
  result = incident - normal * dot(incident, normal)

func refract*(incident, normal: Vec2; eta: float32): Vec2 =
  var k: float32 = 1.0f - eta * eta * (1.0f - dot(normal, incident) * dot(
      normal, incident))
  if k < 0.0f: vec2() else: eta * incident - (eta * dot(normal, incident) +
      sqrt(k)) * normal

func lerp*(t: float32; a, b: Vec2): Vec2 {.inline.} =
  result.x = lerp(t, a.x, b.x)
  result.y = lerp(t, a.y, b.y)

func round*(a: Vec2): Vec2 {.inline.} =
  result.x = round(a.x)
  result.y = round(a.y)

func trunc*(a: Vec2): Vec2 {.inline.} =
  result.x = trunc(a.x)
  result.y = trunc(a.y)

func floor*(a: Vec2): Vec2 {.inline.} =
  result.x = floor(a.x)
  result.y = floor(a.y)

func ceil*(a: Vec2): Vec2 {.inline.} =
  result.x = ceil(a.x)
  result.y = ceil(a.y)

func abs*(a: Vec2): Vec2 {.inline.} =
  result.x = abs(a.x)
  result.y = abs(a.y)

func fastAbs*(a: Vec2): Vec2 {.inline.} =
  result.x = fastAbs(a.x)
  result.y = fastAbs(a.y)

func left*(a: Vec2): Vec2 {.inline.} =
  ## return vector rotated by 90 degrees counter clockwise
  result = vec2(a.y, -a.x)

func right*(a: Vec2): Vec2 {.inline.} =
  ## return vector rotated by 90 degrees clockwise
  result = vec2(-a.y, a.x)

func low*(a: typedesc[Vec2]): Vec2 =
  result.x = low(float32)
  result.y = low(float32)

func high*(a: typedesc[Vec2]): Vec2 =
  result.x = high(float32)
  result.y = high(float32)
