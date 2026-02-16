extends Area2D
## Goal zone: detects ball entry, emits goal_scored(team).

@export var team: String = "left"  # "left" or "right"

signal goal_scored(team_name: String)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _draw() -> void:
	var size: Vector2 = Vector2(40, 800)
	var rect: Rect2 = Rect2(-size / 2, size)
	var is_left: bool = position.x < 640
	var color: Color = Color(0.2, 0.4, 0.9, 0.4) if is_left else Color(0.9, 0.2, 0.2, 0.4)
	draw_rect(rect, color)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		var t: String = "right" if position.x > 640 else "left"
		goal_scored.emit(t)
