import divzero / [vec4, mat4]
import std / [math]

# --------------------------------------------------------------------------------------------------

type AABB3* = object
  ## Axis-aligned bounding box
  min*: Vec4
  max*: Vec4

type Plane3* = object
  a*, b*, c*, d*: float32

type Sphere* = object
  x*, y*, z*, r*: float32

type Ray3* = object
  origin*, direction*: Vec4

type RaycastInfo* = object
  point*: Vec4
  normal*: Vec4
  depth*: float32
  hit*: bool

type Frustum* = object
  p*: array[6, Plane3]

# --------------------------------------------------------------------------------------------------
# AABB3
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
# Plane33
# --------------------------------------------------------------------------------------------------

func plane3*(v: Vec4): Plane3 =
  result.a = v.x
  result.b = v.y
  result.c = v.z
  result.d = v.w


func plane3*(normal, point: Vec4): Plane3 =
  result.a = normal.x
  result.b = normal.y
  result.c = normal.z
  result.d = dot(normal, point)


func plane3_cw*(a, b, c: Vec4): Plane3 =
  let n = normalize(cross(a - c, a - b))
  result.a = n.x
  result.b = n.y
  result.c = n.z
  result.d = dot(n, a)


func plane3_ccw*(a, b, c: Vec4): Plane3 =
  let n = normalize(cross(a - b, a - c))
  result.a = n.x
  result.b = n.y
  result.c = n.z
  result.d = dot(n, a)

# ----------------------------------------------------------------------------------------

func normal*(plane: Plane3): Vec4 =
  result.x = plane.a
  result.y = plane.b
  result.z = plane.c
  result.w = 0.0f


func normalize*(plane: var Plane3) =
  let m = plane.normal.len()
  plane.a = plane.a / m
  plane.b = plane.b / m
  plane.c = plane.c / m
  plane.d = plane.d / m


func distance*(plane: Plane3; point: Vec4): float32 =
  result = (plane.a * point.x) + (plane.b * point.y) + (plane.c * point.z) + plane.d

# --------------------------------------------------------------------------------------------------
# Sphere
# --------------------------------------------------------------------------------------------------

func sphere*(x, y, z, r: float32): Sphere =
  result = Sphere(x: x, y: y, z: z, r: r)


func sphere*(point: Vec4; radius: float32): Sphere =
  result.x = point.x
  result.y = point.y
  result.z = point.z
  result.r = radius


func position*(sphere: Sphere): Vec4 =
  result.x = sphere.x
  result.y = sphere.y
  result.z = sphere.z
  result.w = 1f


func inside*(sphere: Sphere; point: Vec4): bool =
  let x = point.x - sphere.x
  let y = point.y - sphere.y
  let z = point.z - sphere.z
  let m = x * x + y * y + z * z
  result = m < (sphere.r * sphere.r)


func overlaps*(a, b: Sphere): bool =
  let r = a.r + b.r
  let x = a.x - b.x
  let y = a.y - b.y
  let z = a.z - b.z
  let m = x * x + y * y + z * z
  result = m < (r * r)

# ----------------------------------------------------------------------------------------
# Ray3
# ----------------------------------------------------------------------------------------

func ray3*(origin, direction: Vec4): Ray3 =
  result.origin = origin
  result.direction = direction


proc ray_cast*(ray: Ray3; plane: Plane3; info: out RaycastInfo) =
  let pn = dot(ray.origin, plane.normal)
  let nd = dot(ray.direction, plane.normal)

  if nd >= 0f:
    info.hit = false
  else:
    let t = (plane.d - pn) / nd
    if t >= 0f:
      info.hit = true
      info.point  = ray.origin + ray.direction * t
      info.normal = plane.normal
      info.depth  = t
    else:
      info.hit = false


proc ray_cast*(ray: Ray3; sphere: Sphere; info: out RaycastInfo) =
  let d  = normalize(ray.direction)
  let e  = sphere.position - ray.origin
  let r2 = sphere.r * sphere.r
  let e2 = len_sq(e)
  let a  = dot(e, d)
  let b2 = e2 - (a * a)
  let f  = sqrt(abs(r2) - b2)
  var t  = a - f
  if r2 - (e2 - a * a) < 0f:
    info.hit = false
    return
  elif e2 < r2:
    t = a + f

  info.depth  = t
  info.hit    = true
  info.point  = ray.origin + d * t
  info.normal = direction(sphere.position, info.point)


