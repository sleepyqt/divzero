import std     / [math]
import divzero / [mathfn, vec4, mat4]
# --------------------------------------------------------------------------------------------------

type Quat4* = object
  x*, y*, z*: float32 ## vector term
  w*: float32 ## scalar term

# --------------------------------------------------------------------------------------------------

func quat4*(): Quat4 =
  ## returns quaternion representing no rotation
  result.x = 0f
  result.y = 0f
  result.z = 0f
  result.w = 1f


func quat4*(axis: Vec4; angle: float32): Quat4 =
  ## creates quaternion from ``axis`` and ``angle`` in radians
  let s = sin(angle * 0.5f)
  let c = cos(angle * 0.5f)
  result.x = axis.x * s
  result.y = axis.y * s
  result.z = axis.z * s
  result.w = c


func quat4*(x, y, z, w: float32): Quat4 =
  result.x = x
  result.y = y
  result.z = z
  result.w = w

# --------------------------------------------------------------------------------------------------

func len_sq*(quat: Quat4): float32 =
  result = (quat.x * quat.x) + (quat.y * quat.y) + (quat.z * quat.z) + (quat.w * quat.w)


func len*(quat: Quat4): float32 =
  result = sqrt(quat.len_sq)

# --------------------------------------------------------------------------------------------------

func normalize*(quat: Quat4): Quat4 =
  let inv_len = 1f / quat.len
  result.x = quat.x * inv_len
  result.y = quat.y * inv_len
  result.z = quat.z * inv_len
  result.w = quat.w * inv_len


func conjugate*(quat: Quat4): Quat4 =
  result.x = -quat.x
  result.y = -quat.y
  result.z = -quat.z
  result.w =  quat.w


func inverse*(quat: Quat4): Quat4 =
  let inv_len = 1f / quat.len_sq
  result.x = -quat.x * inv_len
  result.y = -quat.y * inv_len
  result.z = -quat.z * inv_len
  result.w =  quat.w * inv_len


func dot*(a, b: Quat4): float32 =
  result = (a.x * b.x + a.y * b.y) + (a.z * b.z + a.w * b.w)


func `*`*(a, b: Quat4): Quat4 =
  # cross
  let cx = a.y * b.z - a.z * b.y
  let cy = a.z * b.x - a.x * b.z
  let cz = a.x * b.y - a.y * b.x
  # dot
  let d  = a.x * b.x + a.y * b.y + a.z * b.z
  result.x = a.x * b.w + b.x * a.w + cx
  result.y = a.y * b.w + b.y * a.w + cy
  result.z = a.z * b.w + b.z * a.w + cz
  result.w = a.w * b.w - d


func to_matrix*(a: Quat4): Mat4 =
  let xx = a.x * a.x
  let xy = a.x * a.y
  let xz = a.x * a.z
  let xw = a.x * a.w

  let yy = a.y * a.y
  let yz = a.y * a.z
  let yw = a.y * a.w

  let zz = a.z * a.z
  let zw = a.z * a.w

  result.c0.x = 1f - 2f * (yy + zz)
  result.c1.x =      2f * (xy - zw)
  result.c2.x =      2f * (xz + yw)
  result.c0.y =      2f * (xy + zw)
  result.c1.y = 1f - 2f * (xx + zz)
  result.c2.y =      2f * (yz - xw)
  result.c0.z =      2f * (xz - yw)
  result.c1.z =      2f * (yz + xw)
  result.c2.z = 1f - 2f * (xx + yy)

  result.c0.w = 0f
  result.c1.w = 0f
  result.c2.w = 0f

  result.c3 = vec4(0f, 0f, 0f, 1f)


func lerp*(t: float32; a, b: Quat4): Quat4 =
  let s = 1f - t
  result.x = s * a.x + t * b.x
  result.y = s * a.y + t * b.y
  result.z = s * a.z + t * b.z
  result.w = s * a.w + t * b.w


func nlerp*(t: float32; a, b: Quat4): Quat4 =
  result = lerp(t, a, b).normalize


func slerp*(t: float32; a, b: Quat4): Quat4 =
  let cosom: float32 = dot(a, b)
  let abs_cosom: float32 = abs(cosom)
  var scale0: float32
  var scale1: float32
  if (1f - abs_cosom) > 1e-6f:
    let sin_sqr = 1f - abs_cosom * abs_cosom
    let sinom = rsqrt(sin_sqr)
    let omega = arctan2(sin_sqr * sinom, abs_cosom)
    scale0 = sin_poly((1f - t) * omega) * sinom
    scale1 = sin_poly(t * omega) * sinom
  else:
    scale0 = 1f - t
    scale1 = t
  scale1 = if cosom >= 0f: scale1 else: -scale1
  result.x = scale0 * a.x + scale1 * b.x
  result.y = scale0 * a.y + scale1 * b.y
  result.z = scale0 * a.z + scale1 * b.z
  result.w = scale0 * a.w + scale1 * b.w

# --------------------------------------------------------------------------------------------------

proc selftest* =
  let u0 = quat4()
  let u1 = quat4()
  do_assert(u0 * u1 == quat4())
  do_assert(len(u0) == 1f)
  do_assert(len(u1) == 1f)
  let q1 = quat4(2, 3, 4, 1)
  let q2 = quat4(6, 7, 8, 5)
  do_assert(q1 * q2 == quat4(12.0, 30.0, 24.0, -60.0))
