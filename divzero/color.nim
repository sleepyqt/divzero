import std     / [math]
import divzero / [mathfn]

# --------------------------------------------------------------------------------------------------

type Color* = object
  r*, g*, b*, a*: float32

type SrgbColor* = Color

# --------------------------------------------------------------------------------------------------

func color*(r, g, b, a: float32): Color {.inline.} =
  result = Color(r: r, g: g, b: b, a: a)


func color*(hex: uint32): Color {.inline.} =
  let r = uint8((hex and 0xFF_00_00_00u32) shr 24)
  let g = uint8((hex and 0x00_FF_00_00u32) shr 16)
  let b = uint8((hex and 0x00_00_FF_00u32) shr 8)
  let a = uint8((hex and 0x00_00_00_FFu32) shr 0)
  result.r = float32(r) / 255.0f
  result.g = float32(g) / 255.0f
  result.b = float32(b) / 255.0f
  result.a = float32(a) / 255.0f


func color*(gray: float32): Color {.inline.} =
  result.r = gray
  result.g = gray
  result.b = gray
  result.a = 1f


func rgba8*(r, g, b, a: uint8): Color {.inline.} =
  result.r = float32(r) / 255.0f
  result.g = float32(g) / 255.0f
  result.b = float32(b) / 255.0f
  result.a = float32(a) / 255.0f

# --------------------------------------------------------------------------------------------------

proc shade*(c: Color; v: float32): Color =
  result.r = c.r * v
  result.g = c.g * v
  result.b = c.b * v
  result.a = c.a

# --------------------------------------------------------------------------------------------------

proc negative*(c: Color): Color =
  result.r = 1.0f - c.r
  result.g = 1.0f - c.g
  result.b = 1.0f - c.b
  result.a = c.a


proc gray*(c: Color): Color =
  let g: float32 = (c.r + c.g + c.b) / 3.0f
  result.r = g
  result.g = g
  result.b = g
  result.a = c.a


proc alpha*(c: Color; v: float32): Color =
  result.r = c.r
  result.g = c.g
  result.b = c.b
  result.a = c.a * v

# --------------------------------------------------------------------------------------------------

proc blend_multiply*(x, y: Color): Color =
  result.r = x.r * y.r
  result.g = x.g * y.g
  result.b = x.b * y.b
  result.a = x.a * y.a


proc blend_screen*(x, y: Color): Color =
  result.r = 1f - (1f - x.r) * (1f - y.r)
  result.g = 1f - (1f - x.g) * (1f - y.g)
  result.b = 1f - (1f - x.b) * (1f - y.b)
  result.a = 1f - (1f - x.a) * (1f - y.a)

# --------------------------------------------------------------------------------------------------

proc lerp*(t: float32; a, b: Color): Color =
  result.r = lerp(t, a.r, b.r)
  result.g = lerp(t, a.g, b.g)
  result.b = lerp(t, a.b, b.b)
  result.a = lerp(t, a.a, b.a)

# --------------------------------------------------------------------------------------------------

proc premultiply*(c: Color): Color =
  ## converts color with straight alpha to premultiplied alpha
  result.r = c.r * c.a
  result.g = c.g * c.a
  result.b = c.b * c.a
  result.a = c.a

# --------------------------------------------------------------------------------------------------

proc to_linear*(cs: float32): float32 =
  if cs < 0.04045f:
    cs * (1f / 12.92f)
  else:
    pow((cs + 0.055f) * (1f / 1.055f), 2.4f)


proc to_srgb*(cl: float32): float32 =
  let c = clamp(cl, 0f, 1f)
  let X = 12.92f * c
  let Y = 1.055f * pow(c, 0.4166f) - 0.055f
  if c >= 0.0031308f: Y else: X


proc to_linear*(color: SrgbColor): Color =
  result.r = to_linear(color.r)
  result.g = to_linear(color.g)
  result.b = to_linear(color.b)
  result.a = color.a


proc to_srgb*(color: Color): SrgbColor =
  result.r = to_srgb(color.r)
  result.g = to_srgb(color.g)
  result.b = to_srgb(color.b)
  result.a = color.a

# --------------------------------------------------------------------------------------------------

proc encode_abgr_8888*(color: Color): uint32 =
  # layout:
  #  MSB       LSB
  #  0xAA-BB-GG-RR
  let r: uint32 = (uint32(color.r * 255f) shl 00) and 0x00_00_00_FFu32
  let g: uint32 = (uint32(color.g * 255f) shl 08) and 0x00_00_FF_00u32
  let b: uint32 = (uint32(color.b * 255f) shl 16) and 0x00_FF_00_00u32
  let a: uint32 = (uint32(color.a * 255f) shl 24) and 0xFF_00_00_00u32
  result = r or g or b or a


proc decode_abgr_8888*(color: uint32): Color =
  # 0xAA-BB-GG-RR
  let r: uint32 = (color shr 00) and 0x00_00_00_FFu32
  let g: uint32 = (color shr 08) and 0x00_00_00_FFu32
  let b: uint32 = (color shr 16) and 0x00_00_00_FFu32
  let a: uint32 = (color shr 24) and 0x00_00_00_FFu32
  const inv = 1f / 255f
  result.r = float32(r) * inv
  result.g = float32(g) * inv
  result.b = float32(b) * inv
  result.a = float32(a) * inv


proc encode_bgr_888*(color: Color): uint32 =
  # layout: 0xBB-GG-RR
  let r: uint32 = (uint32(color.r * 255f) shl 00) and 0x00_00_00_FFu32
  let g: uint32 = (uint32(color.g * 255f) shl 08) and 0x00_00_FF_00u32
  let b: uint32 = (uint32(color.b * 255f) shl 16) and 0x00_FF_00_00u32
  result = r or g or b


