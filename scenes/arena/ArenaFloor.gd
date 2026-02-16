extends Node2D
## Tiled arena floor with subtle color variation and grid lines.

const TILE_SIZE := 64
const ARENA_W := 2000
const ARENA_H := 2000
const BASE_COLOR := Color(0.122, 0.373, 0.227)  # #1f5f3a
const VARIATION := 0.03

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42  # deterministic pattern
	var ox: int = 640 - ARENA_W / 2
	var oy: int = 360 - ARENA_H / 2
	# Draw tiles
	for x in range(0, ARENA_W, TILE_SIZE):
		for y in range(0, ARENA_H, TILE_SIZE):
			var v: float = rng.randf_range(-VARIATION, VARIATION)
			var c := Color(BASE_COLOR.r + v, BASE_COLOR.g + v, BASE_COLOR.b + v)
			draw_rect(Rect2(ox + x, oy + y, TILE_SIZE, TILE_SIZE), c)
	# Subtle grid lines
	var line_color := Color(0, 0, 0, 0.05)
	for x in range(0, ARENA_W + 1, TILE_SIZE):
		draw_line(Vector2(ox + x, oy), Vector2(ox + x, oy + ARENA_H), line_color)
	for y in range(0, ARENA_H + 1, TILE_SIZE):
		draw_line(Vector2(ox, oy + y), Vector2(ox + ARENA_W, oy + y), line_color)

	# Soccer field lines (playable area: ~80–1200 x, 80–640 y)
	const FX1 := 80
	const FX2 := 1200
	const FY1 := 80
	const FY2 := 640
	const HALFWAY := 640
	const PENALTY_W := 120
	const CENTER_R := 80
	var field_color := Color(1.0, 1.0, 1.0, 0.35)
	# Halfway line
	draw_line(Vector2(HALFWAY, FY1), Vector2(HALFWAY, FY2), field_color)
	# Outer field rectangle
	draw_line(Vector2(FX1, FY1), Vector2(FX2, FY1), field_color)
	draw_line(Vector2(FX2, FY1), Vector2(FX2, FY2), field_color)
	draw_line(Vector2(FX2, FY2), Vector2(FX1, FY2), field_color)
	draw_line(Vector2(FX1, FY2), Vector2(FX1, FY1), field_color)
	# Penalty area left
	draw_rect(Rect2(FX1, FY1, PENALTY_W, FY2 - FY1), field_color, false)
	# Penalty area right
	draw_rect(Rect2(FX2 - PENALTY_W, FY1, PENALTY_W, FY2 - FY1), field_color, false)
	# Center circle
	draw_arc(Vector2(640, 360), CENTER_R, 0, TAU, 32, field_color)
