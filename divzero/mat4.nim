import std / [math]
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

func `*`*(a, b: Mat4): Mat4 =
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

func `*`*(m: Mat4; c: Vec4): Vec4 =
  ## multiply matrix with vector.
  ## ``c`` treated as column vector.
  result.x = m.c0.x * c.x + m.c1.x * c.y + m.c2.x * c.z + m.c3.x * c.w
  result.y = m.c0.y * c.x + m.c1.y * c.y + m.c2.y * c.z + m.c3.y * c.w
  result.z = m.c0.z * c.x + m.c1.z * c.y + m.c2.z * c.z + m.c3.z * c.w
  result.w = m.c0.w * c.x + m.c1.w * c.y + m.c2.w * c.z + m.c3.w * c.w

func mat4*(): Mat4 =
  ## creates new identity matrix
  result.c0 = Vec4(x: 1.0f, y: 0.0f, z: 0.0f, w: 0.0f)
  result.c1 = Vec4(x: 0.0f, y: 1.0f, z: 0.0f, w: 0.0f)
  result.c2 = Vec4(x: 0.0f, y: 0.0f, z: 1.0f, w: 0.0f)
  result.c3 = Vec4(x: 0.0f, y: 0.0f, z: 0.0f, w: 1.0f)

func mat4T*(a: Vec4): Mat4 =
  ## creates new translation matrix
  result.c0 = Vec4(x: 1.0f, y: 0.0f, z: 0.0f, w: 0.0f)
  result.c1 = Vec4(x: 0.0f, y: 1.0f, z: 0.0f, w: 0.0f)
  result.c2 = Vec4(x: 0.0f, y: 0.0f, z: 1.0f, w: 0.0f)
  result.c3 = Vec4(x: a.x,  y: a.y,  z: a.z,  w: 1.0f)

func mat4T*(x, y, z: float32): Mat4 =
  ## creates new translation matrix
  result.c0 = Vec4(x: 1.0f, y: 0.0f, z: 0.0f, w: 0.0f)
  result.c1 = Vec4(x: 0.0f, y: 1.0f, z: 0.0f, w: 0.0f)
  result.c2 = Vec4(x: 0.0f, y: 0.0f, z: 1.0f, w: 0.0f)
  result.c3 = Vec4(x: x,    y: y,    z: z,    w: 1.0f)

func mat4S*(a: Vec4): Mat4 =
  ## creates new scale matrix
  result.c0 = Vec4(x: a.x,  y: 0.0f, z: 0.0f, w: 0.0f)
  result.c1 = Vec4(x: 0.0f, y: a.y,  z: 0.0f, w: 0.0f)
  result.c2 = Vec4(x: 0.0f, y: 0.0f, z: a.z,  w: 0.0f)
  result.c3 = Vec4(x: 0.0f, y: 0.0f, z: 0.0f, w: 1.0f)

func mat4S*(x, y, z: float32): Mat4 =
  ## creates new scale matrix
  result.c0 = Vec4(x: x,    y: 0.0f, z: 0.0f, w: 0.0f)
  result.c1 = Vec4(x: 0.0f, y: y,    z: 0.0f, w: 0.0f)
  result.c2 = Vec4(x: 0.0f, y: 0.0f, z: z,    w: 0.0f)
  result.c3 = Vec4(x: 0.0f, y: 0.0f, z: 0.0f, w: 1.0f)

func mat4S*(s: float32): Mat4 =
  ## creates new scale matrix
  result.c0 = Vec4(x: s,    y: 0.0f, z: 0.0f, w: 0.0f)
  result.c1 = Vec4(x: 0.0f, y: s,    z: 0.0f, w: 0.0f)
  result.c2 = Vec4(x: 0.0f, y: 0.0f, z: s,    w: 0.0f)
  result.c3 = Vec4(x: 0.0f, y: 0.0f, z: 0.0f, w: 1.0f)

