import divzero / [vec2]
import math

# --------------------------------------------------------------------------------------------------

type Mat3* = object
  x*: Vec2
  y*: Vec2
  t*: Vec2

# --------------------------------------------------------------------------------------------------

proc mat3*: Mat3 =
  result.x = vec2(1f, 0f)
  result.y = vec2(0f, 1f)
  result.t = vec2(0f, 0f)


proc mat3_t*(pos: Vec2): Mat3 =
  result.x = vec2(1f, 0f)
  result.y = vec2(0f, 1f)
  result.t = pos


proc mat3_s*(scale: Vec2): Mat3 =
  result.x = vec2(scale.x, 0f)
  result.y = vec2(0f,      scale.y)
  result.t = vec2(0f,      0f)


proc mat3_r*(phi: float32): Mat3 =
  let c = cos(phi)
  let s = sin(phi)
  result.x = vec2( c,  s)
  result.y = vec2(-s,  c)
  result.t = vec2(0f, 0f)


proc mat3_t*(x, y: float32): Mat3 =
  result.x = vec2(1f, 0f)
  result.y = vec2(0f, 1f)
  result.t = vec2(x,  y )


proc mat3_s*(x, y: float32): Mat3 =
  result.x = vec2(x,  0f)
  result.y = vec2(0f, y )
  result.t = vec2(0f, 0f)


proc mat3_s*(s: float32): Mat3 =
  result.x = vec2(s,  0f)
  result.y = vec2(0f, s )
  result.t = vec2(0f, 0f)

# --------------------------------------------------------------------------------------------------

proc `*`*(a, b: Mat3): Mat3 =
  result.x.x = a.x.x * b.x.x + a.y.x * b.x.y
  result.y.x = a.x.x * b.y.x + a.y.x * b.y.y
  result.t.x = a.x.x * b.t.x + a.y.x * b.t.y + a.t.x

  result.x.y = a.x.y * b.x.x + a.y.y * b.x.y
  result.y.y = a.x.y * b.y.x + a.y.y * b.y.y
  result.t.y = a.x.y * b.t.x + a.y.y * b.t.y + a.t.y


proc `*`*(m: Mat3; b: Vec2): Vec2 =
  result.x = (m.x.x * b.x) + (m.y.x * b.y) + m.t.x
  result.y = (m.x.y * b.x) + (m.y.y * b.y) + m.t.y

# --------------------------------------------------------------------------------------------------
