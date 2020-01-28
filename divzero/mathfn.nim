import std / [math]

const π* = PI

func fract*(x: float32): float32 {.inline.} =
  ## returns the fractional part of ``x``.
  x - floor(x)

func lerp*(t: float32; a, b: float32): float32 {.inline.} =
  ## linearly interpolate between ``a`` and ``b``.
  ## ``t`` must be in [0 .. 1] range
  (1f - t) * a + t * b

func smoothStep*(x, edge0, edge1: float32): float32 {.inline.} =
  ## performs Hermite interpolation between two values.
  ## ``edge0`` - lower edge of the Hermite function.
  ## ``edge1`` - higher edge.
  ## ``x`` - value to interpolate.
  let t = clamp((x - edge0) / (edge1 - edge0), 0f, 1f)
  result = t * t * (3f - 2f * t)

func smootherStep*(x, edge0, edge1: float32): float32 =
  let t = clamp(x, 0f, 1f)
  let r = t * t * t * (t * (6f * t - 15f) + 10f)
  lerp(r, edge0, edge1)

func step*(edge, x: float32): float32 {.inline.} =
  if x < edge: 0f else: 1f

func `~=`*(x, y: float32): bool =
  abs(x - y) < 0.000001

func expandBits*(v: uint32): uint32 =
  ## expands 10bit interger into 30 bits by inserting 2 zeros after each bit.
  ## 1111111111 -> 100100100100100100100100100100.
  ## 0000000000 -> 000000000000000000000000000000.
  ##               _00_00_00_00_00_00_00_00_00_00.
  var v = v
  v = (v * 0x00010001u32) and 0xFF0000FFu32
  v = (v * 0x00000101u32) and 0x0F00F00Fu32
  v = (v * 0x00000011u32) and 0xC30C30C3u32
  v = (v * 0x00000005u32) and 0x49249249u32
  result = v

func morton3D*(x, y, z: float32): uint32 =
  ## Calculates a 30-bit Morton code for the
  ## given 3D point located within the unit cube [0,1]
  let x = min(max(x * 1024f, 0f), 1023f)
  let y = min(max(y * 1024f, 0f), 1023f)
  let z = min(max(z * 1024f, 0f), 1023f)
  let xx = expand_bits(uint32 x)
  let yy = expand_bits(uint32 y)
  let zz = expand_bits(uint32 z)
  return xx * 4 + yy * 2 + zz

func min*(a, b, c: float32): float32 {.inline.} =
  result = min(a, min(b, c))

func max*(a, b, c: float32): float32 {.inline.} =
  result = max(a, max(b, c))

func min*(a, b, c, d: float32): float32 {.inline.} =
  result = min(a, min(b, min(c, d)))

func max*(a, b, c, d: float32): float32 {.inline.} =
  result = max(a, max(b, max(c, d)))

func rsqrt*(a: float32): float32 {.inline.} =
  result = 1f / sqrt(a)

func sinPoly5*(x: float32): float32 =
  const
    a = -1f / 6f
    b = +1f / 120f
    c = -1f / 5040f
    d = +1f / 362880f
    e = -1f / 39916800f
  let z = x * x
  result = e
  result = result * z + d
  result = result * z + c
  result = result * z + b
  result = result * z + a
  result = result * z + 1f
  result = result * x

func fastAbs*(x: float32): float32 {.inline.} =
  type FU32 = object {.union.}
    f: float32
    u: uint32

  var h: FU32
  h.f = x
  h.u = h.u and 0x7fffffffu32
  result = h.f

when isMainModule:
  discard