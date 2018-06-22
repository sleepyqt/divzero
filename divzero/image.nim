import divzero / [color]

# --------------------------------------------------------------------------------------------------

type ImageFormat* {.pure.} = enum
  gray_8
  abgr_8888
  bgr_888
  sabgr_8888
  sbgr_888
  gray_16

const format_stride* = [
  1, # gray_8
  4, # abgr_8888
  3, # bgr_888
  4, # sabgr_8888
  3, # sbgr_888
  2, # gray_16
]

# --------------------------------------------------------------------------------------------------

const row_alignment = 4

type Image2d* = object
  format*: ImageFormat
  width*, height*: int32      ## dimensions in pixels
  stride*: int32              ## size in bytes of single pixel
  pitch*: int32               ## size in bytes of single row of pixels, including padding
  size*: int32                ## size of image data in bytes
  data*: pointer              ## pointer to memory containing pixel data


type MipChain* = array[16, int] ## offsets into Image2d.data

# --------------------------------------------------------------------------------------------------

template roundup(x, v: int32): int32 = (x + (v - 1)) and not (v - 1)

# --------------------------------------------------------------------------------------------------

proc init_image*(width, height: int32; format: ImageFormat; data: pointer): Image2d =
  assert(width > 0 and height > 0)
  result.width  = width
  result.height = height
  result.stride = int32 format_stride[ord format]
  result.format = format
  result.pitch  = roundup((result.width * result.stride), row_alignment)
  result.size   = result.pitch * result.height
  result.data   = data


proc init_image*(width, height: int32; format: ImageFormat): Image2d =
  result = init_image(width, height, format, nil)
  result.data = alloc(result.size)


proc destroy*(image: var Image2d) =
  assert(image.data != nil)
  image.data.dealloc()

# --------------------------------------------------------------------------------------------------

proc in_bounds*(image: Image2d; x, y: int32): bool =
  (x >= 0) and (y >= 0) and (x < image.width) and (y < image.height)


proc row*(image: Image2d; y: int; T: typedesc): ptr UncheckedArray[T] =
  cast[ptr UncheckedArray[T]](cast[int](image.data) + y * image.pitch)

# --------------------------------------------------------------------------------------------------

proc set_pixel_gray_8*(image: var Image2d; x, y: int32; color: uint8) =
  assert(in_bounds(image, x, y))
  image.row(y, uint8)[x] = color


proc get_pixel_gray_8*(image: Image2d; x, y: int32): uint8 =
  assert(in_bounds(image, x, y))
  image.row(y, uint8)[x]


iterator xy_pixels_gray_8*(image: Image2d): (int32, int32, uint8) =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield (x, y, image.row(y, uint8)[x])


iterator xy_mpixels_gray_8*(image: var Image2d): (int32, int32, var uint8) =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield (x, y, image.row(y, uint8)[x])


iterator pixels_gray_8*(image: Image2d): uint8 =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield image.row(y, uint8)[x]


iterator mpixels_gray_8*(image: var Image2d): var uint8 =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield image.row(y, uint8)[x]


proc clear_gray_8*(image: var Image2d; color: uint8) =
  for p in mpixels_gray_8(image):
    p = color

# --------------------------------------------------------------------------------------------------

proc set_pixel_gray_16*(image: var Image2d; x, y: int32; color: uint16) =
  assert(in_bounds(image, x, y))
  image.row(y, uint16)[x] = color


proc get_pixel_gray_16*(image: Image2d; x, y: int32): uint16 =
  assert(in_bounds(image, x, y))
  image.row(y, uint16)[x]


iterator xy_pixels_gray_16*(image: Image2d): (int32, int32, uint16) =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield (x, y, image.row(y, uint16)[x])


iterator xy_mpixels_gray_16*(image: var Image2d): (int32, int32, var uint16) =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield (x, y, image.row(y, uint16)[x])


iterator pixels_gray_16*(image: Image2d): uint16 =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield image.row(y, uint16)[x]


iterator mpixels_gray_16*(image: var Image2d): var uint16 =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield image.row(y, uint16)[x]


proc clear_gray_16*(image: var Image2d; color: uint16) =
  for p in mpixels_gray_16(image):
    p = color

# --------------------------------------------------------------------------------------------------

proc set_pixel_abgr_8888*(image: var Image2d; x, y: int32; color: uint32) =
  assert(in_bounds(image, x, y))
  image.row(y, uint32)[x] = color


proc get_pixel_abgr_8888*(image: Image2d; x, y: int32): uint32 =
  assert(in_bounds(image, x, y))
  image.row(y, uint32)[x]


iterator xy_pixels_abgr_8888*(image: Image2d): (int32, int32, uint32) =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield (x, y, image.row(y, uint32)[x])


iterator xy_mpixels_abgr_8888*(image: var Image2d): (int32, int32, var uint32) =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield (x, y, image.row(y, uint32)[x])


iterator pixels_abgr_8888*(image: Image2d): uint32 =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield image.row(y, uint32)[x]


