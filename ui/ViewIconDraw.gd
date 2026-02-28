extends Control
## Draws a fullscreen/view-toggle icon programmatically. No PNG needed.
## overview_mode = true: inward arrows (collapse). false: outward arrows (expand).

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
	var lw := 2.0

	if not overview_mode:
		# Standard fullscreen / expand icon:
		# Four L-shaped brackets in each corner
		var m := w * 0.18   # margin from edge
		var s := w * 0.22   # arm length of bracket
		# Top-left bracket
		draw_line(Vector2(m, m + s), Vector2(m, m), col, lw, true)
		draw_line(Vector2(m, m), Vector2(m + s, m), col, lw, true)
		# Top-right bracket
		draw_line(Vector2(w - m, m + s), Vector2(w - m, m), col, lw, true)
		draw_line(Vector2(w - m, m), Vector2(w - m - s, m), col, lw, true)
		# Bottom-left bracket
		draw_line(Vector2(m, h - m - s), Vector2(m, h - m), col, lw, true)
		draw_line(Vector2(m, h - m), Vector2(m + s, h - m), col, lw, true)
		# Bottom-right bracket
		draw_line(Vector2(w - m, h - m - s), Vector2(w - m, h - m), col, lw, true)
		draw_line(Vector2(w - m, h - m), Vector2(w - m - s, h - m), col, lw, true)
	else:
		# Collapse / gameplay icon:
		# Four inward-pointing L-brackets (pointing toward center)
		var m := w * 0.30
		var s := w * 0.18
		# Top-left pointing in
		draw_line(Vector2(m + s, m), Vector2(m, m), col, lw, true)
		draw_line(Vector2(m, m), Vector2(m, m + s), col, lw, true)
		# Top-right pointing in
		draw_line(Vector2(w - m - s, m), Vector2(w - m, m), col, lw, true)
		draw_line(Vector2(w - m, m), Vector2(w - m, m + s), col, lw, true)
		# Bottom-left pointing in
		draw_line(Vector2(m + s, h - m), Vector2(m, h - m), col, lw, true)
		draw_line(Vector2(m, h - m), Vector2(m, h - m - s), col, lw, true)
		# Bottom-right pointing in
		draw_line(Vector2(w - m - s, h - m), Vector2(w - m, h - m), col, lw, true)
		draw_line(Vector2(w - m, h - m), Vector2(w - m, h - m - s), col, lw, true)