proc ray_test*(ray: Ray3; box: AABB3): bool =
  let t1 = (box.min.x - ray.origin.x) / ray.direction.x
  let t2 = (box.max.x - ray.origin.x) / ray.direction.x
  let t3 = (box.min.y - ray.origin.y) / ray.direction.y
  let t4 = (box.max.y - ray.origin.y) / ray.direction.y
  let t5 = (box.min.z - ray.origin.z) / ray.direction.z
  let t6 = (box.max.z - ray.origin.z) / ray.direction.z
  let t7 = max(max(min(t1, t2), min(t3, t4)), min(t5, t6))
  let t8 = min(min(max(t1, t2), max(t3, t4)), max(t5, t6))
  (t8 > 0) and (t7 < t8)


func screen_ray*(x, y, width, height: float32; inv_pv: Mat4; length: float32): Ray3 =
  ## `x`, `y` - point on screen
  ## `width`, `height` - screen size
  ## `length` - ray length
  ## `inv_pv` - clip-to-world matrix
  let clip_n = to_cartesian_point(inv_pv * window_to_near_clip(x, y, width, height))
  let clip_f = to_cartesian_point(inv_pv * window_to_far_clip(x, y, width, height))
  ray3(clip_n, direction(clip_n, clip_f) * length)

# ----------------------------------------------------------------------------------------
# Frustum
# ----------------------------------------------------------------------------------------

func from_proj_view_matrix*(m: Mat4): Frustum =
  let mx = vec4(m.c0.x, m.c1.x, m.c2.x, m.c3.x)
  let my = vec4(m.c0.y, m.c1.y, m.c2.y, m.c3.y)
  let mz = vec4(m.c0.z, m.c1.z, m.c2.z, m.c3.z)
  let mw = vec4(m.c0.w, m.c1.w, m.c2.w, m.c3.w)
  result.p[0] = plane3(mw + mx)
  result.p[1] = plane3(mw - mx)
  result.p[2] = plane3(mw + my)
  result.p[3] = plane3(mw - my)
  result.p[4] = plane3(mw + mz)
  result.p[5] = plane3(mw - mz)
  for p in result.p.mitems:
    p.normalize()


func inside*(frustum: Frustum; point: Vec4): bool =
  for plane in frustum.p:
    if distance(plane, point) < 0: return false
  return true


func inside*(frustum: Frustum; box: AABB3): bool =
  ## returns true if world space AABB inside frustum
  let p0 = vec4(box.min.x, box.min.y, box.min.z, 1.0f)
  let p1 = vec4(box.max.x, box.min.y, box.min.z, 1.0f)
  let p2 = vec4(box.min.x, box.max.y, box.min.z, 1.0f)
  let p3 = vec4(box.max.x, box.max.y, box.min.z, 1.0f)

  let p4 = vec4(box.min.x, box.min.y, box.max.z, 1.0f)
  let p5 = vec4(box.max.x, box.min.y, box.max.z, 1.0f)
  let p6 = vec4(box.min.x, box.max.y, box.max.z, 1.0f)
  let p7 = vec4(box.max.x, box.max.y, box.max.z, 1.0f)

  for plane in frustum.p:
    let d0 = distance(plane, p0)
    let d1 = distance(plane, p1)
    let d2 = distance(plane, p2)
    let d3 = distance(plane, p3)

    let d4 = distance(plane, p4)
    let d5 = distance(plane, p5)
    let d6 = distance(plane, p6)
    let d7 = distance(plane, p7)

    let x0 = d0 < 0
    let x1 = d1 < 0
    let x2 = d2 < 0
    let x3 = d3 < 0

    let x4 = d4 < 0
    let x5 = d5 < 0
    let x6 = d6 < 0
    let x7 = d7 < 0

    if x0 and x1 and x2 and x3 and x4 and x5 and x6 and x7: return false
  result = true
