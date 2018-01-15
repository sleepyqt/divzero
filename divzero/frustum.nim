import divzero / [shapes3, vec4, aabb3, mat4]

# --------------------------------------------------------------------------------------------------

type Frustum* = object
  p*: array[6, Plane]

# --------------------------------------------------------------------------------------------------

proc from_matrix*(m: Mat4): Frustum =
  let mx = vec4(m.c0.x, m.c1.x, m.c2.x, m.c3.x)
  let my = vec4(m.c0.y, m.c1.y, m.c2.y, m.c3.y)
  let mz = vec4(m.c0.z, m.c1.z, m.c2.z, m.c3.z)
  let mw = vec4(m.c0.w, m.c1.w, m.c2.w, m.c3.w)
  result.p[0] = plane(mw + mx)
  result.p[1] = plane(mw - mx)
  result.p[2] = plane(mw + my)
  result.p[3] = plane(mw - my)
  result.p[4] = plane(mw + mz)
  result.p[5] = plane(mw - mz)
  for p in result.p.mitems:
    p.normalize()


proc inside*(frustum: Frustum; point: Vec4): bool =
  for plane in frustum.p:
    if distance(plane, point) < 0: return false
  return true


proc inside*(frustum: Frustum; box: AABB4): bool =
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
