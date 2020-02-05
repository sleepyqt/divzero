import divzero / [color]

type ImageFormat* = enum
  IfGray8,
  IfGray16,
  IfABGR8888,
  IfSABGR8888,
  IfBGR888,
  IfSBGR888,

const format_stride* = [
  1, # gray8
  2, # gray16
  4, # abgr8888
  4, # sabgr8888
  3, # bgr888
  3, # sbgr888
]

type
  Image2d* = object
    format*: ImageFormat
    width*, height*: int32      ## dimensions in pixels
    stride*: int32              ## size in bytes of single pixel
    pitch*: int32               ## size in bytes of single row of pixels, including padding
    size*: int32                ## size of image data in bytes
    data*: pointer              ## pointer to memory containing pixel data

  MipChain* = array[16, int] ## offsets into Image2d.data

template roundup(x, v: int32): int32 = (x + (v - 1)) and not (v - 1)

proc initImage*(width, height: int32; format: ImageFormat; data: pointer; rowAlignment = 4): Image2d =
  assert(width > 0 and height > 0)
  result.width  = width
  result.height = height
  result.stride = int32 format_stride[ord format]
  result.format = format
  result.pitch  = roundup((result.width * result.stride), int32(rowAlignment))
  result.size   = result.pitch * result.height
  result.data   = data

proc allocImage*(width, height: int32; format: ImageFormat; rowAlignment = 4): Image2d =
  result = initImage(width, height, format, nil, rowAlignment)
  result.data = alloc(result.size)

proc destroy*(image: var Image2d) =
  assert(image.data != nil)
  image.data.dealloc()

proc inBounds*(image: Image2d; x, y: int32): bool =
  (x >= 0) and (y >= 0) and (x < image.width) and (y < image.height)

proc row*(image: Image2d; y: int; T: typedesc): ptr UncheckedArray[T] =
  cast[ptr UncheckedArray[T]](cast[int](image.data) + y * image.pitch)

# Gray 8

proc setPixelGray8*(image: var Image2d; x, y: int32; color: uint8) =
  assert(inBounds(image, x, y))
  image.row(y, uint8)[x] = color

proc getPixelGray8*(image: Image2d; x, y: int32): uint8 =
  assert(inBounds(image, x, y))
  image.row(y, uint8)[x]

iterator xyPixelsGray8*(image: Image2d): (int32, int32, uint8) =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield (x, y, image.row(y, uint8)[x])

iterator xyMPixelsGray8*(image: var Image2d): (int32, int32, var uint8) =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield (x, y, image.row(y, uint8)[x])

iterator pixelsGray8*(image: Image2d): uint8 =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield image.row(y, uint8)[x]

iterator mPixelsGray8*(image: var Image2d): var uint8 =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield image.row(y, uint8)[x]

proc clearGray8*(image: var Image2d; color: uint8) =
  for p in mpixelsGray8(image):
    p = color

# Gray 16

proc setPixelGray16*(image: var Image2d; x, y: int32; color: uint16) =
  assert(inBounds(image, x, y))
  image.row(y, uint16)[x] = color

proc getPixelGray16*(image: Image2d; x, y: int32): uint16 =
  assert(inBounds(image, x, y))
  image.row(y, uint16)[x]

iterator xyPixelsGray16*(image: Image2d): (int32, int32, uint16) =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield (x, y, image.row(y, uint16)[x])

iterator xyMpixelsGray16*(image: var Image2d): (int32, int32, var uint16) =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield (x, y, image.row(y, uint16)[x])

iterator pixelsGray16*(image: Image2d): uint16 =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield image.row(y, uint16)[x]

iterator mpixelsGray16*(image: var Image2d): var uint16 =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield image.row(y, uint16)[x]

proc clearGray16*(image: var Image2d; color: uint16) =
  for p in mpixelsGray16(image):
    p = color

# ABGR 8888

proc setPixelAbgr8888*(image: var Image2d; x, y: int32; color: uint32) =
  assert(inBounds(image, x, y))
  image.row(y, uint32)[x] = color

proc getPixelAbgr8888*(image: Image2d; x, y: int32): uint32 =
  assert(inBounds(image, x, y))
  image.row(y, uint32)[x]