func mat4RX*(phi: float32): Mat4 =
  ## creates new matrix rotated around x axis
  let s = sin(phi)
  let c = cos(phi)
  result.c0 = vec4(1.0, 0.0, 0.0, 0.0)
  result.c1 = vec4(0.0, c,   s,   0.0)
  result.c2 = vec4(0.0, -s,  c,   0.0)
  result.c3 = vec4(0.0, 0.0, 0.0, 1.0)

func mat4RY*(phi: float32): Mat4 =
  ## creates new matrix rotated around y axis
  let s = sin(phi)
  let c = cos(phi)
  result.c0 = vec4(c  , 0.0, -s , 0.0)
  result.c1 = vec4(0.0, 1.0, 0.0, 0.0)
  result.c2 = vec4(s  , 0.0, c  , 0.0)
  result.c3 = vec4(0.0, 0.0, 0.0, 1.0)

func mat4RZ*(phi: float32): Mat4 =
  ## creates new matrix rotated around z axis
  let s = sin(phi)
  let c = cos(phi)
  result.c0 = vec4(c,   s,   0.0, 0.0)
  result.c1 = vec4(-s,  c,   0.0, 0.0)
  result.c2 = vec4(0.0, 0.0, 1.0, 0.0)
  result.c3 = vec4(0.0, 0.0, 0.0, 1.0)

func mat4RXYZ*(a: Vec4): Mat4 =
  result = mat4_rz(a.z) * mat4_ry(a.y) * mat4_rx(a.x)

func viewLookAt*(eye, target, up: Vec4): Mat4 =
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

func ortho*(l, r, b, t, n, f: float32): Mat4 =
  ## creates orthographics projection matrix
  ## `l`, `r` - coordinates for the left and right vertical clipping planes
  ## `b`, `t` - coordinates for the bottom and top horizontal clipping planes
  ## `n`, `f` - distance to near and far clipping planes
  result.c0 = vec4(2f / (r - l), 0f, 0f, 0f)
  result.c1 = vec4(0f, 2f / (t - b), 0f, 0f)
  result.c2 = vec4(0f, 0f, -2 / (f - n), 0f)
  result.c3 = vec4(-((r+l)/(r-l)), -((t+b)/(t-b)), -((f+n)/(f-n)), 1f)

func persp*(fovy, aspect, znear, zfar: float32): Mat4 =
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

func transpose*(m: Mat4): Mat4 =
  result.c0 = vec4(m.c0.x, m.c1.x, m.c2.x, m.c3.x)
  result.c1 = vec4(m.c0.y, m.c1.y, m.c2.y, m.c3.y)
  result.c2 = vec4(m.c0.z, m.c1.z, m.c2.z, m.c3.z)
  result.c3 = vec4(m.c0.w, m.c1.w, m.c2.w, m.c3.w)

func inverse*(m: Mat4): Mat4 =
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
  assert(det != 0.0f, "matrix determinant is zero")
  let invDet: float32 = 1.0f / det
  result.c0 = result.c0 * invDet
  result.c1 = result.c1 * invDet
  result.c2 = result.c2 * invDet
  result.c3 = result.c3 * invDet

func fastInverse*(m: Mat4): Mat4 =
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

func normalizeZAxis*(m: Mat4): Mat4 =
  result.c0 = normalize cross(m.c1, m.c2)
  result.c1 = normalize cross(m.c2, m.c0)
  result.c2 = normalize m.c2
  result.c3 = m.c3

func windowToNearClip*(x, y, width, height: float32): Vec4 =
  ## transforms point on near clip plane to clip space
  result.x = (2f * x) / width - 1f
  result.y = 1f - (2f * y) / height
  result.z = -1f
  result.w = 1f

func windowToFarClip*(x, y, width, height: float32): Vec4 =
  ## transforms point on far clip plane to clip space
  result.x = (2f * x) / width - 1f
  result.y = 1f - (2f * y) / height
  result.z = 0f
  result.w = 1f

func pretty*(m: Mat4): string =
  result = $m.c0 & "\n"
  result.add $m.c1 & "\n"
  result.add $m.c2 & "\n"
  result.add $m.c3

when isMainModule:
  discard