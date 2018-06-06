import std     / [math]
import divzero / [vec2, mat3, mathfn]

# --------------------------------------------------------------------------------------------------

include divzero.xpragmas

# --------------------------------------------------------------------------------------------------

type Rectangle* = object
  pos*: Vec2
  size*: Vec2


type AABB2* = object
  ## Axis aligned bounding box
  min*, max*: Vec2


type Ray2* = object
  origin*, direction*: Vec2


type Edge* = object
  p0*, p1*: Vec2


type Plane2* = object
  ## 2D plane
  normal*: Vec2
  dist*: float32 ## distance to plane from origin along normal


type Circle* = object
  pos*: Vec2 ## center of circle
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


type Projection* = object
  min*, max*: float32

# --------------------------------------------------------------------------------------------------

proc overlaps*(a, b: Projection): bool =
  ## checks is two projections overlaps
  if (a.min - b.max) > 0f: return false
  if (b.min - a.max) > 0f: return false
  result = true


proc depth*(a, b: Projection): float32 =
  ## returns projection overlap size
  result = b.max - a.min

# --------------------------------------------------------------------------------------------------

func mtv*(info: CollisionInfo): Vec2 =
  ## returns minimum translation vector
  result = info.normal * info.depth

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
# Ray2
# --------------------------------------------------------------------------------------------------

proc ray2*(origin, direction: Vec2): Ray2 =
  result.origin = origin
  result.direction = direction

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
  ## returns circle transformed by matrix
  let a = m * (c.pos)
  let b = m * (c.pos + vec2(0f, c.radius))
  let d = distance(a, b)
  result.pos    = a
  result.radius = d


proc offset*(circle: Circle; pos: Vec2): Circle =
  result.pos = circle.pos + pos
  result.radius = circle.radius


func project*(circle: Circle; axis: Vec2): Projection =
  let naxis = normalize(axis)
  let p0 = circle.pos + (naxis * circle.radius)
  let p1 = circle.pos - (naxis * circle.radius)
  let proj0 = dot(axis, p0)
  let proj1 = dot(axis, p1)
  result.min = min(proj0, proj1)
  result.max = max(proj0, proj1)

# --------------------------------------------------------------------------------------------------
# Edge
# --------------------------------------------------------------------------------------------------

func `*`*(m: Mat3; e: Edge): Edge =
  ## returns edge transformed by matrix
  result.p0 = m * e.p0
  result.p1 = m * e.p1


func midpoint*(edge: Edge): Vec2 =
  result.x = (edge.p0.x + edge.p1.x) * 0.5f
  result.y = (edge.p0.y + edge.p1.y) * 0.5f


func normal_cw*(edge: Edge): Vec2 =
  result = direction(edge.p0, edge.p1).right


func normal_ccw*(edge: Edge): Vec2 =
  result = direction(edge.p0, edge.p1).left


func project*(edge: Edge; axis: Vec2): Projection =
  let p0 = dot(edge.p0, axis)
  let p1 = dot(edge.p1, axis)
  result.min = min(p0, p1)
  result.max = max(p0, p1)

# --------------------------------------------------------------------------------------------------
# Plane2
# --------------------------------------------------------------------------------------------------

proc plane2*(normal: Vec2; dist: float32): Plane2 =
  ## builds plane from normal and distance to origin
  result.normal = normal
  result.dist = dist


proc plane2*(normal, origin: Vec2): Plane2 =
  ## builds plane from normal and origin
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
  ## builds plane from edge
  result.normal = direction(edge.p0, edge.p1).right()
  result.dist   = dot(result.normal, edge.p0)


proc plane2_ccw*(edge: Edge): Plane2 =
  ## builds plane from edge
  result.normal = direction(edge.p0, edge.p1).left()
  result.dist   = dot(result.normal, edge.p0)


proc distance*(plane: Plane2; point: Vec2): float32 =
  ## returns distance from the point to the plane
  result = dot(plane.normal, point) - plane.dist


