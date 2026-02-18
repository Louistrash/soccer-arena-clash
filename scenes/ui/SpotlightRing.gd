extends Control
## Glowing ring behind selected hero in spotlight panel.

var glow_color: Color = Color(0.2, 0.95, 0.7)

func _draw() -> void:
	var cx := size.x * 0.5
	var cy := size.y * 0.5
	# Outer glow (soft)
	for i in range(4):
		var r: float = 68.0 + float(i) * 4.0
		var alpha: float = 0.15 - float(i) * 0.03
		draw_arc(Vector2(cx, cy), r, 0, TAU, 48, Color(glow_color.r, glow_color.g, glow_color.b, alpha))
	# Main ring
	draw_arc(Vector2(cx, cy), 62.0, 0, TAU, 48, Color(glow_color.r, glow_color.g, glow_color.b, 0.6))
