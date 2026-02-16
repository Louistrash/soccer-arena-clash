extends Node2D
## Dust puff at feet when moving. Fades in 0.3s.

var _life: float = 0.3

func _process(delta: float) -> void:
	_life -= delta
	if _life <= 0:
		queue_free()

func _draw() -> void:
	var alpha: float = _life / 0.3
	draw_set_transform(Vector2.ZERO, 0, Vector2(1, 0.5))
	draw_circle(Vector2.ZERO, 6.0, Color(0.5, 0.45, 0.35, alpha))