proc center*(plane: Plane2): Vec2 =
  ## returns point on plane
  result = plane.normal * plane.dist


iterator edges*(points: open_array[Vec2]): Edge =
  let L = len(points)
  for i in 0 ..< L:
    let i0 = i
    let i1 = (i + 1) mod L
    yield Edge(p0: points[i0], p1: points[i1])


proc `*`*(m: Mat3; plane: Plane2): Plane2 =
  ## returns plane transformed by matrix
  let c = plane.center
  let l = m * (c + plane.normal.left)
  let r = m * (c + plane.normal.right)
  result = plane2_ccw(l, r)

# --------------------------------------------------------------------------------------------------
# AABB2
# --------------------------------------------------------------------------------------------------

proc aabb2*(min, max: Vec2): AABB2 {.inline.} =
  ## builds AABB from a two points
  result.min = min
  result.max = max


proc aabb2*(point: Vec2): AABB2 {.inline.} =
  ## builds AABB from a point
  result.min = point
  result.max = point


proc aabb2*(circle: Circle): AABB2 {.inline.} =
  ## builds AABB from a circle
  result.min = circle.pos - vec2(circle.radius, circle.radius)
  result.max = circle.pos + vec2(circle.radius, circle.radius)


proc aabb2*(triangle: Triangle): AABB2 {.inline.} =
  ## build AABB from triangle
  result.min = min(triangle.a, triangle.b, triangle.c)
  result.max = max(triangle.a, triangle.b, triangle.c)


proc size*(box: AABB2): Vec2 {.inline.} =
  result = box.max - box.min


proc half_size*(box: AABB2): Vec2 {.inline.} =
  result = box.size * 0.5f


proc center*(box: AABB2): Vec2 {.inline.} =
  result = (box.min + box.max) * 0.5f


proc expand*(box: var AABB2; point: Vec2) {.inline.} =
  box.min = min(box.min, point)
  box.max = max(box.max, point)


proc expand*(box: var AABB2; b: AABB2) {.inline.} =
  box.min = min(box.min, b.min)
  box.max = max(box.max, b.max)


proc offset*(box: AABB2; dir: Vec2): AABB2 {.inline.} =
  result.min = box.min + dir
  result.max = box.max + dir


proc `*`*(m: Mat3; box: AABB2): AABB2 {.inline.} =
  result.min = m * box.min
  result.max = m * box.max


func top_left*(box: AABB2): Vec2 {.inline.} =
  result = box.min


func top_right*(box: AABB2): Vec2 {.inline.} =
  result.x = box.max.x
  result.y = box.min.y


func bottom_left*(box: AABB2): Vec2 {.inline.} =
  result.x = box.min.x
  result.y = box.max.y


func bottom_right*(box: AABB2): Vec2 {.inline.} =
  result = box.max


func project*(box: AABB2; axis: Vec2): Projection =
  let p0 = dot(axis, box.top_left)
  let p1 = dot(axis, box.top_right)
  let p2 = dot(axis, box.bottom_left)
  let p3 = dot(axis, box.bottom_right)
  result.min = min(p0, p1, p2, p3)
  result.max = max(p0, p1, p2, p3)

# --------------------------------------------------------------------------------------------------
# ConvexHull
# --------------------------------------------------------------------------------------------------

proc `*`*(m: Mat3; hull: ConvexHull): ConvexHull =
  result.count = hull.count
  for i in 0 ..< hull.count:
    result.points[i] = m * hull.points[i]


iterator points*(hull: ConvexHull): Vec2 =
  for i in 0 ..< hull.count:
    yield hull.points[i]


iterator index_and_points*(hull: ConvexHull): (int, Vec2) =
  for i in 0 ..< hull.count:
    yield (i, hull.points[i])


func project*(hull: ConvexHull; axis: Vec2): Projection =
  ## project convex hull into axis. Axis must be normalized.
  let proj = dot(axis, hull.points[0])
  result.min = proj
  result.max = proj
  for i in 1 ..< hull.count:
    let proj = dot(axis, hull.points[i])
    result.min = min(result.min, proj)
    result.max = max(result.max, proj)


