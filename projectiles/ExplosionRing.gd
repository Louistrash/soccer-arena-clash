extends Node2D
## Cartoon explosion ring for soccer ball impact.

var _life: float = 0.25

func _process(delta: float) -> void:
	_life -= delta
	queue_redraw()
	if _life <= 0:
		queue_free()

func _draw() -> void:
	var alpha: float = clampf(_life / 0.25, 0.0, 1.0)
	var r: float = 20.0 + (1.0 - alpha) * 50.0
	draw_arc(Vector2.ZERO, r, 0, TAU, 24, Color(1.0, 1.0, 0.9, alpha * 0.6), 4.0)
	draw_arc(Vector2.ZERO, r * 0.7, 0, TAU, 24, Color(1.0, 1.0, 1.0, alpha * 0.3), 2.0)
