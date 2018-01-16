import divzero / [vec2]
import math

# --------------------------------------------------------------------------------------------------

type Mat3* = object
  x*: array[3, float32]
  y*: array[3, float32]
  t*: array[3, float32]

# --------------------------------------------------------------------------------------------------

proc mat3*: Mat3 =
  result.x = [1f, 0f, 0f]
  result.y = [0f, 1f, 0f]
  result.t = [0f, 0f, 1f]


proc mat3_t*(pos: Vec2): Mat3 =
  result.x = [1f, 0f, 0f]
  result.y = [0f, 1f, 0f]
  result.t = [pos.x, pos.y, 1f]


proc mat3_s*(scale: Vec2): Mat3 =
  result.x = [scale.x, 0f, 0f]
  result.y = [0f, scale.y, 0f]
  result.t = [0f, 0f, 1f]


proc mat3_r*(phi: float32): Mat3 =
  let c = cos(phi)
  let s = sin(phi)
  result.x = [c,  -s, 0f]
  result.y = [s,  c,  0f]
  result.t = [0f, 0f, 1f]

# --------------------------------------------------------------------------------------------------

proc `*`*(a, b: Mat3): Mat3 =
  result.x[0] = a.x[0] * b.x[0] + a.y[0] * b.x[1] + a.t[0] * b.x[2]
  result.y[0] = a.x[0] * b.y[0] + a.y[0] * b.y[1] + a.t[0] * b.y[2]
  result.t[0] = a.x[0] * b.t[0] + a.y[0] * b.t[1] + a.t[0] * b.t[2]

  result.x[1] = a.x[1] * b.x[0] + a.y[1] * b.x[1] + a.t[1] * b.x[2]
  result.y[1] = a.x[1] * b.y[0] + a.y[1] * b.y[1] + a.t[1] * b.y[2]
  result.t[1] = a.x[1] * b.t[0] + a.y[1] * b.t[1] + a.t[1] * b.t[2]

  result.x[2] = a.x[2] * b.x[0] + a.y[2] * b.x[1] + a.t[2] * b.x[2]
  result.y[2] = a.x[2] * b.y[0] + a.y[2] * b.y[1] + a.t[2] * b.y[2]
  result.t[2] = a.x[2] * b.t[0] + a.y[2] * b.t[1] + a.t[2] * b.t[2]


proc `*`*(m: Mat3; b: Vec2): Vec2 =
  let c = [b.x, b.y, 1f]
  result.x = m.x[0] * c[0] + m.y[0] * c[1] + m.t[0] * c[2]
  result.y = m.x[1] * c[0] + m.y[1] * c[1] + m.t[1] * c[2]

# --------------------------------------------------------------------------------------------------
