import divzero / [vec2]

# --------------------------------------------------------------------------------------------------

type Rectangle* = object
  pos*: Vec2
  size*: Vec2

# --------------------------------------------------------------------------------------------------

proc rectangle*(x, y, w, h: F32): Rectangle {.inline.} =
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
  result = rect.pos; result.y += rect.size.y - 1


proc top_right*(rect: Rectangle): Vec2 {.inline.} =
  result = rect.pos; result.x += rect.size.x - 1


proc bottom_right*(rect: Rectangle): Vec2 {.inline.} =
  result = rect.pos + rect.size - vec2(1, 1)


proc left*(rect: Rectangle): F32 {.inline.} =
  result = rect.pos.x


proc right*(rect: Rectangle): F32 {.inline.} =
  result = rect.pos.x + rect.size.x


proc top*(rect: Rectangle): F32 {.inline.} =
  result = rect.pos.y


proc bottom*(rect: Rectangle): F32 {.inline.} =
  result = rect.pos.y + rect.size.y


proc width*(rect: Rectangle): F32 {.inline.} =
  result = rect.size.x


proc height*(rect: Rectangle): F32 {.inline.} =
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


proc offset*(a: Rectangle; x, y: F32): Rectangle {.inline.} =
  result.pos.x = a.pos.x + x
  result.pos.y = a.pos.y + y
  result.size = a.size


proc offset_x*(a: Rectangle; size: F32): Rectangle {.inline.} =
  result.pos = a.pos + vec2(size, 0)
  result.size = a.size


proc offset_y*(a: Rectangle; size: F32): Rectangle {.inline.} =
  result.pos = a.pos + vec2(0, size)
  result.size = a.size


proc resize*(a: Rectangle; size: Size): Rectangle {.inline.} =
  result.pos = a.pos
  result.size = size


proc resize*(a: Rectangle; x, y: F32): Rectangle {.inline.} =
  result.pos = a.pos
  result.size = vec2(x, y)


proc resize_x*(a: Rectangle; size: F32): Rectangle {.inline.} =
  result.pos = a.pos
  result.size.x = size
  result.size.y = a.size.y


proc resize_y*(a: Rectangle; size: F32): Rectangle {.inline.} =
  result.pos = a.pos
  result.size.x = a.size.x
  result.size.y = size


proc scale*(a: Rectangle; size: Size): Rectangle {.inline.} =
  result.pos = a.pos
  result.size = a.size + size


proc scale*(a: Rectangle; x, y: F32): Rectangle {.inline.} =
  result.pos = a.pos
  result.size.x = a.size.x + x
  result.size.y = a.size.y + y


proc inflate*(a: Rectangle; size: Vec2): Rectangle {.inline.} =
  result.pos = a.pos - size / 2
  result.size = a.size + size


proc inflate*(a: Rectangle; x, y: F32): Rectangle {.inline.} =
  let size = vec2(x, y)
  result.pos  = a.pos  - size / 2
  result.size = a.size + size


proc set_x*(a: Rectangle; x: F32): Rectangle =
  result.pos = a.pos
  result.size = a.size
  result.pos.x = x


proc set_y*(a: Rectangle; y: F32): Rectangle =
  result.pos = a.pos
  result.size = a.size
  result.pos.y = y

# --------------------------------------------------------------------------------------------------

proc left_border*(a: Rectangle; width: F32): Rectangle =
  result.pos = a.pos
  result.size.x = width
  result.size.y = a.size.y


proc right_border*(a: Rectangle; width: F32): Rectangle =
  result.pos.x = a.pos.x + a.size.x - width
  result.pos.y = a.pos.y
  result.size.x = width
  result.size.y = a.size.y


proc bottom_border*(a: Rectangle; width: F32): Rectangle =
  result.pos.x = a.pos.x
  result.pos.y = a.pos.y + a.size.y - width
  result.size.x = a.size.x
  result.size.y = width

# --------------------------------------------------------------------------------------------------

proc split2_horz_pixels*(a: Rectangle; split_pos: F32): (Rectangle, Rectangle) =
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
  pos: Vec2
  radius: float32

# --------------------------------------------------------------------------------------------------

type Ray2* = object
  origin*, direction*: Vec2
