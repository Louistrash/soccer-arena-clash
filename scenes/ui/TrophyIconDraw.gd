extends Control
## Procedural gold trophy cup icon for hero cards.

const GOLD := Color(0.95, 0.78, 0.25)
const GOLD_DARK := Color(0.75, 0.6, 0.15)

func _draw() -> void:
	var cx := size.x * 0.5
	var cy := size.y * 0.5
	# Cup body (trapezoid)
	var cup_points := PackedVector2Array([
		Vector2(cx - 6, cy - 4),
		Vector2(cx + 6, cy - 4),
		Vector2(cx + 5, cy + 6),
		Vector2(cx - 5, cy + 6),
	])
	draw_colored_polygon(cup_points, GOLD)
	# Stem
	draw_rect(Rect2(cx - 2, cy + 6, 4, 4), GOLD_DARK)
	# Base
	draw_rect(Rect2(cx - 8, cy + 9, 16, 3), GOLD)
	# Handles (arcs)
	draw_arc(Vector2(cx - 8, cy), 3, -PI * 0.5, PI * 0.5, 8, GOLD)
	draw_arc(Vector2(cx + 8, cy), 3, PI * 0.5, PI * 1.5, 8, GOLD)
