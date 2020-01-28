import std / [math]
import divzero / [vec2, mathfn]

type Mat3* = object
  ## Represents a 3x2 transformation matrix
  x*: Vec2 ## basis X-axis
  y*: Vec2 ## basis Y-axis
  t*: Vec2 ## translation component

proc mat3*: Mat3 {.inline.} =
  ## returns identity transformation matrix
  result.x = vec2(1f, 0f)
  result.y = vec2(0f, 1f)
  result.t = vec2(0f, 0f)

proc mat3T*(pos: Vec2): Mat3 {.inline.} =
  ## returns translation transformation matrix
  result.x = vec2(1f, 0f)
  result.y = vec2(0f, 1f)
  result.t = pos

proc mat3S*(scale: Vec2): Mat3 =
  ## returns scale transformation matrix
  result.x = vec2(scale.x, 0f)
  result.y = vec2(0f, scale.y)
  result.t = vec2(0f, 0f)

proc mat3R*(phi: float32): Mat3 =
  ## returns matrix rotated clockwise by ``phi`` radians
  let c = cos(phi)
  let s = sin(phi)
  result.x = vec2(c, s)
  result.y = vec2(-s, c)
  result.t = vec2(0f, 0f)

proc mat3T*(x, y: float32): Mat3 {.inline.} =
  ## returns translation transformation matrix
  result.x = vec2(1f, 0f)
  result.y = vec2(0f, 1f)
  result.t = vec2(x, y)

proc mat3S*(x, y: float32): Mat3 {.inline.} =
  ## returns scale matrix
  result.x = vec2(x, 0f)
  result.y = vec2(0f, y)
  result.t = vec2(0f, 0f)

proc mat3S*(s: float32): Mat3 {.inline.} =
  ## returns scale transformation matrix
  result.x = vec2(s, 0f)
  result.y = vec2(0f, s)
  result.t = vec2(0f, 0f)

proc basisDet*(m: Mat3): float32 {.inline.} =
  ## returns determinant of 2x2 basis matrix
  result = m.x.x * m.y.y - m.y.x * m.x.y

proc `*`*(a, b: Mat3): Mat3 =
  ## combine transformations
  result.x.x = a.x.x * b.x.x + a.y.x * b.x.y
  result.x.y = a.x.y * b.x.x + a.y.y * b.x.y

  result.y.x = a.x.x * b.y.x + a.y.x * b.y.y
  result.y.y = a.x.y * b.y.x + a.y.y * b.y.y

  result.t.x = a.x.x * b.t.x + a.y.x * b.t.y + a.t.x
  result.t.y = a.x.y * b.t.x + a.y.y * b.t.y + a.t.y

proc linearTransform*(m: Mat3; b: Vec2): Vec2 =
  ## returns vector transformed by matrix
  result.x = (m.x.x * b.x) + (m.y.x * b.y)
  result.y = (m.x.y * b.x) + (m.y.y * b.y)

proc affineTransform*(m: Mat3; b: Vec2): Vec2 =
  ## returns vector transformed by matrix
  result = linearTransform(m, b) + m.t

proc `*`*(m: Mat3; b: Vec2): Vec2 =
  ## return vector transformed by matrix ``m``
  result = affineTransform(m, b)

proc linearInverse*(m: Mat3): Mat3 =
  ## returns inverse of matrix
  result.x = vec2(m.y.y, -m.x.y)
  result.y = vec2(-m.y.x, m.x.x)
  let invDet = 1f / basisDet(m)
  result.x = result.x * invDet
  result.y = result.y * invDet
  result.t = vec2(0f, 0f)

proc affineInverse*(m: Mat3): Mat3 =
  ## returns inverse of matrix
  result = linearInverse(m)
  result.t = linearTransform(result, -m.t)

func lerp*(t: float32; a, b: Mat3): Mat3 =
  result.x = lerp(t, a.x, b.x)
  result.y = lerp(t, a.y, b.y)
  result.t = lerp(t, a.t, b.t)

proc `==`*(a, b: Mat3): bool =
  a.x == b.x and a.y == b.y and a.t == b.t

proc `~=`*(a, b: Mat3): bool =
  a.x ~= b.x and a.y ~= b.y and a.t ~= b.t

proc pretty*(m: Mat3): string =
  let a = "[" & $m.x.x & ", " & $m.y.x & ", " & $m.t.x & "]\n"
  let b = "[" & $m.x.y & ", " & $m.y.y & ", " & $m.t.y & "]\n"
  let c = "[0.0, 0.0, 1.0]\n"
  result = a & b & c
