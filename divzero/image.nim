import divzero / [color]

# --------------------------------------------------------------------------------------------------

type ImageFormat* {.pure.} = enum
  None
  RGBA_8888
  RGB_888
  BGRA_8888
  BGR_888
  SRGBA_8888
  SRGB_888
  DXT3


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

proc stride*(format: ImageFormat): int32 = int32([0, 4, 3, 4, 3, 4, 3, 0][int32(format)])

proc roundup(x, v: int32): int32 {.inline.} = (x + (v - 1)) and not (v - 1)

# --------------------------------------------------------------------------------------------------

proc create_image*(width, height: int32; format: ImageFormat; flags: set[ImageFlags]): Image =
  result.width   = width
  result.height  = height
  result.stride  = stride(format)
  result.format  = format
  result.flags   = flags
  result.size    = result.width * result.height * result.stride
  result.data    = alloc(result.size)
  result.pitch   = roundup((result.width * result.stride), ROW_ALIGNMENT)


proc destroy*(image: var Image) =
  assert(image.data != nil)

# --------------------------------------------------------------------------------------------------

iterator bytes*(image: Image): uint8 =
  for i in 0 ..< image.size:
    let a = cast[pointer](cast[int](image.data) + i)
    yield cast[ptr uint8](a)[]


iterator mbytes*(image: Image): var uint8 =
  for i in 0 ..< image.size:
    let a = cast[pointer](cast[int](image.data) + i)
    yield cast[ptr uint8](a)[]


iterator words*(image: Image): uint16 =
  for i in 0 ..< (image.size div 2):
    let a = cast[pointer](cast[int](image.data) + i * 2)
    yield cast[ptr uint16](a)[]


iterator mwords*(image: Image): var uint16 =
  for i in 0 ..< (image.size div 2):
    let a = cast[pointer](cast[int](image.data) + i * 2)
    yield cast[ptr uint16](a)[]


iterator dwords*(image: Image): uint32 =
  for i in 0 ..< (image.size div 4):
    let a = cast[pointer](cast[int](image.data) + i * 4)
    yield cast[ptr uint32](a)[]


iterator mdwords*(image: Image): ptr uint32 =
  for i in 0 ..< (image.size div 4):
    yield cast[ptr uint32](cast[int](image.data) + i * 4)

# --------------------------------------------------------------------------------------------------

template sample2d(data: pointer; pitch, stride, x, y: int32): int =
  cast[int](data) + ((x * stride) + y * pitch)

# --------------------------------------------------------------------------------------------------

proc set_pixel*(image: var Image; x, y: int32; color: Color) =
  case image.format:
  of IMAGE_FORMAT.RGBA_8888:
    let i = sample2d(image.data, image.pitch, image.stride, x, y)
    cast[ptr uint32](i)[] = encode_abgr_8888(color)
  else:
    assert(false, "set_pixel: Unsupported image format")


proc get_pixel*(image: Image; x, y: int32): Color =
  case image.format:
  of IMAGE_FORMAT.RGBA_8888:
    let i = sample2d(image.data, image.pitch, image.stride, x, y)
    result = decode_abgr_8888(cast[ptr uint32](i)[])
  else:
    assert(false, "set_pixel: Unsupported image format")

# --------------------------------------------------------------------------------------------------

proc clear*(image: var Image; color: Color) =
  case image.format:
  of IMAGE_FORMAT.RGBA_8888:
    var d: uint32 = encode_abgr_8888(color)
    for pixel in mdwords(image): pixel[] = d
  else:
    assert(false, "clear: Unsupported image format")