func bounds*(hull: ConvexHull): AABB2 =
  result.min = hull.points[0]
  result.max = hull.points[0]
  for i in 1 ..< hull.count:
    result.expand(hull.points[i])


iterator planes*(hull: ConvexHull): Plane2 =
  for i in 0 ..< hull.count:
    let i0 = i
    let i1 = (i + 1) mod hull.count
    let p0 = hull.points[i0]
    let p1 = hull.points[i1]
    yield plane2_cw(p0, p1)


func offset*(hull: ConvexHull; dir: Vec2): ConvexHull =
  result.count = hull.count
  for i, point in hull.index_and_points:
    result.points[i] = point + dir

# --------------------------------------------------------------------------------------------------
# Triangle
# --------------------------------------------------------------------------------------------------

proc triangle*(a, b, c: Vec2): Triangle {.inline.} =
  ## builds triangle from tree vertices
  result.a = a
  result.b = b
  result.c = c


proc triangle*(ax, ay, bx, by, cx, cy: float32): Triangle =
  result.a.x = ax; result.a.y = ay
  result.b.x = bx; result.b.y = by
  result.c.x = cx; result.c.y = cy


proc signed_area*(a, b, c: Vec2): float32 =
  ## returns signed area of triangle formed by points `a` `b` `c`
  let side1 = b - a
  let side2 = c - a
  result = cross(side1, side2)


proc signed_area*(triangle: Triangle): float32 =
  ## returns signed area of triangle
  let side1 = triangle.b - triangle.a
  let side2 = triangle.c - triangle.a
  result = cross(side1, side2)


func edge_ab*(triangle: Triangle): Edge =
  result.p0 = triangle.a
  result.p1 = triangle.b


func edge_bc*(triangle: Triangle): Edge =
  result.p0 = triangle.b
  result.p1 = triangle.c


func edge_ca*(triangle: Triangle): Edge =
  result.p0 = triangle.c
  result.p1 = triangle.a


func perimeter*(triangle: Triangle): float32 =
  let side1 = triangle.b - triangle.a
  let side2 = triangle.c - triangle.a
  let side3 = triangle.c - triangle.b
  result = len(side1) + len(side2) + len(side3)


func `*`*(m: Mat3; triangle: Triangle): Triangle =
  result.a = m * triangle.a
  result.b = m * triangle.b
  result.c = m * triangle.c


func offset*(triangle: Triangle; dir: Vec2): Triangle =
  result.a = triangle.a + dir
  result.b = triangle.b + dir
  result.c = triangle.c + dir


func project*(triangle: Triangle; axis: Vec2): Projection =
  ## project `triangle` into `axis`
  let pa = dot(axis, triangle.a)
  let pb = dot(axis, triangle.b)
  let pc = dot(axis, triangle.c)
  result.min = min(pa, pb, pc)
  result.max = max(pa, pb, pc)

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
  ## checks if `point` inside convex hull formed by `planes`
  result = true
  for plane in planes:
    if distance(plane, point) < 0:
      return false


proc inside*(points: open_array[Vec2]; point: Vec2): bool =
  ## checks if `point` inside convex hull formed by `points` in clockwise direction
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


proc inside*(triangle: Triangle; point: Vec2): bool =
  ## checks if `point` inside `triangle`
  let c0 = signed_area(point, triangle.a, triangle.b) < 0f
  let c1 = signed_area(point, triangle.b, triangle.c) < 0f
  let c2 = signed_area(point, triangle.c, triangle.a) < 0f
  result = (c0 == c1) and (c1 == c2)

# --------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------

proc overlaps*(a: Rectangle; b: Rectangle): bool =
  let over_x = (a.left < b.right) and (a.right > b.left)
  let over_y = (a.top < b.bottom) and (a.bottom > b.top)
  result = over_x and over_y

# ConvexHull

