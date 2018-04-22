import math
import divzero / [mathfn]

# --------------------------------------------------------------------------------------------------

func value_rand*(x: float32): float32 =
  ## [0..1]
  fract(sin(x) * 43758.5453123f)


func value_rand*(x, y: float32): float32 =
  ## [0..1]
  let d = x * 12.9898f + y * 78.233f
  fract(sin(d) * 43758.5453123f)


func value_noise_linear*(x: float32): float32 =
  ## [0..1]
  let i = floor(x)
  let f = fract(x)
  lerp(f, value_rand(i), value_rand(i + 1f))


func value_noise*(x: float32): float32 =
  ## [0..1]
  let i = floor(x)
  let f = fract(x)
  lerp(smoothstep(f, 0f, 1f), value_rand(i), value_rand(i + 1f))


func value_noise*(x, y: float32): float32 =
  ## [0..1]
  let ix = floor(x)
  let iy = floor(y)
  let fx = fract(x)
  let fy = fract(y)
  let a = value_rand(ix + 0f, iy + 0f)
  let b = value_rand(ix + 1f, iy + 0f)
  let c = value_rand(ix + 0f, iy + 1f)
  let d = value_rand(ix + 1f, iy + 1f)
  let ux = fx * fx * (3f - 2f * fx)
  let uy = fy * fy * (3f - 2f * fy)
  lerp(ux, a, b) + (c - a) * uy * (1f - ux) + (d - b) * ux * uy
