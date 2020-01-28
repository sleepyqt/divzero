import divzero / [shapes3]

# [V]ertex
# [N]ormal
# [T]exture
# [B]ones

type GeoFormat* = enum GfVN3, GfVNT3, GfVNTB3, GfVT2

const
  sizeV* = sizeof(float32) * 3
  sizeN* = sizeof(float32) * 3
  sizeT* = sizeof(float32) * 2
  sizeB* = sizeof(int32) + sizeof(int32)

const geoStride* = [
  sizeV + sizeN,
  sizeV + sizeN + sizeT,
  sizeV + sizeN + sizeT + sizeB,
  8 + 8]

type GeoSurface* = object
  start*, count*: int32

const maxGeometrySurfaces* = 16

type Geometry* = object
  attrData*: pointer
  elemData*: pointer
  attrSize*: int
  elemSize*: int
  bounds*: AABB3
  surfaces*: array[maxGeometrySurfaces, GeoSurface]
  format*: GeoFormat
  numBones*: int

proc createGeometry*(format: GeoFormat; attrCount, elemCount: int): Geometry =
  result.attrSize = attrCount * geoStride[int format]
  result.elemSize = elemCount * sizeof(int32)
  result.attrData = alloc(result.attrSize)
  result.elemData = alloc(result.elemSize)
  result.format = format

proc createGeometry*(format: GeoFormat; attrCount, elemCount: int; attrData, elemData: pointer): Geometry =
  result.attrSize = attrCount * geoStride[int format]
  result.elemSize = elemCount * sizeof(int32)
  result.attrData = attrData
  result.elemData = elemData
  result.format = format

proc `=destroy`*(geo: var Geometry) =
  if geo.attrData != nil: dealloc(geo.attrData)
  if geo.elemData != nil: dealloc(geo.elemData)

proc setAttribVN3*(geo: var Geometry; index: int; data: array[6, float32]) =
  cast[ptr UncheckedArray[type data]](geo.attrData)[index] = data

proc setElem*(geo: var Geometry; index: int; data: int32) =
  cast[ptr UncheckedArray[type data]](geo.elemData)[index] = data
