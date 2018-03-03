import std     / [math]
import divzero / [vec2, mat3]

# --------------------------------------------------------------------------------------------------

type Rectangle* = object
  pos*: Vec2
  size*: Vec2


type AABB2* = object
  min*, max*: Vec2


type Ray2* = object
  origin*, direction*: Vec2


type Edge* = object
  p0*, p1*: Vec2


type Plane2* = object
  normal*: Vec2
  dist*: float32


type Circle* = object
  pos*: Vec2
  radius*: float32


type Triangle* = object
  a*, b*, c*: Vec2


type ConvexHull* = object
  count*: int32
  points*: array[8, Vec2]


type CollisionInfo* = object
  hit*: bool
  normal*: Vec2
  depth*: float32

# --------------------------------------------------------------------------------------------------
# Rectangle
# --------------------------------------------------------------------------------------------------

proc rectangle*(x, y, w, h: float32): Rectangle {.inline.} =
  result.pos.x = x
  result.pos.y = y
  result.size.x = w
  result.size.y = h


proc rectangle*(pos, size: Vec2): Rectangle {.inline.} =
  result.pos = pos
  result.size = size


proc rectangle*(aabb: AABB2): Rectangle =
  result.pos = aabb.min
  result.size = aabb.max - aabb.min

# --------------------------------------------------------------------------------------------------

proc top_left*(rect: Rectangle): Vec2 {.inline.} =
  result = rect.pos


proc top_right*(rect: Rectangle): Vec2 {.inline.} =
  result = rect.pos + vec2(rect.size.x, 0f)


proc bottom_left*(rect: Rectangle): Vec2 {.inline.} =
  result = rect.pos + vec2(0f, rect.size.y)


proc bottom_right*(rect: Rectangle): Vec2 {.inline.} =
  result = rect.pos + rect.size


proc left*(rect: Rectangle): float32 {.inline.} =
  result = rect.pos.x


proc right*(rect: Rectangle): float32 {.inline.} =
  result = rect.pos.x + rect.size.x


proc top*(rect: Rectangle): float32 {.inline.} =
  result = rect.pos.y


proc bottom*(rect: Rectangle): float32 {.inline.} =
  result = rect.pos.y + rect.size.y


proc width*(rect: Rectangle): float32 {.inline.} =
  result = rect.size.x


proc height*(rect: Rectangle): float32 {.inline.} =
  result = rect.size.y


proc center*(rect: Rectangle): Vec2 =
  result = rect.pos + rect.size * 0.5f

# --------------------------------------------------------------------------------------------------

proc union*(a, b: Rectangle): Rectangle =
  result.pos.x = min(a.pos.x, b.pos.x)
  result.pos.y = min(a.pos.y, b.pos.y)
  result.size.x = max(a.pos.x + a.size.x, b.pos.x + b.size.x) - min(a.pos.x, b.pos.x)
  result.size.y = max(a.pos.y + a.size.y, b.pos.y + b.size.y) - min(a.pos.y, b.pos.y)


proc intersection*(a, b: Rectangle): Rectangle =
  result.pos.x = max(a.pos.x, b.pos.x)
  result.pos.y = max(a.pos.y, b.pos.y)
  result.size.x = min(a.pos.x + a.size.x, b.pos.x + b.size.x) - max(a.pos.x, b.pos.x)
  result.size.y = min(a.pos.y + a.size.y, b.pos.y + b.size.y) - max(a.pos.y, b.pos.y)

# --------------------------------------------------------------------------------------------------

proc valid*(a: Rectangle): bool {.inline.} =
  (a.size.x > 0) and (a.size.y > 0)

# --------------------------------------------------------------------------------------------------

proc offset*(a: Rectangle; pos: Vec2): Rectangle {.inline.} =
  result.pos = a.pos + pos
  result.size = a.size


proc offset*(a: Rectangle; x, y: float32): Rectangle {.inline.} =
  result.pos.x = a.pos.x + x
  result.pos.y = a.pos.y + y
  result.size = a.size


proc offset_x*(a: Rectangle; size: float32): Rectangle {.inline.} =
  result.pos = a.pos + vec2(size, 0)
  result.size = a.size


proc offset_y*(a: Rectangle; size: float32): Rectangle {.inline.} =
  result.pos = a.pos + vec2(0, size)
  result.size = a.size


proc resize*(a: Rectangle; size: Vec2): Rectangle {.inline.} =
  result.pos = a.pos
  result.size = size


