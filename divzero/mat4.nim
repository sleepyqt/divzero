import std     / [math]
import divzero / [vec4]

## This module implements 4x4 transformation matrix.
## Uses right-handed coordinate system.
## Viewing volume for vertex defined as:
## -Wc ≤ Xc ≤ Wc
## -Wc ≤ Xy ≤ Wc
## -Wc ≤ Xz ≤ Wc
##
## A * B != B * A
## A * (B + C) = A * B + A * C
## (A + B) * C = A * C + B * C
## A * identity = A = identity * A
## (A * B) * C = A * (B * C)
## transpose(A * B) = transpose(B) * transpose(A)
## inverse(inverse(A)) = A
## inverse(transpose(A)) = transpose(inverse(A))
## inverse(A) * A = identity = A * inverse(A)
##

type Mat4* = object
  ## 4x4, column-major transformation matrix.
  c0*: Vec4 ## +X axis (left).
  c1*: Vec4 ## +Y axis (up).
  c2*: Vec4 ## +Z axis (forward).
  c3*: Vec4 ## translation component.

# --------------------------------------------------------------------------------------------------

proc `*`*(a, b: Mat4): Mat4 =
  result.c0.x = a.c0.x * b.c0.x + a.c1.x * b.c0.y + a.c2.x * b.c0.z + a.c3.x * b.c0.w
  result.c1.x = a.c0.x * b.c1.x + a.c1.x * b.c1.y + a.c2.x * b.c1.z + a.c3.x * b.c1.w
  result.c2.x = a.c0.x * b.c2.x + a.c1.x * b.c2.y + a.c2.x * b.c2.z + a.c3.x * b.c2.w
  result.c3.x = a.c0.x * b.c3.x + a.c1.x * b.c3.y + a.c2.x * b.c3.z + a.c3.x * b.c3.w
  result.c0.y = a.c0.y * b.c0.x + a.c1.y * b.c0.y + a.c2.y * b.c0.z + a.c3.y * b.c0.w
  result.c1.y = a.c0.y * b.c1.x + a.c1.y * b.c1.y + a.c2.y * b.c1.z + a.c3.y * b.c1.w
  result.c2.y = a.c0.y * b.c2.x + a.c1.y * b.c2.y + a.c2.y * b.c2.z + a.c3.y * b.c2.w
  result.c3.y = a.c0.y * b.c3.x + a.c1.y * b.c3.y + a.c2.y * b.c3.z + a.c3.y * b.c3.w
  result.c0.z = a.c0.z * b.c0.x + a.c1.z * b.c0.y + a.c2.z * b.c0.z + a.c3.z * b.c0.w
  result.c1.z = a.c0.z * b.c1.x + a.c1.z * b.c1.y + a.c2.z * b.c1.z + a.c3.z * b.c1.w
  result.c2.z = a.c0.z * b.c2.x + a.c1.z * b.c2.y + a.c2.z * b.c2.z + a.c3.z * b.c2.w
  result.c3.z = a.c0.z * b.c3.x + a.c1.z * b.c3.y + a.c2.z * b.c3.z + a.c3.z * b.c3.w
  result.c0.w = a.c0.w * b.c0.x + a.c1.w * b.c0.y + a.c2.w * b.c0.z + a.c3.w * b.c0.w
  result.c1.w = a.c0.w * b.c1.x + a.c1.w * b.c1.y + a.c2.w * b.c1.z + a.c3.w * b.c1.w
  result.c2.w = a.c0.w * b.c2.x + a.c1.w * b.c2.y + a.c2.w * b.c2.z + a.c3.w * b.c2.w
  result.c3.w = a.c0.w * b.c3.x + a.c1.w * b.c3.y + a.c2.w * b.c3.z + a.c3.w * b.c3.w


proc `*`*(m: Mat4; c: Vec4): Vec4 =
  result.x = m.c0.x * c.x + m.c1.x * c.y + m.c2.x * c.z + m.c3.x * c.w
  result.y = m.c0.y * c.x + m.c1.y * c.y + m.c2.y * c.z + m.c3.y * c.w
  result.z = m.c0.z * c.x + m.c1.z * c.y + m.c2.z * c.z + m.c3.z * c.w
  result.w = m.c0.w * c.x + m.c1.w * c.y + m.c2.w * c.z + m.c3.w * c.w

