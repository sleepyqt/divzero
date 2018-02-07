import math

# --------------------------------------------------------------------------------------------------

proc lerp*(t: float32; a, b: float32): float32 =
  result = (1f  - t) * a + t * b


proc smoothstep*(edge0, edge1, x: float32): float32 =
  let t = clamp((x - edge0) / (edge1 - edge0), 0f, 1f)
  result = t * t * (3f - 2f * t)


proc step*(edge, x: float32): float32 =
  result = if x < edge: 0f else: 1f