proc resize*(a: Rectangle; x, y: float32): Rectangle {.inline.} =
  result.pos = a.pos
  result.size = vec2(x, y)


proc resize_x*(a: Rectangle; size: float32): Rectangle {.inline.} =
  result.pos = a.pos
  result.size.x = size
  result.size.y = a.size.y


proc resize_y*(a: Rectangle; size: float32): Rectangle {.inline.} =
  result.pos = a.pos
  result.size.x = a.size.x
  result.size.y = size


proc scale*(a: Rectangle; size: Vec2): Rectangle {.inline.} =
  result.pos = a.pos
  result.size = a.size + size


proc scale*(a: Rectangle; x, y: float32): Rectangle {.inline.} =
  result.pos = a.pos
  result.size.x = a.size.x + x
  result.size.y = a.size.y + y


proc inflate*(a: Rectangle; size: Vec2): Rectangle {.inline.} =
  result.pos = a.pos - size / 2
  result.size = a.size + size


proc inflate*(a: Rectangle; x, y: float32): Rectangle {.inline.} =
  let size = vec2(x, y)
  result.pos  = a.pos  - size / 2
  result.size = a.size + size


proc set_x*(a: Rectangle; x: float32): Rectangle =
  result.pos = a.pos
  result.size = a.size
  result.pos.x = x


proc set_y*(a: Rectangle; y: float32): Rectangle =
  result.pos = a.pos
  result.size = a.size
  result.pos.y = y

# --------------------------------------------------------------------------------------------------

proc left_border*(a: Rectangle; width: float32): Rectangle =
  result.pos = a.pos
  result.size.x = width
  result.size.y = a.size.y


proc right_border*(a: Rectangle; width: float32): Rectangle =
  result.pos.x = a.pos.x + a.size.x - width
  result.pos.y = a.pos.y
  result.size.x = width
  result.size.y = a.size.y


proc bottom_border*(a: Rectangle; width: float32): Rectangle =
  result.pos.x = a.pos.x
  result.pos.y = a.pos.y + a.size.y - width
  result.size.x = a.size.x
  result.size.y = width

# --------------------------------------------------------------------------------------------------

proc split2_horz_pixels*(a: Rectangle; split_pos: float32): (Rectangle, Rectangle) =
  result[0].pos.x  = a.pos.x
  result[0].pos.y  = a.pos.y
  result[0].size.x = split_pos
  result[0].size.y = a.size.y
  result[1].pos.x  = a.pos.x + split_pos
  result[1].pos.y  = a.pos.y
  result[1].size.x = a.size.x - split_pos
  result[1].size.y = a.size.y

# --------------------------------------------------------------------------------------------------
# Circle
# --------------------------------------------------------------------------------------------------

proc circle*(pos: Vec2; radius: float32): Circle =
  result.pos = pos
  result.radius = radius


proc circle*(x, y, radius: float32): Circle =
  result.pos.x = x
  result.pos.y = y
  result.radius = radius


proc `*`*(m: Mat3; c: Circle): Circle =
  result.pos    = m * c.pos
  result.radius = distance(result.pos, m * (vec2(c.radius) + c.pos))

# --------------------------------------------------------------------------------------------------
# Edge
# --------------------------------------------------------------------------------------------------

proc `*`*(m: Mat3; e: Edge): Edge =
  result.p0 = m * e.p0
  result.p1 = m * e.p1

# --------------------------------------------------------------------------------------------------
# Plane2
# --------------------------------------------------------------------------------------------------

proc plane2*(normal: Vec2; dist: float32): Plane2 =
  result.normal = normal
  result.dist = dist


proc plane2*(normal, origin: Vec2): Plane2 =
  result.normal = normal
  result.dist = dot(normal, origin)


proc plane2_cw*(a, b: Vec2): Plane2 =
  ## build plane from two points
  result.normal = direction(a, b).right()
  result.dist = dot(result.normal, a)


proc plane2_ccw*(a, b: Vec2): Plane2 =
  ## build plane from two points
  result.normal = direction(a, b).left()
  result.dist = dot(result.normal, a)


proc plane2_cw*(edge: Edge): Plane2 =
  result.normal = direction(edge.p0, edge.p1).right()
  result.dist   = dot(result.normal, edge.p0)


