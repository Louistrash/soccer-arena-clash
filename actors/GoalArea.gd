extends Area2D
## Goal zone: detects ball entry, emits goal_scored(team).
## Draws a proper soccer goal with posts, crossbar, and net pattern.

@export var team: String = "left"

signal goal_scored(team_name: String)

# Goal dimensions
const GOAL_WIDTH := 60.0
const GOAL_HEIGHT := 500.0
const POST_THICKNESS := 8.0
const NET_SPACING := 24.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()

func _draw() -> void:
	var hw: float = GOAL_WIDTH * 0.5
	var hh: float = GOAL_HEIGHT * 0.5
	var post_color := Color(1.0, 1.0, 1.0, 0.95)
	var net_color := Color(1.0, 1.0, 1.0, 0.15)
	var fill_color := Color(0.0, 0.0, 0.0, 0.25)

	# Goal area background (dark)
	draw_rect(Rect2(-hw, -hh, GOAL_WIDTH, GOAL_HEIGHT), fill_color)

	# Net pattern (vertical lines)
	for x_off in range(0, int(GOAL_WIDTH), NET_SPACING):
		var xp: float = -hw + x_off
		draw_line(Vector2(xp, -hh), Vector2(xp, hh), net_color, 1.0)

	# Net pattern (horizontal lines)
	for y_off in range(0, int(GOAL_HEIGHT), NET_SPACING):
		var yp: float = -hh + y_off
		draw_line(Vector2(-hw, yp), Vector2(hw, yp), net_color, 1.0)

	# Goal posts (left and right vertical bars)
	draw_rect(Rect2(-hw, -hh, POST_THICKNESS, GOAL_HEIGHT), post_color)
	draw_rect(Rect2(hw - POST_THICKNESS, -hh, POST_THICKNESS, GOAL_HEIGHT), post_color)

	# Crossbar top
	draw_rect(Rect2(-hw, -hh, GOAL_WIDTH, POST_THICKNESS), post_color)
	# Crossbar bottom
	draw_rect(Rect2(-hw, hh - POST_THICKNESS, GOAL_WIDTH, POST_THICKNESS), post_color)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("ball"):
		goal_scored.emit(team)