proc decode_bgr_888*(color: uint32): Color =
  let r: uint32 = (color shr 24) and 0x00_00_00_FFu32
  let g: uint32 = (color shr 16) and 0x00_00_00_FFu32
  let b: uint32 = (color shr 08) and 0x00_00_00_FFu32
  const inv = 1f / 255f
  result.r = float32(r) * inv
  result.g = float32(g) * inv
  result.b = float32(b) * inv
  result.a = 1f


proc encode_rgba_8888*(color: Color): uint32 =
  # layout:
  #  MSB       LSB
  #  0xRR-GG-BB-AA
  let r: uint32 = (uint32(color.r * 255f) shl 24) and 0xFF_00_00_00u32
  let g: uint32 = (uint32(color.g * 255f) shl 16) and 0x00_FF_00_00u32
  let b: uint32 = (uint32(color.b * 255f) shl 08) and 0x00_00_FF_00u32
  let a: uint32 = (uint32(color.a * 255f) shl 00) and 0x00_00_00_FFu32
  result = r or g or b or a


proc decode_rgba_8888*(color: uint32): Color =
  let r: uint32 = (color shr 00) and 0x00_00_00_FFu32
  let g: uint32 = (color shr 08) and 0x00_00_00_FFu32
  let b: uint32 = (color shr 16) and 0x00_00_00_FFu32
  let a: uint32 = (color shr 24) and 0x00_00_00_FFu32
  const inv = 1f / 255f
  result.r = float32(r) * inv
  result.g = float32(g) * inv
  result.b = float32(b) * inv
  result.a = float32(a) * inv


proc encode_gray_8*(color: Color): uint8 =
  let g: uint8 = uint8(color.gray.r * 255f)
  result = g


proc decode_gray_8*(color: uint8): Color =
  let g: float32 = float32(color) / 255f
  result.r = g
  result.g = g
  result.b = g
  result.a = 1f

# --------------------------------------------------------------------------------------------------

const
  # VGA 16 colors
  COLOR_BLACK*                  = color(0.00f, 0.00f, 0.00f, 1.00f).to_linear
  COLOR_BLUE*                   = color(0.00f, 0.00f, 0.66f, 1.00f).to_linear
  COLOR_GREEN*                  = color(0.00f, 0.66f, 0.00f, 1.00f).to_linear
  COLOR_CYAN*                   = color(0.00f, 0.66f, 0.66f, 1.00f).to_linear
  COLOR_RED*                    = color(0.66f, 0.00f, 0.00f, 1.00f).to_linear
  COLOR_MAGENTA*                = color(0.66f, 0.00f, 0.66f, 1.00f).to_linear
  COLOR_BROWN*                  = color(0.66f, 0.33f, 0.00f, 1.00f).to_linear
  COLOR_LIGHT_GRAY*             = color(0.66f, 0.66f, 0.66f, 1.00f).to_linear
  COLOR_GRAY*                   = color(0.33f, 0.33f, 0.33f, 1.00f).to_linear
  COLOR_LIGHT_BLUE*             = color(0.33f, 0.33f, 1.00f, 1.00f).to_linear
  COLOR_LIGHT_GREEN*            = color(0.33f, 1.00f, 0.33f, 1.00f).to_linear
  COLOR_LIGHT_CYAN*             = color(0.33f, 1.00f, 1.00f, 1.00f).to_linear
  COLOR_LIGHT_RED*              = color(1.00f, 0.33f, 0.33f, 1.00f).to_linear
  COLOR_LIGHT_MAGENTA*          = color(1.00f, 0.33f, 1.00f, 1.00f).to_linear
  COLOR_YELLOW*                 = color(1.00f, 1.00f, 0.33f, 1.00f).to_linear
  COLOR_WHITE*                  = color(1.00f, 1.00f, 1.00f, 1.00f).to_linear

const
  COLOR_PINK*                   = color(1.00f, 0.00f, 1.00f, 1.00f).to_linear

const
  COLOR_MONOKAI_BLACK*          = color(0x272822ffu32).to_linear
  COLOR_MONOKAI_RED*            = color(0xf92672ffu32).to_linear
  COLOR_MONOKAI_GREEN*          = color(0xa6e22effu32).to_linear
  COLOR_MONOKAI_YELLOW*         = color(0xf4bf75ffu32).to_linear
  COLOR_MONOKAI_BLUE*           = color(0x66d9efffu32).to_linear
  COLOR_MONOKAI_MAGENTA*        = color(0xae81ffffu32).to_linear
  COLOR_MONOKAI_CYAN*           = color(0xa1efe4ffu32).to_linear
  COLOR_MONOKAI_WHITE*          = color(0xf8f8f2ffu32).to_linear

# --------------------------------------------------------------------------------------------------

proc selftest* =
  assert color(0xFF000000u32) == color(1f, 0f, 0f, 0f)
  assert color(0x00FF0000u32) == color(0f, 1f, 0f, 0f)
  assert color(0x0000FF00u32) == color(0f, 0f, 1f, 0f)
  assert color(0x000000FFu32) == color(0f, 0f, 0f, 1f)
  assert color(0xFFFFFFFFu32) == color(1f, 1f, 1f, 1f)
  assert color(0x00000000u32) == color(0f, 0f, 0f, 0f)
  assert color(0xFF0000FFu32) == color(1f, 0f, 0f, 1f)
  #assert encode_abgr_8888(COLOR_RED) == 0xFF0000FFu32