func overlaps*(a: ConvexHull; b: ConvexHull): bool =
  for plane in a.planes:
    let axis = plane.normal
    let pa = a.project(axis)
    let pb = b.project(axis)
    if not overlaps(pa, pb):
      # found separating axis
      return false
  result = true

# Triangle

func overlaps*(a: Triangle; b: Triangle): bool =
  let axis1 = left(a.b - a.a)
  let pa1 = project(a, axis1)
  let pb1 = project(b, axis1)
  if not overlaps(pa1, pb1): return false

  let axis2 = left(a.c - a.b)
  let pa2 = project(a, axis2)
  let pb2 = project(b, axis2)
  if not overlaps(pa2, pb2): return false

  let axis3 = left(a.a - a.c)
  let pa3 = project(a, axis3)
  let pb3 = project(b, axis3)
  if not overlaps(pa3, pb3): return false

  result = true


func overlaps*(a: Triangle; b: Plane2): bool =
  let da = b.distance(a.a)
  let db = b.distance(a.b)
  let dc = b.distance(a.c)
  result = (da <= 0f) or (db <= 0f) or (dc <= 0f)

# AABB2

func overlaps*(a: AABB2; b: AABB2): bool =
  let d0 = int(b.max.x < a.min.x)
  let d1 = int(a.max.x < b.min.x)
  let d2 = int(b.max.y < a.min.y)
  let d3 = int(a.max.y < b.min.y)
  result = not bool(d0 or d1 or d2 or d3)


func overlaps*(a: AABB2; b: Circle): bool =
  let L  = clamp(b.pos, a.min, a.max)
  let ab = b.pos - L
  let d2 = dot(ab, ab)
  let r2 = b.radius * b.radius
  result = d2 < r2


func overlaps*(a: AABB2; b: ConvexHull): bool =
  for plane in b.planes:
    let axis = plane.normal
    let pa = a.project(axis)
    let pb = b.project(axis)
    if not overlaps(pa, pb):
      # found separating axis
      return false
  result = true


func overlaps*(a: AABB2; b: Triangle): bool =
  let axis1 = left(b.b - b.a)
  let pa1 = project(a, axis1)
  let pb1 = project(b, axis1)
  if not overlaps(pa1, pb1): return false

  let axis2 = left(b.c - b.b)
  let pa2 = project(a, axis2)
  let pb2 = project(b, axis2)
  if not overlaps(pa2, pb2): return false

  let axis3 = left(b.a - b.c)
  let pa3 = project(a, axis3)
  let pb3 = project(b, axis3)
  if not overlaps(pa3, pb3): return false

  result = true

# Circle

proc overlaps*(a: Circle; b: Circle): bool =
  let r2 = a.radius + b.radius
  result = distance_sq(a.pos, b.pos) < (r2 * r2)


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
    if a.pos != b.pos:
      info.normal = direction(b.pos, a.pos)
    else:
      info.normal = vec2(1f, 0f)


proc overlaps*(a_points, b_points: open_array[Vec2]; info: var CollisionInfo) =
  ## checks if two convex hulls formed by points overlaps
  ## points must be in clockwise order
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

  info.hit = (dx >= 0) and (dy >= 0)

  if info.hit:
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


func overlaps*(a: Triangle; b: Plane2; info: var CollisionInfo) =
  let da = b.distance(a.a)
  let db = b.distance(a.b)
  let dc = b.distance(a.c)
  info.hit = (da <= 0f) or (db <= 0f) or (dc <= 0f)
  if info.hit:
    info.normal = b.normal
    info.depth  = abs min(da, db, dc)


