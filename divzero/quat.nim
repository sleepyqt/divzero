import std     / [math]
import divzero / [mathfn, vec4, mat4]

# --------------------------------------------------------------------------------------------------

type Quat* = object
  x*, y*, z*: float32 ## vector term
  w*: float32 ## scalar term

# --------------------------------------------------------------------------------------------------

func quat*(): Quat =
  ## returns quaternion representing no rotation
  result.x = 0f
  result.y = 0f
  result.z = 0f
  result.w = 1f


func quat*(axis: Vec4; angle: float32): Quat =
  ## creates quaternion from ``axis`` and ``angle`` in radians
  let s = sin(angle * 0.5f)
  let c = cos(angle * 0.5f)
  result.x = axis.x * s
  result.y = axis.y * s
  result.z = axis.z * s
  result.w = c


func quat*(x, y, z, w: float32): Quat =
  result.x = x
  result.y = y
  result.z = z
  result.w = w


func quat_rx*(angle: float32): Quat =
  result.x = sin(angle * 0.5f)
  result.y = 0f
  result.z = 0f
  result.w = cos(angle * 0.5f)


func quat_ry*(angle: float32): Quat =
  result.x = 0f
  result.y = sin(angle * 0.5f)
  result.z = 0f
  result.w = cos(angle * 0.5f)


func quat_rz*(angle: float32): Quat =
  result.x = 0f
  result.y = 0f
  result.z = sin(angle * 0.5f)
  result.w = cos(angle * 0.5f)

# --------------------------------------------------------------------------------------------------

func len_sq*(quat: Quat): float32 =
  result = (quat.x * quat.x) + (quat.y * quat.y) + (quat.z * quat.z) + (quat.w * quat.w)


func len*(quat: Quat): float32 =
  result = sqrt(quat.len_sq)

# --------------------------------------------------------------------------------------------------

func normalize*(quat: Quat): Quat =
  let inv_len = 1f / quat.len
  result.x = quat.x * inv_len
  result.y = quat.y * inv_len
  result.z = quat.z * inv_len
  result.w = quat.w * inv_len


func conjugate*(quat: Quat): Quat =
  result.x = -quat.x
  result.y = -quat.y
  result.z = -quat.z
  result.w =  quat.w


func inverse*(quat: Quat): Quat =
  let inv_len = 1f / quat.len_sq
  result.x = -quat.x * inv_len
  result.y = -quat.y * inv_len
  result.z = -quat.z * inv_len
  result.w =  quat.w * inv_len


func dot*(a, b: Quat): float32 =
  result = (a.x * b.x + a.y * b.y) + (a.z * b.z + a.w * b.w)


func `*`*(a, b: Quat): Quat =
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


func `*`*(a: Quat; s: float32): Quat =
  result.x = a.x * s
  result.y = a.y * s
  result.z = a.z * s
  result.w = a.w * s


func `+`*(a, b: Quat): Quat =
  result.x = a.x + b.x
  result.y = a.y + b.y
  result.z = a.z + b.z
  result.w = a.w + b.w


func `-`*(a, b: Quat): Quat =
  result.x = a.x - b.x
  result.y = a.y - b.y
  result.z = a.z - b.z
  result.w = a.w - b.w


func forward*(a: Quat): Vec4 =
  let xx = a.x * a.x
  let xz = a.x * a.z
  let xw = a.x * a.w
  let yy = a.y * a.y
  let yz = a.y * a.z
  let yw = a.y * a.w
  result.x =      2f * (xz + yw)
  result.y =      2f * (yz - xw)
  result.z = 1f - 2f * (xx + yy)


func up*(a: Quat): Vec4 =
  let xx = a.x * a.x
  let xy = a.x * a.y
  let xw = a.x * a.w
  let yz = a.y * a.z
  let zz = a.z * a.z
  let zw = a.z * a.w
  result.x =      2f * (xy - zw)
  result.y = 1f - 2f * (xx + zz)
  result.z =      2f * (yz + xw)


func left*(a: Quat): Vec4 =
  let xy = a.x * a.y
  let xz = a.x * a.z
  let yy = a.y * a.y
  let yw = a.y * a.w
  let zz = a.z * a.z
  let zw = a.z * a.w
  result.x = 1f - 2f * (yy + zz)
  result.y =      2f * (xy + zw)
  result.z =      2f * (xz - yw)


