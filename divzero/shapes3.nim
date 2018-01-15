import divzero / [vec4]

# --------------------------------------------------------------------------------------------------

type Plane* = object
  a*, b*, c*, d*: float32

# --------------------------------------------------------------------------------------------------

proc plane*(v: Vec4): Plane =
  result.a = v.x
  result.b = v.y
  result.c = v.z
  result.d = v.w


proc plane*(normal, point: Vec4): Plane =
  result.a = normal.x
  result.b = normal.y
  result.c = normal.z
  result.d = dot(normal, point)


proc plane_cw*(a, b, c: Vec4): Plane =
  let n = normalize(cross(a - c, a - b))
  result.a = n.x
  result.b = n.y
  result.c = n.z
  result.d = dot(n, a)


proc plane_ccw*(a, b, c: Vec4): Plane =
  let n = normalize(cross(a - b, a - c))
  result.a = n.x
  result.b = n.y
  result.c = n.z
  result.d = dot(n, a)

# ----------------------------------------------------------------------------------------

proc normal*(plane: Plane): Vec4 =
  result.x = plane.a
  result.y = plane.b
  result.z = plane.c
  result.w = 0.0


proc normalize*(plane: var Plane) =
  let m = plane.normal.len()
  plane.a = plane.a / m
  plane.b = plane.b / m
  plane.c = plane.c / m
  plane.d = plane.d / m


proc distance*(plane: Plane; point: Vec4): float32 =
  result = plane.a * point.x + plane.b * point.y + plane.c * point.z + plane.d

# --------------------------------------------------------------------------------------------------

type Sphere* = object
  x*, y*, z*, r*: float32

# --------------------------------------------------------------------------------------------------

proc sphere*(x, y, z, r: float32): Sphere =
  result = Sphere(x: x, y: y, z: z, r: r)


proc sphere*(point: Vec4; radius: float32): Sphere =
  result.x = point.x
  result.y = point.y
  result.z = point.z
  result.r = radius

# --------------------------------------------------------------------------------------------------

proc inside*(sphere: Sphere; point: Vec4): bool =
  let x = point.x - sphere.x
  let y = point.y - sphere.y
  let z = point.z - sphere.z
  let m = x * x + y * y + z * z
  result = m < (sphere.r * sphere.r)


proc intersect*(a, b: Sphere): bool =
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

proc ray3*(origin, direction: Vec4): Ray3 =
  result.origin = origin
  result.direction = direction

