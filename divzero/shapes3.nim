import divzero / [vec4, mat4, aabb3]
import std / [math]

# --------------------------------------------------------------------------------------------------

type Plane* = object
  a*, b*, c*, d*: float32

# --------------------------------------------------------------------------------------------------

func plane*(v: Vec4): Plane =
  result.a = v.x
  result.b = v.y
  result.c = v.z
  result.d = v.w


func plane*(normal, point: Vec4): Plane =
  result.a = normal.x
  result.b = normal.y
  result.c = normal.z
  result.d = dot(normal, point)


func plane_cw*(a, b, c: Vec4): Plane =
  let n = normalize(cross(a - c, a - b))
  result.a = n.x
  result.b = n.y
  result.c = n.z
  result.d = dot(n, a)


func plane_ccw*(a, b, c: Vec4): Plane =
  let n = normalize(cross(a - b, a - c))
  result.a = n.x
  result.b = n.y
  result.c = n.z
  result.d = dot(n, a)

# ----------------------------------------------------------------------------------------

func normal*(plane: Plane): Vec4 =
  result.x = plane.a
  result.y = plane.b
  result.z = plane.c
  result.w = 0.0f


func normalize*(plane: var Plane) =
  let m = plane.normal.len()
  plane.a = plane.a / m
  plane.b = plane.b / m
  plane.c = plane.c / m
  plane.d = plane.d / m


func distance*(plane: Plane; point: Vec4): float32 =
  result = (plane.a * point.x) + (plane.b * point.y) + (plane.c * point.z) + plane.d

# --------------------------------------------------------------------------------------------------

type Sphere* = object
  x*, y*, z*, r*: float32

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

type Ray3* = object
  origin*, direction*: Vec4

# ----------------------------------------------------------------------------------------

type RaycastInfo* = object
  point*: Vec4
  normal*: Vec4
  depth*: float32
  hit*: bool


func ray3*(origin, direction: Vec4): Ray3 =
  result.origin = origin
  result.direction = direction


proc ray_cast*(ray: Ray3; plane: Plane; info: out RaycastInfo) =
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