func to_matrix*(a: Quat): Mat4 =
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
  result.c0.y =      2f * (xy + zw)
  result.c0.z =      2f * (xz - yw)
  result.c1.x =      2f * (xy - zw)
  result.c1.y = 1f - 2f * (xx + zz)
  result.c1.z =      2f * (yz + xw)
  result.c2.x =      2f * (xz + yw)
  result.c2.y =      2f * (yz - xw)
  result.c2.z = 1f - 2f * (xx + yy)

  result.c0.w = 0f
  result.c1.w = 0f
  result.c2.w = 0f

  result.c3 = vec4(0f, 0f, 0f, 1f)


func to_matrix*(rot: Quat; pos: Vec4): Mat4 =
  result = to_matrix(rot)
  result.c3 = pos


func to_axis_and_angle*(q: Quat): (Vec4, float32) =
  let ca = q.w
  var sa = sqrt(1f - ca * ca)
  if abs(sa) < 0.0005f: sa = 1f
  result[0].x = q.x / sa
  result[0].y = q.y / sa
  result[0].z = q.z / sa
  result[0].w = 0f
  result[1]   = 2f * arccos(ca)


func rotate_vector*(q: Quat; v: Vec4): Vec4 =
  let vt = q * quat(v.x, v.y, v.z, 0f) * conjugate(q)
  result.x = vt.x
  result.y = vt.y
  result.z = vt.z
  result.w = 0f


func rotate_point*(q: Quat; v: Vec4): Vec4 =
  let vt = q * quat(v.x, v.y, v.z, 0f) * conjugate(q)
  result.x = vt.x
  result.y = vt.y
  result.z = vt.z
  result.w = 1f


func lerp*(t: float32; a, b: Quat): Quat =
  let s = 1f - t
  result.x = s * a.x + t * b.x
  result.y = s * a.y + t * b.y
  result.z = s * a.z + t * b.z
  result.w = s * a.w + t * b.w


func nlerp*(t: float32; a, b: Quat): Quat =
  result = lerp(t, a, b).normalize


func slerp*(t: float32; a, b: Quat): Quat =
  let cosom: float32 = dot(a, b)
  let abs_cosom: float32 = abs(cosom)
  var scale0: float32
  var scale1: float32
  if (1f - abs_cosom) > 1e-6f:
    let sin_sqr = 1f - abs_cosom * abs_cosom
    let sinom = rsqrt(sin_sqr)
    let omega = arctan2(sin_sqr * sinom, abs_cosom)
    scale0 = sin_poly_5((1f - t) * omega) * sinom
    scale1 = sin_poly_5(t * omega) * sinom
  else:
    scale0 = 1f - t
    scale1 = t
  scale1 = if cosom >= 0f: scale1 else: -scale1
  result.x = scale0 * a.x + scale1 * b.x
  result.y = scale0 * a.y + scale1 * b.y
  result.z = scale0 * a.z + scale1 * b.z
  result.w = scale0 * a.w + scale1 * b.w

# --------------------------------------------------------------------------------------------------

type DualQuat* = object
  real*: Quat
  dual*: Quat

# --------------------------------------------------------------------------------------------------

func dual_quat*(): DualQuat =
  result.real = quat(0f, 0f, 0f, 1f)
  result.dual = quat(0f, 0f, 0f, 0f)


func dual_quat*(real, dual: Quat): DualQuat =
  result.real = normalize(real)
  result.dual = dual


func dual_quat*(rotation: Quat; t: Vec4): DualQuat =
  result.real = normalize(rotation)
  result.dual = quat(t.x, t.y, t.z, 0f) * result.real * 0.5f


func dual_quat_t*(t: Vec4): DualQuat =
  result.real = quat()
  result.dual = quat(t.x, t.y, t.z, 0f) * result.real * 0.5f


func dual_quat_t*(x, y, z: float32): DualQuat =
  result.real = quat()
  result.dual = quat(x, y, z, 0f) * result.real * 0.5f


func dual_quat_rx*(angle: float32): DualQuat =
  result.real = quat_rx(angle)
  result.dual = quat(0f, 0f, 0f, 0f)


