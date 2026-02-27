extends Control
## Draws a speaker icon programmatically. No PNG needed.
## Set `sound_on = true/false` to switch between on/off state.

var sound_on: bool = true:
	set(v):
		sound_on = v
		queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y
	var cx := w * 0.5
	var cy := h * 0.5
	var col := Color(1.0, 1.0, 1.0, 0.80)

	# Speaker body (left rectangle) — compact
	var body_w := w * 0.18
	var body_h := h * 0.28
	var body_x := cx - w * 0.22
	var body_y := cy - body_h * 0.5
	draw_rect(Rect2(body_x, body_y, body_w, body_h), col)

	# Speaker cone (triangle) — compact
	var cone_pts := PackedVector2Array([
		Vector2(body_x, body_y),
		Vector2(body_x, body_y + body_h),
		Vector2(cx - w * 0.04, cy + h * 0.24),
		Vector2(cx - w * 0.04, cy - h * 0.24),
	])
	draw_colored_polygon(cone_pts, col)

	if sound_on:
		# Two arcs = sound waves (subtle)
		var center := Vector2(cx - w * 0.02, cy)
		var arc_col := Color(1.0, 1.0, 1.0, 0.75)
		draw_arc(center, w * 0.14, -PI * 0.38, PI * 0.38, 12, arc_col, 1.5)
		draw_arc(center, w * 0.22, -PI * 0.43, PI * 0.43, 12, arc_col, 1.5)
	else:
		# X cross = muted
		var x1 := cx + w * 0.06
		var y1 := cy - h * 0.18
		var x2 := cx + w * 0.26
		var y2 := cy + h * 0.18
		var mute_col := Color(1.0, 0.35, 0.35, 0.90)
		draw_line(Vector2(x1, y1), Vector2(x2, y2), mute_col, 2.0, true)
		draw_line(Vector2(x2, y1), Vector2(x1, y2), mute_col, 2.0, true)
