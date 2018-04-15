import std / [math]

# --------------------------------------------------------------------------------------------------

const
  π* = PI

proc lerp*(t: float32; a, b: float32): float32 =
  ## linearly interpolate between ``a`` and ``b``.
  ## ``t`` must be in [0 .. 1] range
  result = (1f - t) * a + t * b


proc smoothstep*(edge0, edge1, x: float32): float32 =
  let t = clamp((x - edge0) / (edge1 - edge0), 0f, 1f)
  result = t * t * (3f - 2f * t)


proc step*(edge, x: float32): float32 =
  result = if x < edge: 0f else: 1f


proc `~=`*(x, y: float32): bool =
  abs(x - y) < 0.000001


proc expand_bits*(v: uint32): uint32 =
  ## expands 10bit interger into 30 bits by inserting 2 zeros after each bit.
  ## 1111111111 -> 100100100100100100100100100100
  ## 0000000000 -> 000000000000000000000000000000
  ##               _00_00_00_00_00_00_00_00_00_00
  var v = v
  v = (v * 0x00010001u32) and 0xFF0000FFu32
  v = (v * 0x00000101u32) and 0x0F00F00Fu32
  v = (v * 0x00000011u32) and 0xC30C30C3u32
  v = (v * 0x00000005u32) and 0x49249249u32
  result = v


func morton_3d(x, y, z: float32): uint32 =
  ## Calculates a 30-bit Morton code for the
  ## given 3D point located within the unit cube [0,1]
  let x = min(max(x * 1024f, 0f), 1023f)
  let y = min(max(y * 1024f, 0f), 1023f)
  let z = min(max(z * 1024f, 0f), 1023f)
  let xx = expand_bits(uint32 x)
  let yy = expand_bits(uint32 y)
  let zz = expand_bits(uint32 z)
  return xx * 4 + yy * 2 + zz


func fma*(a, b, c: float32): float32 =
  result = a * b + c


func min*(a, b, c: float32): float32 =
  result = min(a, min(b, c))


func max*(a, b, c: float32): float32 =
  result = max(a, max(b, c))


func min*(a, b, c, d: float32): float32 =
  result = min(a, min(b, min(c, d)))


func max*(a, b, c, d: float32): float32 =
  result = max(a, max(b, max(c, d)))


func rsqrt*(a: float32): float32 =
  result = 1f / sqrt(a)


func sin_poly*(x: float32): float32 =
  const a = -1f / 6f
  const b = +1f / 120f
  const c = -1f / 5040f
  const d = +1f / 362880f
  const e = -1f / 39916800f

  when true:
    let x3  = x * x * x
    let x5  = x * x * x * x * x
    let x7  = x * x * x * x * x * x * x
    let x9  = x * x * x * x * x * x * x * x * x
    let x11 = x * x * x * x * x * x * x * x * x * x * x
    result = (x) + (a * x3) + (b * x5) + (c * x7) + (d * x9) + (e * x11)

# --------------------------------------------------------------------------------------------------

proc selftest* =
  discard