# --------------------------------------------------------------------------------------------------

proc mat4*(): Mat4 =
  ## creates new identity matrix
  result.c0 = Vec4(x: 1.0f, y: 0.0f, z: 0.0f, w: 0.0f)
  result.c1 = Vec4(x: 0.0f, y: 1.0f, z: 0.0f, w: 0.0f)
  result.c2 = Vec4(x: 0.0f, y: 0.0f, z: 1.0f, w: 0.0f)
  result.c3 = Vec4(x: 0.0f, y: 0.0f, z: 0.0f, w: 1.0f)


proc mat4_t*(a: Vec4): Mat4 =
  ## creates new translation matrix
  result.c0 = Vec4(x: 1.0f, y: 0.0f, z: 0.0f, w: 0.0f)
  result.c1 = Vec4(x: 0.0f, y: 1.0f, z: 0.0f, w: 0.0f)
  result.c2 = Vec4(x: 0.0f, y: 0.0f, z: 1.0f, w: 0.0f)
  result.c3 = Vec4(x: a.x,  y: a.y,  z: a.z,  w: 1.0f)


proc mat4_s*(a: Vec4): Mat4 =
  ## creates new scale matrix
  result.c0 = Vec4(x: a.x,  y: 0.0f, z: 0.0f, w: 0.0f)
  result.c1 = Vec4(x: 0.0f, y: a.y,  z: 0.0f, w: 0.0f)
  result.c2 = Vec4(x: 0.0f, y: 0.0f, z: a.z,  w: 0.0f)
  result.c3 = Vec4(x: 0.0f, y: 0.0f, z: 0.0f, w: 1.0f)


proc mat4_rx*(phi: float32): Mat4 =
  ## creates new matrix rotated around x axis
  let s = sin(phi)
  let c = cos(phi)
  result.c0 = vec4(1.0, 0.0, 0.0, 0.0)
  result.c1 = vec4(0.0, c,   s,   0.0)
  result.c2 = vec4(0.0, -s,  c,   0.0)
  result.c3 = vec4(0.0, 0.0, 0.0, 1.0)


proc mat4_ry*(phi: float32): Mat4 =
  ## creates new matrix rotated around y axis
  let s = sin(phi)
  let c = cos(phi)
  result.c0 = vec4(c  , 0.0, s  , 0.0)
  result.c1 = vec4(0.0, 1.0, 0.0, 0.0)
  result.c2 = vec4(-s , 0.0, c  , 0.0)
  result.c3 = vec4(0.0, 0.0, 0.0, 1.0)


proc mat4_rz*(phi: float32): Mat4 =
  ## creates new matrix rotated around z axis
  let s = sin(phi)
  let c = cos(phi)
  result.c0 = vec4(c,   s,   0.0, 0.0)
  result.c1 = vec4(-s,  c,   0.0, 0.0)
  result.c2 = vec4(0.0, 0.0, 1.0, 0.0)
  result.c3 = vec4(0.0, 0.0, 0.0, 1.0)


proc mat4_rxyz*(a: Vec4): Mat4 =
  result = mat4_rz(a.z) * mat4_ry(a.y) * mat4_rx(a.x)

# --------------------------------------------------------------------------------------------------

proc translate*(m: Mat4; x, y, z: float32): Mat4 =
  result = m * mat4_t(vec4(x, y, z, 1.0f))

# --------------------------------------------------------------------------------------------------

proc view_look_at*(eye, target, up: Vec4): Mat4 =
  ## creates viewing matrix for camera
  ## `eye` - camera position
  ## `target` - camera target position
  ## `up` - camera up vector
  let f = normalize(target - eye)
  let l = normalize(cross(f, up))
  let u = cross(l, f)
  result.c0 = vec4(l.x, u.x, -f.x, 0.0f)
  result.c1 = vec4(l.y, u.y, -f.y, 0.0f)
  result.c2 = vec4(l.z, u.z, -f.z, 0.0f)
  result.c3 = vec4(-dot(l, eye), -dot(u, eye), dot(f, eye), 1f)


