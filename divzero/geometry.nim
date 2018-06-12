import divzero / [shapes3]

# --------------------------------------------------------------------------------------------------

# [V]ertex
# [N]ormal
# [T]exture
# [B]ones

type GeoFormat* {.pure.} = enum
  VN3
  VNT3
  VNTB3
  VT2

const size_V* = sizeof(float32) * 3
const size_N* = sizeof(float32) * 3
const size_T* = sizeof(float32) * 2
const size_B* = sizeof(int32) + sizeof(int32)

const geo_stride* = [
  size_V + size_N,
  size_V + size_N + size_T,
  size_V + size_N + size_T + size_B,
  8 + 8
]

# --------------------------------------------------------------------------------------------------

type GeoSurface* = object
  start*, count*: int32

# --------------------------------------------------------------------------------------------------

const MAX_GEOMETRY_SURFACES* = 16

type Geometry* = object
  attr_data*: pointer
  elem_data*: pointer
  attr_size*: int
  elem_size*: int
  bounds*: AABB3
  surfaces*: array[MAX_GEOMETRY_SURFACES, GeoSurface]
  format*: GeoFormat
  num_bones*: int

# --------------------------------------------------------------------------------------------------

proc create_geometry*(format: GeoFormat; attr_count, elem_count: int): Geometry =
  result.attr_size = attr_count * geo_stride[int format]
  result.elem_size = elem_count * sizeof(int32)
  result.attr_data = alloc(result.attr_size)
  result.elem_data = alloc(result.elem_size)
  result.format = format


proc create_geometry*(format: GeoFormat; attr_count, elem_count: int; attr_data, elem_data: pointer): Geometry =
  result.attr_size = attr_count * geo_stride[int format]
  result.elem_size = elem_count * sizeof(int32)
  result.attr_data = attr_data
  result.elem_data = elem_data
  result.format = format


proc destroy*(geo: var Geometry) =
  if geo.attr_data != nil: dealloc(geo.attr_data)
  if geo.elem_data != nil: dealloc(geo.elem_data)

# --------------------------------------------------------------------------------------------------

proc set_attrib_vn3*(geo: var Geometry; index: int; data: array[6, float32]) =
  cast[ptr UncheckedArray[type data]](geo.attr_data)[index] = data


proc set_elem*(geo: var Geometry; index: int; data: int32) =
  cast[ptr UncheckedArray[type data]](geo.elem_data)[index] = data
