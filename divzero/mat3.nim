import std     / [math]
import divzero / [vec2, mathfn]

# --------------------------------------------------------------------------------------------------

type Mat3* = object
  ## 3x2 transformation matrix
  x*: Vec2 ## basis X-axis
  y*: Vec2 ## basis Y-axis
  t*: Vec2 ## translation

# --------------------------------------------------------------------------------------------------

proc mat3*: Mat3 =
  ## returns identity transformation matrix
  result.x = vec2(1f, 0f)
  result.y = vec2(0f, 1f)
  result.t = vec2(0f, 0f)


proc mat3_t*(pos: Vec2): Mat3 =
  ## returns translation transformation matrix
  result.x = vec2(1f, 0f)
  result.y = vec2(0f, 1f)
  result.t = pos


proc mat3_s*(scale: Vec2): Mat3 =
  ## returns scale transformation matrix
  result.x = vec2(scale.x, 0f)
  result.y = vec2(0f,      scale.y)
  result.t = vec2(0f,      0f)


proc mat3_r*(phi: float32): Mat3 =
  ## returns matrix rotated clockwise by ``phi`` radians
  let c = cos(phi)
  let s = sin(phi)
  result.x = vec2( c,  s)
  result.y = vec2(-s,  c)
  result.t = vec2(0f, 0f)


proc mat3_t*(x, y: float32): Mat3 =
  ## returns translation transformation matrix
  result.x = vec2(1f, 0f)
  result.y = vec2(0f, 1f)
  result.t = vec2(x,  y )


proc mat3_s*(x, y: float32): Mat3 =
  ## returns scale matrix
  result.x = vec2(x,  0f)
  result.y = vec2(0f, y )
  result.t = vec2(0f, 0f)


proc mat3_s*(s: float32): Mat3 =
  ## returns scale transformation matrix
  result.x = vec2(s,  0f)
  result.y = vec2(0f, s )
  result.t = vec2(0f, 0f)

# --------------------------------------------------------------------------------------------------

proc basis_det*(m: Mat3): float32 =
  result = m.x.x * m.y.y - m.y.x * m.x.y

# --------------------------------------------------------------------------------------------------

proc `*`*(a, b: Mat3): Mat3 =
  ## combine transformations
  result.x.x = a.x.x * b.x.x + a.y.x * b.x.y
  result.y.x = a.x.x * b.y.x + a.y.x * b.y.y
  result.t.x = a.x.x * b.t.x + a.y.x * b.t.y + a.t.x

  result.x.y = a.x.y * b.x.x + a.y.y * b.x.y
  result.y.y = a.x.y * b.y.x + a.y.y * b.y.y
  result.t.y = a.x.y * b.t.x + a.y.y * b.t.y + a.t.y


proc linear_transform*(m: Mat3; b: Vec2): Vec2 =
  result.x = (m.x.x * b.x) + (m.y.x * b.y)
  result.y = (m.x.y * b.x) + (m.y.y * b.y)


proc affine_transform*(m: Mat3; b: Vec2): Vec2 =
    result = linear_transform(m, b) + m.t


proc `*`*(m: Mat3; b: Vec2): Vec2 =
  ## return vector transformed by matrix ``m``
  result = affine_transform(m, b)

# --------------------------------------------------------------------------------------------------

proc linear_inverse*(m: Mat3): Mat3 =
  result.x = vec2(m.y.y, -m.x.y)
  result.y = vec2(-m.y.x, m.x.x)
  let inv_det = 1f / basis_det(m)
  result.x = result.x * inv_det
  result.y = result.y * inv_det
  result.t = vec2(0f, 0f)


proc affine_inverse*(m: Mat3): Mat3 =
  result = linear_inverse(m)
  result.t = linear_transform(result, -m.t)

# --------------------------------------------------------------------------------------------------

proc `==`*(a, b: Mat3): bool =
  a.x == b.x and a.y == b.y and a.t == b.t


proc `~=`*(a, b: Mat3): bool =
  a.x ~= b.x and a.y ~= b.y and a.t ~= b.t

# --------------------------------------------------------------------------------------------------

proc pretty*(m: Mat3): string =
  let a = "[" & $m.x.x & ", " & $m.y.x & ", " & $m.t.x & "]\n"
  let b = "[" & $m.x.y & ", " & $m.y.y & ", " & $m.t.y & "]\n"
  let c = "[0.0, 0.0, 1.0]\n"
  result = a & b & c

# --------------------------------------------------------------------------------------------------

proc selftest* =
  do_assert(1f != 2f)
  do_assert(1f ~= 1.00000001f)
  do_assert(not (1f ~= 1.1f))

  let a = mat3_r(1f) * mat3_s(2f, 3f)
  let ia = linear_inverse(a)
  do_assert(a * ia ~= mat3())
  let b = a * mat3_t(1f, -2f)
  let ib = affine_inverse(b)
  do_assert(b * ib ~= mat3())
  let c = vec2(10f, 20f)
  let ac = a * c
  let bc = b * c
  do_assert(ia * ac ~= c)
  do_assert(ib * bc ~= c)