proc ortho*(l, r, b, t, n, f: float32): Mat4 =
  ## creates orthographics projection matrix
  ## `l`, `r` - coordinates for the left and right vertical clipping planes
  ## `b`, `t` - coordinates for the bottom and top horizontal clipping planes
  ## `n`, `f` - distance to near and far clipping planes
  result.c0 = vec4(2f / (r - l), 0f, 0f, 0f)
  result.c1 = vec4(0f, 2f / (t - b), 0f, 0f)
  result.c2 = vec4(0f, 0f, -2 / (f - n), 0f)
  result.c3 = vec4(-((r+l)/(r-l)), -((t+b)/(t-b)), -((f+n)/(f-n)), 1f)


proc persp*(fovy, aspect, znear, zfar: float32): Mat4 =
  ## creates perspective projection matrix
  ## `fovy` - horizontal field of view angle, in degrees
  ## `aspect` - viewport aspect ratio (width / height)
  ## `znear` - distance from the viewer to the near clipping plane
  ## `zfar` - distance from the viewer to the far clipping plane
  ## `zfar` > `znear` > 0f
  result.c0.x = 1f / (tan(0.5f * fovy * (PI / 180f)))
  result.c0.y = 0f
  result.c0.z = 0f
  result.c0.w = 0f

  result.c1.x = 0f
  result.c1.y = aspect / tan(0.5f * fovy * (PI / 180f))
  result.c1.z = 0f
  result.c1.w = 0f

  result.c2.x = 0f
  result.c2.y = 0f
  result.c2.z = -((zfar + znear) / (zfar - znear))
  result.c2.w = -1f

  result.c3.x = 0f
  result.c3.y = 0f
  result.c3.z = -((2f * znear * zfar) / (zfar - znear))
  result.c3.w = 0f

# --------------------------------------------------------------------------------------------------

proc transpose*(m: Mat4): Mat4 =
  result.c0 = vec4(m.c0.x, m.c1.x, m.c2.x, m.c3.x)
  result.c1 = vec4(m.c0.y, m.c1.y, m.c2.y, m.c3.y)
  result.c2 = vec4(m.c0.z, m.c1.z, m.c2.z, m.c3.z)
  result.c3 = vec4(m.c0.w, m.c1.w, m.c2.w, m.c3.w)