proc plane2_ccw*(edge: Edge): Plane2 =
  result.normal = direction(edge.p0, edge.p1).left()
  result.dist   = dot(result.normal, edge.p0)


proc distance*(plane: Plane2; point: Vec2): float32 =
  ## returns distance from the point to the plane
  result = dot(plane.normal, point) - plane.dist


proc center*(plane: Plane2): Vec2 =
  result = plane.normal * plane.dist


iterator edges*(points: open_array[Vec2]): Edge =
  let L = len(points)
  for i in 0 ..< L:
    let i0 = i
    let i1 = (i + 1) mod L
    yield Edge(p0: points[i0], p1: points[i1])

# --------------------------------------------------------------------------------------------------
# AABB2
# --------------------------------------------------------------------------------------------------

proc aabb2*(min, max: Vec2): AABB2 =
  ## builds AABB from a two points
  result.min = min
  result.max = max


proc aabb2*(point: Vec2): AABB2 =
  ## builds AABB from a point
  result.min = point
  result.max = point


proc aabb2*(circle: Circle): AABB2 =
  ## builds AABB from a circle
  result.min = circle.pos - vec2(circle.radius, circle.radius)
  result.max = circle.pos + vec2(circle.radius, circle.radius)


proc size*(box: AABB2): Vec2 =
  result = box.max - box.min


proc half_size*(box: AABB2): Vec2 =
  result = box.size * 0.5f


proc center*(box: AABB2): Vec2 =
  result = (box.min + box.max) * 0.5f


proc expand*(box: var AABB2; point: Vec2) =
  box.min = min(box.min, point)
  box.max = max(box.max, point)


proc expand*(box: var AABB2; b: AABB2) =
  box.min = min(box.min, b.min)
  box.max = max(box.max, b.max)


proc offset*(box: AABB2; dir: Vec2): AABB2 =
  result.min = box.min + dir
  result.max = box.max + dir


proc `*`*(m: Mat3; box: AABB2): AABB2 =
  result.min = m * box.min
  result.max = m * box.max

# --------------------------------------------------------------------------------------------------
# ConvexHull
# --------------------------------------------------------------------------------------------------

proc `*`*(m: Mat3; hull: ConvexHull): ConvexHull =
  result.count = hull.count
  for i in 0 ..< hull.count:
    result.points[i] = m * hull.points[i]

# --------------------------------------------------------------------------------------------------
# Triangle
# --------------------------------------------------------------------------------------------------

proc triangle*(a, b, c: Vec2): Triangle =
  result.a = a
  result.b = b
  result.c = c

# --------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------

proc inside*(circle: Circle; point: Vec2): bool =
  result = distance_sq(circle.pos, point) < circle.radius * circle.radius


proc inside*(circle: Circle; m: Mat3; point: Vec2): bool =
  result = distance_sq(m * circle.pos, point) < circle.radius * circle.radius


proc inside*(rect: Rectangle; point: Vec2): bool =
  (point.x >= rect.pos.x) and (point.y >= rect.pos.y) and
    (point.x < (rect.pos.x + rect.size.x)) and (point.y < (rect.pos.y + rect.size.y))


proc inside*(planes: open_array[Plane2]; point: Vec2): bool =
  result = true
  for plane in planes:
    if distance(plane, point) < 0:
      return false


proc inside*(points: open_array[Vec2]; point: Vec2): bool =
  result = true
  for edge in points.edges:
    let plane = plane2_cw(edge)
    if distance(plane, point) < 0:
      return false


proc inside*(points: open_array[Vec2]; point: Vec2; info: var CollisionInfo) =
  info.hit = true
  var closest = high float32
  for edge in points.edges:
    let plane = plane2_cw(edge)
    var dist = distance(plane, point)
    if dist < 0:
      info.hit = false
      return

    if abs(dist) < closest:
      info.depth = dist
      info.normal = plane.normal
      closest = abs(dist)


proc inside*(circle: Circle; point: Vec2; info: var CollisionInfo) =
  let dist = distance(circle.pos, point)
  if dist < circle.radius:
    info.hit    = true
    info.depth  = circle.radius - dist
    info.normal = direction(circle.pos, point)


proc inside*(aabb: AABB2; point: Vec2): bool =
  if point.x < aabb.min.x: return
  if point.y < aabb.min.y: return
  if point.x > aabb.max.x: return
  if point.y > aabb.max.y: return
  result = true

# --------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------

