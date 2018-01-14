import divzero / [vec4, mat4]

# --------------------------------------------------------------------------------------------------

type AABB3* = object
  ## Axis-aligned bounding box
  min*: Vec4
  max*: Vec4

# --------------------------------------------------------------------------------------------------

proc aabb3*(): AABB3 =
  result.min = vec4()
  result.max = vec4()


proc aabb3*(min, max: Vec4): AABB3 =
  result.min = min
  result.max = max


proc aabb3*(point: Vec4): AABB3 =
  result.min = point
  result.max = point

# --------------------------------------------------------------------------------------------------

proc `*`*(b: Mat4; a: AABB3): AABB3 =
  let 
    xa: Vec4 = b.c0 * a.min.x
    ya: Vec4 = b.c1 * a.min.y
    za: Vec4 = b.c2 * a.min.z
    xb: Vec4 = b.c0 * a.max.x
    yb: Vec4 = b.c1 * a.max.y
    zb: Vec4 = b.c2 * a.max.z

  result.min = min(xa, xb) + min(ya, yb) + min(za, zb) + b.c3
  result.max = max(xa, xb) + max(ya, yb) + max(za, zb) + b.c3

# --------------------------------------------------------------------------------------------------

proc expand*(box: var AABB3; point: Vec4) =
  box.min = min(box.min, point)
  box.max = max(box.max, point)


proc expand*(box: var AABB3; b: AABB3) =
  box.min = min(box.min, b.min)
  box.max = max(box.max, b.max)

# --------------------------------------------------------------------------------------------------

proc size*(box: AABB3): Vec4 =
  result = box.max - box.min


proc center*(box: AABB3): Vec4 =
  result = (box.min + box.max) * 0.5f

# --------------------------------------------------------------------------------------------------

proc inside*(box: AABB3; point: Vec4): bool =
  result = point.x >= box.min.x and point.x <= box.max.x and
           point.y >= box.min.y and point.y <= box.max.y and
           point.z >= box.min.z and point.z <= box.max.z


proc inside*(box: AABB3; b: AABB3): bool =
  if b.max.x < box.min.x or b.min.x > box.max.x or
     b.max.y < box.min.y or b.min.y > box.max.y or
     b.max.z < box.min.z or b.min.z > box.max.z:
    result = false
  else:
    result = true

# --------------------------------------------------------------------------------------------------

proc selftest* =
  discard
