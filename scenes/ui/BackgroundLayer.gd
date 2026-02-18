extends Control
## Stadium background: navy gradient, teal spotlight beams, hex pattern, center glow.

var center_glow_pos: Vector2 = Vector2(-9999, -9999)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y

	# Navy gradient base
	var top_col := Color(0.04, 0.06, 0.1)
	var bot_col := Color(0.08, 0.12, 0.19)
	var bg_pts := PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)])
	var bg_cols := PackedColorArray([top_col, top_col, bot_col, bot_col])
	draw_polygon(bg_pts, bg_cols)

	# Hex grid pattern (very subtle)
	var hex_col := Color(0.15, 0.35, 0.45, 0.04)
	var hex_size := 40.0
	var row_h := hex_size * 1.732
	var y := 0.0
	var row_idx := 0
	while y < h + row_h:
		var x_off := hex_size * 0.75 if row_idx % 2 == 1 else 0.0
		var x := x_off
		while x < w + hex_size:
			_draw_hex(Vector2(x, y), hex_size * 0.45, hex_col)
			x += hex_size * 1.5
		y += row_h * 0.5
		row_idx += 1

	# Spotlight beams from top corners
	_draw_spotlight_beam(Vector2(w * 0.12, 0), Vector2(w * 0.35, h * 0.7), 220.0, Color(0.0, 0.78, 0.88, 0.07))
	_draw_spotlight_beam(Vector2(w * 0.88, 0), Vector2(w * 0.65, h * 0.7), 220.0, Color(0.0, 0.78, 0.88, 0.07))
	# Inner beams (brighter, narrower)
	_draw_spotlight_beam(Vector2(w * 0.2, 0), Vector2(w * 0.4, h * 0.6), 140.0, Color(0.0, 0.85, 0.95, 0.05))
	_draw_spotlight_beam(Vector2(w * 0.8, 0), Vector2(w * 0.6, h * 0.6), 140.0, Color(0.0, 0.85, 0.95, 0.05))

	# Top edge glow (stadium lights)
	for i in range(15):
		var r: float = 400.0 - float(i) * 30.0
		var alpha: float = 0.02 + float(i) * 0.003
		draw_circle(Vector2(w * 0.15, -20), r, Color(0.0, 0.7, 0.9, alpha))
		draw_circle(Vector2(w * 0.85, -20), r, Color(0.0, 0.7, 0.9, alpha))

	# Center spotlight behind selected hero
	if center_glow_pos.x > -9999:
		var xform: Transform2D = get_global_transform_with_canvas().affine_inverse()
		var local_pos: Vector2 = xform * center_glow_pos
		for i in range(16):
			var r: float = 80.0 + float(i) * 32.0
			var alpha: float = 0.22 - float(i) * 0.012
			draw_arc(local_pos, r, 0, TAU, 40, Color(0.0, 0.8, 0.95, alpha))
		# Warm gold inner glow for selected
		for i in range(6):
			var r: float = 30.0 + float(i) * 18.0
			var alpha: float = 0.12 - float(i) * 0.015
			draw_arc(local_pos, r, 0, TAU, 32, Color(0.95, 0.78, 0.25, alpha))

func _draw_hex(center: Vector2, radius: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(6):
		var angle := TAU * float(i) / 6.0 - PI / 6.0
		pts.append(center + Vector2(cos(angle), sin(angle)) * radius)
	pts.append(pts[0])
	draw_polyline(pts, col, 1.0)

func _draw_spotlight_beam(origin: Vector2, target: Vector2, spread: float, col: Color) -> void:
	var dir := (target - origin).normalized()
	var perp := Vector2(-dir.y, dir.x)
	var p1 := origin - perp * 20.0
	var p2 := origin + perp * 20.0
	var p3 := target + perp * spread
	var p4 := target - perp * spread
	var pts := PackedVector2Array([p1, p2, p3, p4])
	var cols := PackedColorArray([col, col, Color(col.r, col.g, col.b, 0.0), Color(col.r, col.g, col.b, 0.0)])
	draw_polygon(pts, cols)