iterator xyPixelsAbgr8888*(image: Image2d): (int32, int32, uint32) =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield (x, y, image.row(y, uint32)[x])

iterator xyMPixelsAbgr8888*(image: var Image2d): (int32, int32, var uint32) =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield (x, y, image.row(y, uint32)[x])

iterator pixelsAbgr8888*(image: Image2d): uint32 =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield image.row(y, uint32)[x]

iterator mPixelsAbgr8888*(image: var Image2d): var uint32 =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield image.row(y, uint32)[x]

proc clearAbgr8888*(image: var Image2d; color: uint32) =
  for p in mpixelsAbgr8888(image):
    p = color

# BGR 888

# sABGR 8888

# sBGR 888

# Generic

proc setPixel*(image: var Image2d; x, y: int32; color: Color) =
  case image.format:
  of IfGray8:    image.setPixelGray8(x, y, color.gray.encodeGray8)
  of IfGray16:   image.setPixelGray16(x, y, color.gray.encodeGray16)
  of IfAbgr8888: image.setPixelAbgr8888(x, y, color.encodeAbgr8888)
  else: doAssert(false, "setPixel: unsupported image format")

proc getPixel*(image: Image2d; x, y: int32): Color =
  case image.format:
  of IfGray8:    result = image.getPixelGray8(x, y).decodeGray8.color
  of IfGray16:   result = image.getPixelGray16(x, y).decodeGray16.color
  of IfAbgr8888: result = image.getPixelAbgr8888(x, y).decodeAbgr8888
  else: doAssert(false, "getPixel: unsupported image format")

proc setPixelSafe*(image: var Image2d; x, y: int32; color: Color) =
  if image.inBounds(x, y):
    image.setPixel(x, y, color)

proc getPixelSafe*(image: Image2d; x, y: int32): Color =
  if image.inBounds(x, y):
    result = image.getPixel(x, y)
  else:
    result = colorBlue

proc blendPixel*(image: var Image2d; x, y: int32; src: Color; blend: BlendFn) =
  let dst = image.getPixel(x, y)
  image.setPixel(x, y, blend(s = src, d = dst))

proc blendPixelSafe*(image: var Image2d; x, y: int32; color: Color; blend: BlendFn) =
  if image.inBounds(x, y):
    image.blendPixel(x, y, color, blend)

iterator xyPixels*(image: Image2d): (int32, int32, Color) =
  case image.format:
  of IfGray8:    (for x, y, p in image.xyPixelsGray8: yield (x, y, p.decodeGray8.color))
  of IfGray16:   (for x, y, p in image.xyPixelsGray16: yield (x, y, p.decodeGray16.color))
  of IfAbgr8888: (for x, y, p in image.xyPixelsAbgr8888: yield (x, y, p.decodeAbgr8888))
  else: doAssert(false, "xyPixels: unsupported image format")

iterator xy*(image: Image2d): (int32, int32) =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield (x, y)

proc clear*(image: var Image2d; color: Color) =
  case image.format:
  of IfGray8:    image.clearGray8(color.gray.encodeGray8)
  of IfGray16:   image.clearGray16(color.gray.encodeGray16)
  of IfAbgr8888: image.clearAbgr8888(color.encodeAbgr8888)
  else: doAssert(false, "clear: unsupported image format")

proc premultiplyAlpha*(image: var Image2d) =
  for x, y, color in image.xyPixels:
    image.setPixel(x, y, color.premultiply)

proc drawLine*(image: var Image2d; x0, y0, x1, y1: int32; color: Color) =
  var x0 = x0
  var y0 = y0
  let dx = abs(x1 - x0)
  let sx = if x0 < x1: 1i32 else: -1i32
  let dy = -abs(y1 - y0)
  let sy = if y0 < y1: 1i32 else: -1i32
  var err = dx + dy
  let color = color.premultiply
  while true:
    image.blendPixelSafe(x0, y0, color, blendPremultiplyAlpha)
    if x0 == x1 and y0 == y1: break
    let e2 = 2 * err
    if e2 >= dy:
      err += dy
      x0 += sx
    if e2 <= dx:
      err += dx
      y0 += sy

