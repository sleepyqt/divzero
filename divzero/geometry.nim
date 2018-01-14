import divzero / [aabb3]

# --------------------------------------------------------------------------------------------------

type GeometryFormat* {.pure.} = enum
  VN, VNT, VNTB


type GeometrySurface* = object
  start*, count*: int32

# --------------------------------------------------------------------------------------------------

const MAX_GEOMETRY_SURFACES* = 16

type Geometry* = object
  attr_data*: pointer
  elem_data*: pointer
  attr_size*: int
  elem_size*: int
  bounds*: AABB3
  surfaces*: array[MAX_GEOMETRY_SURFACES, GeometrySurface]
  format*: GeometryFormat
