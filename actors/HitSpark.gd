extends Node2D
## Neon hit spark: colored flash matching laser.

var _life: float = 0.25
var spark_color: Color = Color(1, 1, 1, 1)

func _process(delta: float) -> void:
	_life -= delta
	queue_redraw()
	if _life <= 0:
		queue_free()

func _draw() -> void:
	var alpha: float = clampf(_life / 0.25, 0.0, 1.0)
	var outer: float = 12.0 * alpha
	var inner: float = 6.0 * alpha
	draw_circle(Vector2.ZERO, outer, Color(spark_color.r, spark_color.g, spark_color.b, alpha * 0.4))
	draw_circle(Vector2.ZERO, inner, Color(1, 1, 1, alpha * 0.8))