proc inverse*(m: Mat4): Mat4 =
  result.c0.x =  m.c1.y * m.c2.z * m.c3.w - m.c1.y * m.c2.w * m.c3.z -
                 m.c2.y * m.c1.z * m.c3.w + m.c2.y * m.c1.w * m.c3.z +
                 m.c3.y * m.c1.z * m.c2.w - m.c3.y * m.c1.w * m.c2.z
  result.c1.x = -m.c1.x * m.c2.z * m.c3.w + m.c1.x * m.c2.w * m.c3.z +
                 m.c2.x * m.c1.z * m.c3.w - m.c2.x * m.c1.w * m.c3.z -
                 m.c3.x * m.c1.z * m.c2.w + m.c3.x * m.c1.w * m.c2.z
  result.c2.x =  m.c1.x * m.c2.y * m.c3.w - m.c1.x * m.c2.w * m.c3.y -
                 m.c2.x * m.c1.y * m.c3.w + m.c2.x * m.c1.w * m.c3.y +
                 m.c3.x * m.c1.y * m.c2.w - m.c3.x * m.c1.w * m.c2.y
  result.c3.x = -m.c1.x * m.c2.y * m.c3.z + m.c1.x * m.c2.z * m.c3.y +
                 m.c2.x * m.c1.y * m.c3.z - m.c2.x * m.c1.z * m.c3.y -
                 m.c3.x * m.c1.y * m.c2.z + m.c3.x * m.c1.z * m.c2.y
  result.c0.y = -m.c0.y * m.c2.z * m.c3.w + m.c0.y * m.c2.w * m.c3.z +
                 m.c2.y * m.c0.z * m.c3.w - m.c2.y * m.c0.w * m.c3.z -
                 m.c3.y * m.c0.z * m.c2.w + m.c3.y * m.c0.w * m.c2.z
  result.c1.y =  m.c0.x * m.c2.z * m.c3.w - m.c0.x * m.c2.w * m.c3.z -
                 m.c2.x * m.c0.z * m.c3.w + m.c2.x * m.c0.w * m.c3.z +
                 m.c3.x * m.c0.z * m.c2.w - m.c3.x * m.c0.w * m.c2.z
  result.c2.y = -m.c0.x * m.c2.y * m.c3.w + m.c0.x * m.c2.w * m.c3.y +
                 m.c2.x * m.c0.y * m.c3.w - m.c2.x * m.c0.w * m.c3.y -
                 m.c3.x * m.c0.y * m.c2.w + m.c3.x * m.c0.w * m.c2.y
  result.c3.y =  m.c0.x * m.c2.y * m.c3.z - m.c0.x * m.c2.z * m.c3.y -
                 m.c2.x * m.c0.y * m.c3.z + m.c2.x * m.c0.z * m.c3.y +
                 m.c3.x * m.c0.y * m.c2.z - m.c3.x * m.c0.z * m.c2.y
  result.c0.z =  m.c0.y * m.c1.z * m.c3.w - m.c0.y * m.c1.w * m.c3.z -
                 m.c1.y * m.c0.z * m.c3.w + m.c1.y * m.c0.w * m.c3.z +
                 m.c3.y * m.c0.z * m.c1.w - m.c3.y * m.c0.w * m.c1.z
  result.c1.z = -m.c0.x * m.c1.z * m.c3.w + m.c0.x * m.c1.w * m.c3.z +
                 m.c1.x * m.c0.z * m.c3.w - m.c1.x * m.c0.w * m.c3.z -
                 m.c3.x * m.c0.z * m.c1.w + m.c3.x * m.c0.w * m.c1.z
  result.c2.z =  m.c0.x * m.c1.y * m.c3.w - m.c0.x * m.c1.w * m.c3.y -
                 m.c1.x * m.c0.y * m.c3.w + m.c1.x * m.c0.w * m.c3.y +
                 m.c3.x * m.c0.y * m.c1.w - m.c3.x * m.c0.w * m.c1.y
  result.c3.z = -m.c0.x * m.c1.y * m.c3.z + m.c0.x * m.c1.z * m.c3.y +
                 m.c1.x * m.c0.y * m.c3.z - m.c1.x * m.c0.z * m.c3.y -
                 m.c3.x * m.c0.y * m.c1.z + m.c3.x * m.c0.z * m.c1.y
  result.c0.w = -m.c0.y * m.c1.z * m.c2.w + m.c0.y * m.c1.w * m.c2.z +
                 m.c1.y * m.c0.z * m.c2.w - m.c1.y * m.c0.w * m.c2.z -
                 m.c2.y * m.c0.z * m.c1.w + m.c2.y * m.c0.w * m.c1.z
  result.c1.w =  m.c0.x * m.c1.z * m.c2.w - m.c0.x * m.c1.w * m.c2.z -
                 m.c1.x * m.c0.z * m.c2.w + m.c1.x * m.c0.w * m.c2.z +
                 m.c2.x * m.c0.z * m.c1.w - m.c2.x * m.c0.w * m.c1.z
  result.c2.w = -m.c0.x * m.c1.y * m.c2.w + m.c0.x * m.c1.w * m.c2.y +
                 m.c1.x * m.c0.y * m.c2.w - m.c1.x * m.c0.w * m.c2.y -
                 m.c2.x * m.c0.y * m.c1.w + m.c2.x * m.c0.w * m.c1.y
  result.c3.w =  m.c0.x * m.c1.y * m.c2.z - m.c0.x * m.c1.z * m.c2.y -
                 m.c1.x * m.c0.y * m.c2.z + m.c1.x * m.c0.z * m.c2.y +
                 m.c2.x * m.c0.y * m.c1.z - m.c2.x * m.c0.z * m.c1.y
  let det: float32 = m.c0.x * result.c0.x +
                 m.c0.y * result.c1.x +
                 m.c0.z * result.c2.x +
                 m.c0.w * result.c3.x
  if (det == 0.0f): assert(false, "matrix determinant is zero")
  let inv_det: float32 = 1.0f / det
  result.c0 = result.c0 * inv_det
  result.c1 = result.c1 * inv_det
  result.c2 = result.c2 * inv_det
  result.c3 = result.c3 * inv_det