proc overlaps*(a: Rectangle; b: Rectangle): bool =
  let over_x = (a.left < b.right) and (a.right > b.left)
  let over_y = (a.top < b.bottom) and (a.bottom > b.top)
  result = over_x and over_y


proc overlaps*(a: Circle; b: Circle): bool =
  let r2 = a.radius + b.radius
  result = distance_sq(a.pos, b.pos) < (r2 * r2)


proc overlaps*(a: AABB2; b: AABB2): bool =
  let d0 = b.max.x < a.min.x
  let d1 = a.max.x < b.min.x
  let d2 = b.max.y < a.min.y
  let d3 = a.max.y < b.min.y
  result = not (d0 or d1 or d2 or d3)


proc overlaps*(a: AABB2; b: Circle): bool =
  let L  = clamp(b.pos, a.min, a.max)
  let ab = b.pos - L
  let d2 = dot(ab, ab)
  let r2 = b.radius * b.radius
  result = d2 < r2


proc overlaps*(a: Circle; b: Plane2): bool =
  let dist = distance(b, a.pos)
  result = dist < a.radius

# --------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------

proc overlaps*(a: Circle; b: Circle; info: var CollisionInfo) =
  let r2 = a.radius + b.radius
  let ds = distance_sq(a.pos, b.pos)
  info.hit = ds < (r2 * r2)
  if info.hit:
    info.depth  = r2 - sqrt(ds)
    info.normal = direction(b.pos, a.pos)


proc overlaps*(a_points, b_points: open_array[Vec2]; info: var CollisionInfo) =
  info.hit = true

  var closest = high float32

  for edge in edges(a_points):
    let plane = plane2_cw(edge)

    var a_max_proj = low  float32
    var a_min_proj = high float32

    for point in a_points:
      let proj = dot(plane.normal, point)
      if proj < a_min_proj: a_min_proj = proj
      if proj > a_max_proj: a_max_proj = proj

    var b_max_proj = low  float32
    var b_min_proj = high float32

    for point in b_points:
      let proj = dot(plane.normal, point)
      if proj < b_min_proj: b_min_proj = proj
      if proj > b_max_proj: b_max_proj = proj

    let test_a = a_min_proj - b_max_proj
    let test_b = b_min_proj - a_max_proj

    if (test_a > 0) or (test_b > 0):
      info.hit = false
      return

    let dist = -(b_max_proj - a_min_proj)

    if abs(dist) < closest:
      info.depth = dist
      info.normal = plane.normal
      closest = abs(dist)


proc overlaps*(a: Circle; b: Plane2; info: var CollisionInfo) =
  let dist = distance(b, a.pos)
  if dist < a.radius:
    info.hit = true
    info.depth = a.radius - dist
    info.normal = b.normal


proc overlaps*(a: Rectangle; b: Rectangle; info: var CollisionInfo) =
  let over_x = (a.left < b.right) and (a.right > b.left)
  let over_y = (a.top < b.bottom) and (a.bottom > b.top)
  info.hit = over_x and over_y


proc overlaps*(a: AABB2; b: AABB2; info: var CollisionInfo) =
  let mid_a = a.center
  let mid_b = b.center
  let eA    = abs a.half_size
  let eB    = abs b.half_size
  let d     = mid_b - mid_a

  let dx = eA.x + eB.x - abs(d.x)
  let dy = eA.y + eB.y - abs(d.y)

  if (dx >= 0) and (dy >= 0):
    info.hit = true

    if dx < dy:
      info.depth = dx
      if d.x < 0:
        info.normal = vec2(1f, 0f)
      else:
        info.normal = vec2(-1f, 0f)
    else:
      info.depth = dy
      if d.y < 0:
        info.normal = vec2(0, 1f)
      else:
        info.normal = vec2(0, -1f)

# --------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------

proc `*`*(m: Mat3; hull: open_array[Vec2]): seq[Vec2] =
  result = new_seq[Vec2](len(hull))
  for i, point in hull: result[i] = m * point


proc transform*(m: Mat3; hull: open_array[Vec2]; dest: var open_array[Vec2]) =
  for i in 0 ..< len(hull):
    dest[i] = m * hull[i]


proc point_cloud_size*(points: open_array[Vec2]): Vec2 =
  var maxp = low(Vec2)
  var minp = high(Vec2)
  for point in points:
    maxp = max(maxp, point)
    minp = min(minp, point)
  result = maxp - minp
