extends Control
## Procedural role icon: Striker (target), Defender (shield), General (crown), fallback (star).

var role: String = ""

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var cx: float = size.x * 0.5
	var cy: float = size.y * 0.5
	var s: float = min(size.x, size.y) * 0.4

	match role.to_lower():
		"striker", "shooter", "finisher":
			_draw_target(cx, cy, s)
		"defender":
			_draw_shield(cx, cy, s)
		"general":
			_draw_crown(cx, cy, s)
		"playmaker", "midfielder", "forward":
			_draw_playmaker(cx, cy, s)
		"dribbler", "sprint":
			_draw_dribbler(cx, cy, s)
		_:
			_draw_star(cx, cy, s)

func _draw_target(cx: float, cy: float, s: float) -> void:
	var c := Color(1.0, 0.4, 0.25)
	# Crosshairs / target
	draw_line(Vector2(cx - s, cy), Vector2(cx + s, cy), c, 2.0)
	draw_line(Vector2(cx, cy - s), Vector2(cx, cy + s), c, 2.0)
	draw_arc(Vector2(cx, cy), s * 0.5, 0, TAU, 16, c)
	draw_arc(Vector2(cx, cy), s, 0, TAU, 16, Color(c.r, c.g, c.b, 0.5))

func _draw_shield(cx: float, cy: float, s: float) -> void:
	var c := Color(0.4, 0.6, 1.0)
	var pts := PackedVector2Array([
		Vector2(cx, cy - s),
		Vector2(cx + s * 0.8, cy - s * 0.3),
		Vector2(cx + s * 0.8, cy + s * 0.5),
		Vector2(cx, cy + s),
		Vector2(cx - s * 0.8, cy + s * 0.5),
		Vector2(cx - s * 0.8, cy - s * 0.3),
	])
	draw_colored_polygon(pts, c)
	draw_polyline(pts, Color(c.r, c.g, c.b, 0.8), 1.5)

func _draw_crown(cx: float, cy: float, s: float) -> void:
	var c := Color(0.95, 0.78, 0.25)
	var pts := PackedVector2Array([
		Vector2(cx - s, cy + s * 0.3),
		Vector2(cx - s * 0.5, cy),
		Vector2(cx, cy - s),
		Vector2(cx + s * 0.5, cy),
		Vector2(cx + s, cy + s * 0.3),
	])
	draw_colored_polygon(pts, c)
	draw_polyline(pts, Color(c.r * 0.8, c.g * 0.8, c.b * 0.8), 1.0)

func _draw_playmaker(cx: float, cy: float, s: float) -> void:
	var c := Color(0.2, 0.7, 1.0)
	# Passing arcs
	draw_arc(Vector2(cx - s * 0.3, cy), s * 0.5, -PI * 0.5, PI * 0.5, 12, c)
	draw_arc(Vector2(cx + s * 0.3, cy), s * 0.5, PI * 0.5, PI * 1.5, 12, c)
	draw_circle(Vector2(cx, cy), s * 0.2, c)

func _draw_dribbler(cx: float, cy: float, s: float) -> void:
	var c := Color(0.7, 0.3, 0.95)
	# Zigzag / motion
	for i in range(3):
		var y := cy - s + float(i) * s
		var x_off := s * 0.4 if i % 2 == 1 else -s * 0.4
		draw_circle(Vector2(cx + x_off, y), s * 0.25, c)

func _draw_star(cx: float, cy: float, s: float) -> void:
	var c := Color(0.6, 0.8, 0.6)
	var pts := PackedVector2Array()
	for i in range(5):
		var a1 := -PI * 0.5 + TAU * float(i) / 5.0
		var a2 := -PI * 0.5 + TAU * (float(i) + 0.5) / 5.0
		pts.append(Vector2(cx + cos(a1) * s, cy + sin(a1) * s))
		pts.append(Vector2(cx + cos(a2) * s * 0.5, cy + sin(a2) * s * 0.5))
	draw_colored_polygon(pts, c)