proc drawCircle*(image: var Image2d; cx, cy, radius: int32; color: Color) =
  ## renders circle centered at point cx, cy
  var x0 = cx
  var y0 = cy
  var f = 1i32 - radius
  var ddfX = 1i32
  var ddfY = -2i32 * radius
  var x = 0i32
  var y = radius
  let color = color.premultiply
  image.blendPixelSafe(x0, y0 + radius, color, blendPremultiplyAlpha)
  image.blendPixelSafe(x0, y0 - radius, color, blendPremultiplyAlpha)
  image.blendPixelSafe(x0 + radius, y0, color, blendPremultiplyAlpha)
  image.blendPixelSafe(x0 - radius, y0, color, blendPremultiplyAlpha)
  while x < y:
    if f >= 0: (dec(y); inc(ddfY, 2); inc(f, ddfY))
    inc(x); inc(ddfX, 2); inc(f, ddfX)
    image.blendPixelSafe(x0 + x, y0 + y, color, blendPremultiplyAlpha)
    image.blendPixelSafe(x0 - x, y0 + y, color, blendPremultiplyAlpha)
    image.blendPixelSafe(x0 + x, y0 - y, color, blendPremultiplyAlpha)
    image.blendPixelSafe(x0 - x, y0 - y, color, blendPremultiplyAlpha)
    image.blendPixelSafe(x0 + y, y0 + x, color, blendPremultiplyAlpha)
    image.blendPixelSafe(x0 - y, y0 + x, color, blendPremultiplyAlpha)
    image.blendPixelSafe(x0 + y, y0 - x, color, blendPremultiplyAlpha)
    image.blendPixelSafe(x0 - y, y0 - x, color, blendPremultiplyAlpha)

proc fillRectangle*(image: var Image2d; x, y, w, h: int32; color: Color) =
  let x0 = max(x, 0)
  let y0 = max(y, 0)
  let x1 = min(x + w - 1, image.width - 1)
  let y1 = min(y + h - 1, image.height - 1)
  let color = color.premultiply
  for x in x0 .. x1:
    for y in y0 .. y1:
      image.blendPixel(x, y, color, blendPremultiplyAlpha)

when isMainModule:
  block:
    var img = allocImage(8, 8, IfGray8)

    setPixelGray8(img, 0, 0, 101)
    doAssert(getPixelGray8(img, 0, 0) == 101)

    setPixelGray8(img, 3, 0, 102)
    doAssert(getPixelGray8(img, 3, 0) == 102)

    setPixelGray8(img, 3, 2, 103)
    doAssert(getPixelGray8(img, 3, 2) == 103)

    setPixelGray8(img, 7, 7, 104)
    doAssert(getPixelGray8(img, 7, 7) == 104)

    for x, y, p in xyMpixelsGray8(img):
      p = uint8(x xor y)

    for x, y, p in xyPixelsGray8(img):
      doAssert(p == uint8(x xor y))

    img.clearGray8(123u8)

    for x, y, p in xyPixelsGray8(img):
      doAssert(p == 123u8)

    img.setPixel(2, 2, COLOR_WHITE)
    doAssert(img.getPixel(2, 2) == COLOR_WHITE)

    img.setPixel(2, 3, COLOR_BLACK)
    doAssert(img.getPixel(2, 3) == COLOR_BLACK)

    img.destroy()

  block:
    var img = allocImage(8, 8, IfAbgr8888)

    setPixelAbgr8888(img, 0, 0, 0xAABBCCDDu32)
    doAssert(getPixelAbgr8888(img, 0, 0) == 0xAABBCCDDu32)

    setPixelAbgr8888(img, 3, 2, 0xDEADBEEFu32)
    doAssert(getPixelAbgr8888(img, 3, 2) == 0xDEADBEEFu32)

    setPixelAbgr8888(img, 7, 7, 0xCAFEBABEu32)
    doAssert(getPixelAbgr8888(img, 7, 7) == 0xCAFEBABEu32)

    for x, y, p in xyMpixelsAbgr8888(img):
      p = uint32(x xor y)

    for x, y, p in xyPixelsAbgr8888(img):
      doAssert(p == uint32(x xor y))

    #img.setPixel(2, 3, COLOR_RED)
    #echo COLOR_RED
    #echo img.getPixel(2, 3)

    img.destroy()

  echo "ok"