proc fast_inverse*(m: Mat4): Mat4 =
  result.c0.x = m.c0.x
  result.c0.y = m.c1.x
  result.c0.z = m.c2.x
  result.c0.w = m.c0.w

  result.c1.x = m.c0.y
  result.c1.y = m.c1.y
  result.c1.z = m.c2.y
  result.c1.w = m.c1.w

  result.c2.x = m.c0.z
  result.c2.y = m.c1.z
  result.c2.z = m.c2.z
  result.c2.w = m.c2.w

  result.c3.x = -(result.c0.x * m.c3.x + result.c1.x * m.c3.y + result.c2.x * m.c3.z)
  result.c3.y = -(result.c0.y * m.c3.x + result.c1.y * m.c3.y + result.c2.y * m.c3.z)
  result.c3.z = -(result.c0.z * m.c3.x + result.c1.z * m.c3.y + result.c2.z * m.c3.z)
  result.c3.w = 1.0f


proc normalize_zaxis*(m: Mat4): Mat4 =
  result.c0 = normalize cross(m.c1, m.c2)
  result.c1 = normalize cross(m.c2, m.c0)
  result.c2 = normalize m.c2
  result.c3 = m.c3

# --------------------------------------------------------------------------------------------------

proc world_to_window*(obj: Vec4; view, proj: Mat4; viewport: Vec4): Vec4 =
  var i = proj * view * obj

  i.x /= i.w
  i.y /= i.w
  i.z /= i.w

  i.x = i.x * 0.5f + 0.5f
  i.y = i.y * 0.5f + 0.5f
  i.z = i.z * 0.5f + 0.5f

  i.x = i.x * viewport.z + viewport.x
  i.y = i.y * viewport.w + viewport.y

  result.x = i.x
  result.y = i.y
  result.z = i.z
  result.w = 1.0f


proc window_to_world*(win: Vec4; inv_vp: Mat4; viewport: Vec4): Vec4 =
  var i = win

  i.x = (i.x - viewport.x) / viewport.z
  i.y = (i.y - viewport.y) / viewport.w

  i.x = i.x * 2f - 1f
  i.y = i.y * 2f - 1f
  i.z = i.z * 2f - 1f

  var o = inv_vp * i

  o.x /= o.w
  o.y /= o.w
  o.z /= o.w

  result.x = o.x
  result.y = o.y
  result.z = o.z

# --------------------------------------------------------------------------------------------------

proc mat4_from_pitch_yaw*(pitch, yaw: float32; pos: Vec4): Mat4 =
  result = mat4_t(pos) * (mat4_rz(yaw) * mat4_rx(pitch))

# --------------------------------------------------------------------------------------------------

proc row0*(m: Mat4): Vec4 =
  result = vec4(m.c0.x, m.c1.x, m.c2.x, m.c3.x)


proc row1*(m: Mat4): Vec4 =
  result = vec4(m.c0.y, m.c1.y, m.c2.y, m.c3.y)


proc row2*(m: Mat4): Vec4 =
  result = vec4(m.c0.z, m.c1.z, m.c2.z, m.c3.z)


proc row3*(m: Mat4): Vec4 =
  result = vec4(m.c0.w, m.c1.w, m.c2.w, m.c3.w)

# --------------------------------------------------------------------------------------------------

proc pretty*(m: Mat4): string =
  result = $m.c0 & "\n"
  result.add $m.c1 & "\n"
  result.add $m.c2 & "\n"
  result.add $m.c3

# --------------------------------------------------------------------------------------------------

proc selftest* =
  discard
