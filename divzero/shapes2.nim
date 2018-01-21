import divzero / [vec2]

# --------------------------------------------------------------------------------------------------

type Rectangle* = object
  pos*: Vec2
  size*: Vec2

# --------------------------------------------------------------------------------------------------

proc rectangle*(x, y, w, h: float32): Rectangle {.inline.} =
  result.pos.x = x
  result.pos.y = y
  result.size.x = w
  result.size.y = h


proc rectangle*(pos, size: Vec2): Rectangle {.inline.} =
  result.pos = pos
  result.size = size

# --------------------------------------------------------------------------------------------------

proc top_left*(rect: Rectangle): Vec2 {.inline.} =
  result = rect.pos


proc bottom_left*(rect: Rectangle): Vec2 {.inline.} =
  result = rect.pos; result.y += rect.size.y


proc top_right*(rect: Rectangle): Vec2 {.inline.} =
  result = rect.pos; result.x += rect.size.x


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

# --------------------------------------------------------------------------------------------------

proc contains*(rect: Rectangle; point: Vec2): bool =
  (point.x >= rect.pos.x) and (point.y >= rect.pos.y) and
    (point.x < (rect.pos.x + rect.size.x)) and (point.y < (rect.pos.y + rect.size.y))

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

type Circle* = object
  pos*: Vec2
  radius*: float32

# --------------------------------------------------------------------------------------------------

type Ray2* = object
  origin*, direction*: Vec2

# --------------------------------------------------------------------------------------------------

type Edge* = object
  p0*, p1*: Vec2

# --------------------------------------------------------------------------------------------------

type Plane2* = object
  normal*: Vec2
  dist*: float32

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
  result = dot(plane.normal, point)


proc point_inside_convex*(planes: open_array[Plane2]; point: Vec2): bool =
  result = true
  for plane in planes:
    if distance(plane, point) - plane.dist > 0:
      return false


iterator edges*(points: open_array[Vec2]): Edge =
  let L = len(points)
  for i in 0 ..< L:
    let i0 = i
    let i1 = (i + 1) mod L
    yield Edge(p0: points[i0], p1: points[i1])


proc point_inside_convex*(points: open_array[Vec2]; point: Vec2): bool =
  result = true
  for edge in points.edges:
    let plane = plane2_cw(edge)
    if distance(plane, point) - plane.dist > 0:
      return false

# --------------------------------------------------------------------------------------------------

proc rectangle_vs_rectangle*(a: Rectangle; b: Rectangle): bool =
  let over_x = (a.left < b.right) and (a.right > b.left)
  let over_y = (a.top < b.bottom) and (a.bottom > b.top)
  result = over_x and over_y


proc circle_vs_circle*(a: Circle; b: Circle): bool =
  let r2 = a.radius + b.radius
  result = distance_sq(a.pos, b.pos) <= (r2 * r2)

# --------------------------------------------------------------------------------------------------

type ConvexHull* = object
  points*: seq[Vec2]