iterator mpixels_abgr_8888*(image: var Image2d): var uint32 =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield image.row(y, uint32)[x]


proc clear_abgr_8888*(image: var Image2d; color: uint32) =
  for p in mpixels_abgr_8888(image):
    p = color

# --------------------------------------------------------------------------------------------------

proc set_pixel*(image: var Image2d; x, y: int32; color: Color) =
  case image.format:
  of ImageFormat.gray_8:    image.set_pixel_gray_8(x, y, color.gray.encode_gray_8)
  of ImageFormat.gray_16:   image.set_pixel_gray_16(x, y, color.gray.encode_gray_16)
  of ImageFormat.abgr_8888: image.set_pixel_abgr_8888(x, y, color.encode_abgr_8888)
  else: do_assert(false, "set_pixel: unsupported image format")


proc get_pixel*(image: var Image2d; x, y: int32): Color =
  case image.format:
  of ImageFormat.gray_8:    result = image.get_pixel_gray_8(x, y).decode_gray_8.color
  of ImageFormat.gray_16:   result = image.get_pixel_gray_16(x, y).decode_gray_16.color
  of ImageFormat.abgr_8888: result = image.get_pixel_abgr_8888(x, y).decode_abgr_8888
  else: do_assert(false, "get_pixel: unsupported image format")


iterator xy_pixels*(image: Image2d): (int32, int32, Color) =
  case image.format:
  of ImageFormat.gray_8:    (for x, y, p in image.xy_pixels_gray_8: yield (x, y, p.decode_gray_8.color))
  of ImageFormat.gray_16:   (for x, y, p in image.xy_pixels_gray_16: yield (x, y, p.decode_gray_16.color))
  of ImageFormat.abgr_8888: (for x, y, p in image.xy_pixels_abgr_8888: yield (x, y, p.decode_abgr_8888))
  else: do_assert(false, "xy_pixels: unsupported image format")


iterator xy*(image: Image2d): (int32, int32) =
  for y in 0i32 ..< image.height:
    for x in 0i32 ..< image.width:
      yield (x, y)


proc clear*(image: var Image2d; color: Color) =
  case image.format:
  of ImageFormat.gray_8:    image.clear_gray_8(color.gray.encode_gray_8)
  of ImageFormat.gray_16:   image.clear_gray_16(color.gray.encode_gray_16)
  of ImageFormat.abgr_8888: image.clear_abgr_8888(color.encode_abgr_8888)
  else: do_assert(false, "clear: unsupported image format")

# --------------------------------------------------------------------------------------------------

proc premultiply_alpha*(image: var Image2d) =
  for x, y, color in image.xy_pixels:
    image.set_pixel(x, y, color.premultiply)

# --------------------------------------------------------------------------------------------------

when is_main_module:
  block:
    var img = init_image(8, 8, ImageFormat.gray_8)

    set_pixel_gray_8(img, 0, 0, 101)
    do_assert(get_pixel_gray_8(img, 0, 0) == 101)

    set_pixel_gray_8(img, 3, 0, 102)
    do_assert(get_pixel_gray_8(img, 3, 0) == 102)

    set_pixel_gray_8(img, 3, 2, 103)
    do_assert(get_pixel_gray_8(img, 3, 2) == 103)

    set_pixel_gray_8(img, 7, 7, 104)
    do_assert(get_pixel_gray_8(img, 7, 7) == 104)

    for x, y, p in xy_mpixels_gray_8(img):
      p = uint8(x xor y)

    for x, y, p in xy_pixels_gray_8(img):
      do_assert(p == uint8(x xor y))

    img.clear_gray_8(123u8)

    for x, y, p in xy_pixels_gray_8(img):
      do_assert(p == 123u8)

    img.set_pixel(2, 2, COLOR_WHITE)
    do_assert(img.get_pixel(2, 2) == COLOR_WHITE)

    img.set_pixel(2, 3, COLOR_BLACK)
    do_assert(img.get_pixel(2, 3) == COLOR_BLACK)

    img.destroy()

  block:
    var img = init_image(8, 8, ImageFormat.abgr_8888)

    set_pixel_abgr_8888(img, 0, 0, 0xAABBCCDDu32)
    do_assert(get_pixel_abgr_8888(img, 0, 0) == 0xAABBCCDDu32)

    set_pixel_abgr_8888(img, 3, 2, 0xDEADBEEFu32)
    do_assert(get_pixel_abgr_8888(img, 3, 2) == 0xDEADBEEFu32)

    set_pixel_abgr_8888(img, 7, 7, 0xCAFEBABEu32)
    do_assert(get_pixel_abgr_8888(img, 7, 7) == 0xCAFEBABEu32)

    for x, y, p in xy_mpixels_abgr_8888(img):
      p = uint32(x xor y)

    for x, y, p in xy_pixels_abgr_8888(img):
      do_assert(p == uint32(x xor y))

    #img.set_pixel(2, 3, COLOR_RED)
    #echo COLOR_RED
    #echo img.get_pixel(2, 3)

    img.destroy()

  echo "ok"
