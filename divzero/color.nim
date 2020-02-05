import std / [math]
import divzero / [mathfn]

type
  Color* = object
    r*, g*, b*, a*: float32

  SrgbColor* = Color

  BlendFn* = proc (s, d: Color): Color

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

func color*(r, g, b, a: uint8): Color {.inline.} =
  result.r = float32(r) / 255.0f
  result.g = float32(g) / 255.0f
  result.b = float32(b) / 255.0f
  result.a = float32(a) / 255.0f

func shade*(c: Color; v: float32): Color =
  result.r = c.r * v
  result.g = c.g * v
  result.b = c.b * v
  result.a = c.a

func negative*(c: Color): Color =
  result.r = 1.0f - c.r
  result.g = 1.0f - c.g
  result.b = 1.0f - c.b
  result.a = c.a

func gray*(c: Color): float32 =
  (c.r + c.g + c.b) / 3.0f

func alpha*(c: Color; v: float32): Color =
  result.r = c.r
  result.g = c.g
  result.b = c.b
  result.a = c.a * v

func blendStraightAlpha*(s, d: Color): Color =
  result.r = (s.r * s.a) + (d.r * (1f - s.a))
  result.g = (s.g * s.a) + (d.g * (1f - s.a))
  result.b = (s.b * s.a) + (d.b * (1f - s.a))
  result.a = (s.a * s.a) + 1f - s.a

func blendPremultiplyAlpha*(s, d: Color): Color =
  result.r = s.r + (d.r * (1f - s.a))
  result.g = s.g + (d.g * (1f - s.a))
  result.b = s.b + (d.b * (1f - s.a))
  result.a = s.a + 1f - s.a

func blendMultiply*(x, y: Color): Color =
  result.r = x.r * y.r
  result.g = x.g * y.g
  result.b = x.b * y.b
  result.a = x.a * y.a

func blendScreen*(x, y: Color): Color =
  result.r = 1f - (1f - x.r) * (1f - y.r)
  result.g = 1f - (1f - x.g) * (1f - y.g)
  result.b = 1f - (1f - x.b) * (1f - y.b)
  result.a = 1f - (1f - x.a) * (1f - y.a)

func lerp*(t: float32; a, b: Color): Color =
  result.r = lerp(t, a.r, b.r)
  result.g = lerp(t, a.g, b.g)
  result.b = lerp(t, a.b, b.b)
  result.a = lerp(t, a.a, b.a)

func premultiply*(c: Color): Color =
  ## converts color with straight alpha to premultiplied alpha
  result.r = c.r * c.a
  result.g = c.g * c.a
  result.b = c.b * c.a
  result.a = c.a

func toLinear*(cs: float32): float32 =
  if cs < 0.04045f:
    cs * (1f / 12.92f)
  else:
    pow((cs + 0.055f) * (1f / 1.055f), 2.4f)

func toSrgb*(cl: float32): float32 =
  let c = clamp(cl, 0f, 1f)
  let X = 12.92f * c
  let Y = 1.055f * pow(c, 0.4166f) - 0.055f
  if c >= 0.0031308f: Y else: X

func toLinear*(color: SrgbColor): Color =
  result.r = toLinear(color.r)
  result.g = toLinear(color.g)
  result.b = toLinear(color.b)
  result.a = color.a

func toSrgb*(color: Color): SrgbColor =
  result.r = to_srgb(color.r)
  result.g = to_srgb(color.g)
  result.b = to_srgb(color.b)
  result.a = color.a

func encodeAbgr8888*(color: Color): uint32 =
  # layout:
  #  MSB       LSB
  #  0xAA-BB-GG-RR
  let r: uint32 = (uint32(color.r * 255f) shl 00) and 0x00_00_00_FFu32
  let g: uint32 = (uint32(color.g * 255f) shl 08) and 0x00_00_FF_00u32
  let b: uint32 = (uint32(color.b * 255f) shl 16) and 0x00_FF_00_00u32
  let a: uint32 = (uint32(color.a * 255f) shl 24) and 0xFF_00_00_00u32
  result = r or g or b or a

func decodeAbgr8888*(color: uint32): Color =
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

func encodeBgr888*(color: Color): uint32 =
  # layout: 0xBB-GG-RR
  let r: uint32 = (uint32(color.r * 255f) shl 00) and 0x00_00_00_FFu32
  let g: uint32 = (uint32(color.g * 255f) shl 08) and 0x00_00_FF_00u32
  let b: uint32 = (uint32(color.b * 255f) shl 16) and 0x00_FF_00_00u32
  result = r or g or b