func dual_quat_ry*(angle: float32): DualQuat =
  result.real = quat_ry(angle)
  result.dual = quat(0f, 0f, 0f, 0f)


func dual_quat_rz*(angle: float32): DualQuat =
  result.real = quat_rz(angle)
  result.dual = quat(0f, 0f, 0f, 0f)


func dot*(a, b: DualQuat): float32 =
  result = dot(a.real, b.real)


func `*`*(a: DualQuat; s: float32): DualQuat =
  result.real = a.real * s
  result.dual = a.dual * s


func normalize*(a: DualQuat): DualQuat =
  let mag = dot(a.real, a.real)
  result.real = a.real * (1f / mag)
  result.dual = a.dual * (1f / mag)


func `+`*(a, b: DualQuat): DualQuat =
  result.real = a.real + b.real
  result.dual = a.dual + b.dual


func `*`*(a, b: DualQuat): DualQuat =
  result.real = a.real * b.real
  result.dual = a.real * b.dual + a.dual * b.real


func conjugate*(a: DualQuat): DualQuat =
  result.real = conjugate(a.real)
  result.dual = conjugate(a.dual)


func rotation*(a: DualQuat): Quat =
  result = a.real


func translation*(a: DualQuat): Vec4 =
  let t = (a.dual * 2f) * conjugate(a.real)
  result.x = t.x
  result.y = t.y
  result.z = t.z
  result.w = 1f


func to_matrix*(a: DualQuat): Mat4 =
  let q = normalize(a)
  let w = q.real.w
  let x = q.real.x
  let y = q.real.y
  let z = q.real.z
  result.c0.x = (w * w) + (x * x) - (y * y) - (z * z)
  result.c0.y = (2f * x * y) + (2f * w * z)
  result.c0.z = (2f * x * z) - (2f * w * y)
  result.c0.w = 0f

  result.c1.x = (2f * x * y) - (2f * w * z)
  result.c1.y = (w * w) + (y * y) - (x * x) - (z * z)
  result.c1.z = (2f * y * z) + (2f * w * x)
  result.c1.w = 0f

  result.c2.x = (2f * x * z) + (2f * w * y)
  result.c2.y = (2f * y * z) - (2f * w * x)
  result.c2.z = (w * w) + (z * z) - (x * x) - (y * y)
  result.c2.w = 0f

  let t = (q.dual * 2f) * conjugate(q.real)
  result.c3.x = t.x
  result.c3.y = t.y
  result.c3.z = t.z
  result.c3.w = 1f


func rotate_vector*(q: DualQuat; v: Vec4): Vec4 =
  result = q.real.rotate_vector(v)


func transform*(q: DualQuat; p: Vec4): Vec4 =
  result = q.real.rotate_vector(p) + q.translation


func lerp*(t: float32; a, b: DualQuat): DualQuat =
  result.real = t.lerp(a.real, b.real)
  result.dual = t.lerp(a.dual, b.dual)

# --------------------------------------------------------------------------------------------------

proc selftest* =
  block:
    let u0 = quat()
    let u1 = quat()
    do_assert(u0 * u1 == quat())
    do_assert(len(u0) == 1f)
    do_assert(len(u1) == 1f)
    let q1 = quat(2, 3, 4, 1)
    let q2 = quat(6, 7, 8, 5)
    do_assert(q1 * q2 == quat(12.0, 30.0, 24.0, -60.0))

  block:
    let q1 = dual_quat()
    let q2 = dual_quat()
    echo q1
    echo q2
    echo q1 * q2
    #do_assert(q1 * q2 == dual_quat())

    let q3 = dual_quat(quat(), vec4(1, 2, 3, 1))
    echo "q3"
    echo q3.to_matrix.pretty
    let q4 = dual_quat(quat(vec4(0, 1, 0, 0), 1.23f), vec4())
    echo "q4"
    echo q4.to_matrix.pretty
    let q5 = dual_quat(quat(vec4(0, 1, 0, 0), 1.23f), vec4(1, 2, 3, 1))
    echo "q5"
    echo q5.to_matrix.pretty
    let q6 = dual_quat(quat(), vec4(3, 2, 1, 1))
    echo "q6"
    echo q6.to_matrix.pretty
    echo "q3 * q6"
    echo (q3 * q6).to_matrix.pretty