func overlaps*(a: Triangle; b: Triangle; info: var CollisionInfo) =
  let axis1 = left(a.b - a.a).normalize
  let pa1 = project(a, axis1)
  let pb1 = project(b, axis1)
  if not overlaps(pa1, pb1):
    return

  info.normal = axis1; info.depth = depth(pa1, pb1)

  let axis2 = left(a.c - a.b).normalize
  let pa2 = project(a, axis2)
  let pb2 = project(b, axis2)
  if not overlaps(pa2, pb2):
    return

  let d2 = depth(pa2, pb2)
  if abs(d2) < abs(info.depth): (info.normal = axis2; info.depth = d2)

  let axis3 = left(a.a - a.c).normalize
  let pa3 = project(a, axis3)
  let pb3 = project(b, axis3)
  if not overlaps(pa3, pb3):
    return

  let d3 = depth(pa3, pb3)
  if abs(d3) < abs(info.depth): (info.normal = axis3; info.depth = d3)

  info.hit = true


func overlaps*(a: ConvexHull; b: ConvexHull; info: var CollisionInfo) =
  info.depth = high float32

  for plane in a.planes:
    let axis = plane.normal
    let pa = a.project(axis)
    let pb = b.project(axis)
    if not overlaps(pa, pb):
      return
    else:
      let depth = depth(pa, pb)
      if abs(depth) < abs(info.depth):
        info.depth = depth
        info.normal = axis

  for plane in b.planes:
    let axis = plane.normal
    let pa = a.project(axis)
    let pb = b.project(axis)
    if not overlaps(pa, pb):
      return
    else:
      let depth = depth(pa, pb)
      if abs(depth) < abs(info.depth):
        info.depth = depth
        info.normal = axis

  info.hit = true

# --------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------

proc ray_test*(ray: Ray2; circle: Circle): bool =
  ## checks if `ray` overlaps `circle`
  let d = circle.pos - ray.origin
  let r = ray.direction
  let l = ray.direction.left
  let X = abs(dot(d, l)) <= circle.radius
  let Y = dot(d, r) >= 0
  let Z = len_sq(d) <= circle.radius * circle.radius
  result = (X and Y) or Z


proc ray_cast*(ray: Ray2; circle: Circle; out_ray: out Ray2): bool =
  let d = circle.pos - ray.origin
  let r = ray.direction
  let l = ray.direction.left
  let a = dot(d, l)
  let b = dot(d, r)
  if (abs(a) > circle.radius) or (b < 0f):
    result = false
  else:
    result = true
    let t = sqrt(circle.radius * circle.radius - a * a)
    out_ray.origin = ray.origin + ray.direction * (b - t)
    out_ray.direction = normalize(out_ray.origin - circle.pos)

# --------------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------------

func support*(circle: Circle; dir: Vec2): Vec2 =
  result = circle.pos + (dir * circle.radius)

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

# --------------------------------------------------------------------------------------------------

proc selftest* =
  block: # Aabb2
    var a1 = aabb2(vec2(-1, -1), vec2(+1, +1))
    var a2 = aabb2(vec2(+2, +2), vec2(+3, +3))
    var a3 = aabb2(vec2(-2, -2), vec2(+2, +2))
    var a4 = aabb2(vec2(-3, -3), vec2(+3, +3))
    do_assert(overlaps(a1, a2) == false)
    do_assert(overlaps(a1, a1) == true)
    do_assert(overlaps(a2, a2) == true)
    do_assert(overlaps(a3, a3) == true)
    do_assert(overlaps(a1, a3) == true)
    do_assert(overlaps(a3, a1) == true)
    do_assert(overlaps(a4, a3) == true)
    do_assert(overlaps(a1, a4) == true)
    do_assert(overlaps(a4, a2) == true)

    do_assert(inside(a1, vec2(+0f, +0f)) == true)
    do_assert(inside(a1, vec2(+2f, +0f)) == false)
    do_assert(inside(a1, vec2(+0f, +2f)) == false)
    do_assert(inside(a1, vec2(+2f, +2f)) == false)
    do_assert(inside(a1, vec2(+0f, -2f)) == false)
    do_assert(inside(a1, vec2(-2f, -2f)) == false)
    do_assert(inside(a1, vec2(-2f, +2f)) == false)
    do_assert(inside(a1, vec2(0.1f, 0.1f)) == true)

  block:
    discard

  echo "shapes2.selftest ok"

