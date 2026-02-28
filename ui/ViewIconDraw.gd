extends Control
## Draws a view-toggle icon programmatically (expand/arrows style). No PNG needed.
## overview_mode = true draws a "zoom out" icon, false draws a "gameplay" icon.

var overview_mode: bool = false:
	set(v):
		overview_mode = v
		queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y
	var cx := w * 0.5
	var cy := h * 0.5
	var col := Color(1.0, 1.0, 1.0, 0.85)
	var arm := w * 0.26
	var tip := w * 0.10

	if not overview_mode:
		# Four corner arrows pointing outward (expand / overview icon)
		_draw_arrow(Vector2(cx - arm, cy - arm), Vector2(-tip, -tip), col)
		_draw_arrow(Vector2(cx + arm, cy - arm), Vector2(tip, -tip), col)
		_draw_arrow(Vector2(cx + arm, cy + arm), Vector2(tip, tip), col)
		_draw_arrow(Vector2(cx - arm, cy + arm), Vector2(-tip, tip), col)
	else:
		# Four corner arrows pointing inward (collapse / gameplay icon)
		_draw_arrow(Vector2(cx - arm * 0.4, cy - arm * 0.4), Vector2(tip, tip), col)
		_draw_arrow(Vector2(cx + arm * 0.4, cy - arm * 0.4), Vector2(-tip, tip), col)
		_draw_arrow(Vector2(cx + arm * 0.4, cy + arm * 0.4), Vector2(-tip, -tip), col)
		_draw_arrow(Vector2(cx - arm * 0.4, cy + arm * 0.4), Vector2(tip, -tip), col)

func _draw_arrow(origin: Vector2, direction: Vector2, col: Color) -> void:
	var perp := Vector2(-direction.y, direction.x).normalized() * direction.length() * 0.7
	draw_line(origin, origin + direction, col, 2.0, true)
	draw_line(origin, origin + perp, col, 2.0, true)
