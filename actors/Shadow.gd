extends Node2D
## Team indicator: shadow + colored ring (green=hero, red=enemy, yellow=ball carrier).

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var parent := get_parent()

	# Shadow (flattened ellipse)
	draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.5))
	draw_circle(Vector2.ZERO, 22.0, Color(0, 0, 0, 0.25))

	# Team ring (reset transform)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	var color := Color(0.2, 0.9, 0.3, 0.7)
	if parent and not parent.is_in_group("hero"):
		color = Color(0.9, 0.2, 0.2, 0.7)
	draw_arc(Vector2.ZERO, 24.0, 0, TAU, 32, color, 2.5)
