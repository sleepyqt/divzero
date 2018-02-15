import divzero / [color]

# --------------------------------------------------------------------------------------------------

type ImageFormat* = enum
  IF_NONE = 0
  IF_RGBA_8888 = 1
  IF_RGB_888 = 2
  IF_BGRA_8888 = 3
  IF_BGR_888 = 4
  IF_SRGBA_8888 = 5
  IF_SRGB_888 = 6
  IF_DXT3 = 7
  IF_GRAY_8 = 8


type ImageFlags* {.pure.} = enum
  Filter, GenMipmaps

# --------------------------------------------------------------------------------------------------

const ROW_ALIGNMENT = 4

type Image* = object
  width*, height*: int32      ## dimensions in pixels
  stride*: int32              ## size in bytes of single pixel
  pitch*: int32               ## size in bytes of single row of pixels, including padding
  size*: int32                ## size of image data in bytes
  format*: ImageFormat
  flags*: set[ImageFlags]
  data*: pointer              ## pointer to memory containing pixel data

# --------------------------------------------------------------------------------------------------

proc stride*(format: ImageFormat): int32 = int32([0, 4, 3, 4, 3, 4, 3, 0, 1][ord format])

proc roundup(x, v: int32): int32 {.inline.} = (x + (v - 1)) and not (v - 1)

# --------------------------------------------------------------------------------------------------

proc create_image*(width, height: int32; format: ImageFormat; flags: set[ImageFlags]): Image =
  result.width   = width
  result.height  = height
  result.stride  = stride(format)
  result.format  = format
  result.flags   = flags
  result.pitch   = roundup((result.width * result.stride), ROW_ALIGNMENT)
  result.size    = result.pitch * result.height
  result.data    = alloc(result.size)


proc destroy*(image: var Image) =
  assert(image.data != nil)
  image.data.dealloc()

# --------------------------------------------------------------------------------------------------

iterator bytes*(image: Image): uint8 =
  for i in 0 ..< image.size:
    let a = cast[pointer](cast[int](image.data) + i)
    yield cast[ptr uint8](a)[]


iterator mbytes*(image: var Image): ptr uint8 =
  for i in 0 ..< image.size:
    yield cast[ptr uint8](cast[int](image.data) + i * 1)


iterator words*(image: Image): uint16 =
  for i in 0 ..< (image.size div 2):
    let a = cast[pointer](cast[int](image.data) + i * 2)
    yield cast[ptr uint16](a)[]


iterator mwords*(image: var Image): ptr uint16 =
  for i in 0 ..< (image.size div 2):
    yield cast[ptr uint16](cast[int](image.data) + i * 2)


iterator dwords*(image: Image): uint32 =
  for i in 0 ..< (image.size div 4):
    let a = cast[pointer](cast[int](image.data) + i * 4)
    yield cast[ptr uint32](a)[]


iterator mdwords*(image: var Image): ptr uint32 =
  for i in 0 ..< (image.size div 4):
    yield cast[ptr uint32](cast[int](image.data) + i * 4)

# --------------------------------------------------------------------------------------------------

template sample2d(data: pointer; pitch, stride, x, y: int32): int =
  cast[int](data) + ((x * stride) + y * pitch)

# --------------------------------------------------------------------------------------------------

proc in_bounds*(image: Image; x, y: int32): bool =
  if x < 0: return
  if y < 0: return
  if x >= image.width: return
  if y >= image.height: return
  result = true


proc set_pixel*(image: var Image; x, y: int32; color: Color) =
  assert(image.data != nil)
  assert(in_bounds(image, x, y))
  let i = sample2d(image.data, image.pitch, image.stride, x, y)
  case image.format:
  of IF_RGBA_8888:
    cast[ptr uint32](i)[] = encode_abgr_8888(color)
  of IF_GRAY_8:
    cast[ptr uint8](i)[] = encode_gray_8(color)
  else:
    assert(false, "set_pixel: Unsupported image format")


proc get_pixel*(image: Image; x, y: int32): Color =
  assert(image.data != nil)
  assert(in_bounds(image, x, y))
  let i = sample2d(image.data, image.pitch, image.stride, x, y)
  case image.format:
  of IF_RGBA_8888:
    result = decode_abgr_8888(cast[ptr uint32](i)[])
  of IF_GRAY_8:
    result = decode_gray_8(cast[ptr uint8](i)[])
  else:
    assert(false, "get_pixel: Unsupported image format")


proc resize*(image: var Image; w, h: int32) =
  assert(w > 0)
  assert(h > 0)
  assert(image.format != IF_NONE)
  image.width  = w
  image.height = h
  image.pitch  = roundup((image.width * image.stride), ROW_ALIGNMENT)
  image.size   = image.pitch * image.height
  image.data   = realloc(image.data, image.size)

# --------------------------------------------------------------------------------------------------

proc clear*(image: var Image; color: Color) =
  assert(image.data != nil)
  case image.format:
  of IF_RGBA_8888:
    var d: uint32 = encode_abgr_8888(color)
    for pixel in mdwords(image): pixel[] = d
  of IF_GRAY_8:
    var d: uint8 = encode_gray_8(color)
    for pixel in mbytes(image): pixel[] = d
  else:
    assert(false, "clear: Unsupported image format")


proc print_ascii*(image: Image; x1, y1, x2, y2: int32) =
  for py in x1 ..< x2:
    for px in y1 ..< y2:
      let p = image.get_pixel(int32 px, int32 py)
      let u = p.encode_abgr_8888()
      let g = gray(p)
      stdout.write(if g.r < 0.5f: "X" else: ".")
    stdout.write("\n")