func decodeBgr888*(color: uint32): Color =
  let r: uint32 = (color shr 24) and 0x00_00_00_FFu32
  let g: uint32 = (color shr 16) and 0x00_00_00_FFu32
  let b: uint32 = (color shr 08) and 0x00_00_00_FFu32
  const inv = 1f / 255f
  result.r = float32(r) * inv
  result.g = float32(g) * inv
  result.b = float32(b) * inv
  result.a = 1f

func encodeRgba8888*(color: Color): uint32 =
  # layout:
  #  MSB       LSB
  #  0xRR-GG-BB-AA
  let r: uint32 = (uint32(color.r * 255f) shl 24) and 0xFF_00_00_00u32
  let g: uint32 = (uint32(color.g * 255f) shl 16) and 0x00_FF_00_00u32
  let b: uint32 = (uint32(color.b * 255f) shl 08) and 0x00_00_FF_00u32
  let a: uint32 = (uint32(color.a * 255f) shl 00) and 0x00_00_00_FFu32
  result = r or g or b or a

func decodeRgba8888*(color: uint32): Color =
  let r: uint32 = (color shr 00) and 0x00_00_00_FFu32
  let g: uint32 = (color shr 08) and 0x00_00_00_FFu32
  let b: uint32 = (color shr 16) and 0x00_00_00_FFu32
  let a: uint32 = (color shr 24) and 0x00_00_00_FFu32
  const inv = 1f / 255f
  result.r = float32(r) * inv
  result.g = float32(g) * inv
  result.b = float32(b) * inv
  result.a = float32(a) * inv

func encodeGray8*(color: float32): uint8 =
  uint8(color * 255f)

func decodeGray8*(color: uint8): float32 =
  float32(color) / 255f

func encodeGray16*(color: float32): uint16 =
  uint16(color * 65535f)

func decodeGray16*(color: uint16): float32 =
  float32(color) / 65535f

const
  # vga 16 colors
  colorBlack* = color(0.00f, 0.00f, 0.00f, 1.00f).toLinear
  colorBlue* = color(0.00f, 0.00f, 0.66f, 1.00f).toLinear
  colorGreen* = color(0.00f, 0.66f, 0.00f, 1.00f).toLinear
  colorCyan* = color(0.00f, 0.66f, 0.66f, 1.00f).toLinear
  colorRed* = color(0.66f, 0.00f, 0.00f, 1.00f).toLinear
  colorMagenta* = color(0.66f, 0.00f, 0.66f, 1.00f).toLinear
  colorBrown* = color(0.66f, 0.33f, 0.00f, 1.00f).toLinear
  colorLightGray* = color(0.66f, 0.66f, 0.66f, 1.00f).toLinear
  colorGray* = color(0.33f, 0.33f, 0.33f, 1.00f).toLinear
  colorLightBlue* = color(0.33f, 0.33f, 1.00f, 1.00f).toLinear
  colorLightGreen* = color(0.33f, 1.00f, 0.33f, 1.00f).toLinear
  colorLightCyan* = color(0.33f, 1.00f, 1.00f, 1.00f).toLinear
  colorLightRed* = color(1.00f, 0.33f, 0.33f, 1.00f).toLinear
  colorLightMagenta* = color(1.00f, 0.33f, 1.00f, 1.00f).toLinear
  colorYellow* = color(1.00f, 1.00f, 0.33f, 1.00f).toLinear
  colorWhite* = color(1.00f, 1.00f, 1.00f, 1.00f).toLinear

const
  colorMonokaiBlack* = color(0x272822ffu32).toLinear
  colorMonokaiRed* = color(0xf92672ffu32).toLinear
  colorMonokaiGreen* = color(0xa6e22effu32).toLinear
  colorMonokaiYellow* = color(0xf4bf75ffu32).toLinear
  colorMonokaiBlue* = color(0x66d9efffu32).toLinear
  colorMonokaiMagenta* = color(0xae81ffffu32).toLinear
  colorMonokaiCyan* = color(0xa1efe4ffu32).toLinear
  colorMonokaiWhite* = color(0xf8f8f2ffu32).toLinear

when isMainModule:
  doAssert color(0xFF000000u32) == color(1f, 0f, 0f, 0f)
  doAssert color(0x00FF0000u32) == color(0f, 1f, 0f, 0f)
  doAssert color(0x0000FF00u32) == color(0f, 0f, 1f, 0f)
  doAssert color(0x000000FFu32) == color(0f, 0f, 0f, 1f)
  doAssert color(0xFFFFFFFFu32) == color(1f, 1f, 1f, 1f)
  doAssert color(0x00000000u32) == color(0f, 0f, 0f, 0f)
  doAssert color(0xFF0000FFu32) == color(1f, 0f, 0f, 1f)
