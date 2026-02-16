extends Node2D
## Tiled arena floor with subtle color variation, grid lines, and soccer field markings.

const TILE_SIZE := 64
const ARENA_W := 8000
const ARENA_H := 5000
const BASE_COLOR := Color(0.122, 0.373, 0.227)  # #1f5f3a
const VARIATION := 0.03

# Field bounds (must match GameCamera constants)
const FX1 := 200
const FX2 := 4000
const FY1 := 150
const FY2 := 2500
const FIELD_CX := 2100
const FIELD_CY := 1325
const HALFWAY := 2100
const PENALTY_W := 400
const PENALTY_H_RATIO := 0.4
const CENTER_R := 200
const GOAL_BOX_W := 150
const GOAL_BOX_H_RATIO := 0.2

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	# Center floor tiles on the field center
	var ox: int = FIELD_CX - ARENA_W / 2
	var oy: int = FIELD_CY - ARENA_H / 2
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

	# --- Soccer field markings ---
	var field_w: float = FX2 - FX1
	var field_h: float = FY2 - FY1
	var field_color := Color(1.0, 1.0, 1.0, 0.45)
	var line_w: float = 3.0

	# Outer field rectangle
	draw_rect(Rect2(FX1, FY1, field_w, field_h), field_color, false, line_w)

	# Halfway line
	draw_line(Vector2(HALFWAY, FY1), Vector2(HALFWAY, FY2), field_color, line_w)

	# Center circle
	draw_arc(Vector2(FIELD_CX, FIELD_CY), CENTER_R, 0, TAU, 64, field_color, line_w)

	# Center dot
	draw_circle(Vector2(FIELD_CX, FIELD_CY), 8.0, field_color)

	# Penalty areas (large boxes)
	var pen_h: float = field_h * PENALTY_H_RATIO
	var pen_top: float = FIELD_CY - pen_h
	var pen_bot: float = FIELD_CY + pen_h
	# Left penalty area
	draw_rect(Rect2(FX1, pen_top, PENALTY_W, pen_h * 2), field_color, false, line_w)
	# Right penalty area
	draw_rect(Rect2(FX2 - PENALTY_W, pen_top, PENALTY_W, pen_h * 2), field_color, false, line_w)

	# Goal boxes (6-yard boxes)
	var gbox_h: float = field_h * GOAL_BOX_H_RATIO
	var gbox_top: float = FIELD_CY - gbox_h
	var gbox_bot: float = FIELD_CY + gbox_h
	# Left goal box
	draw_rect(Rect2(FX1, gbox_top, GOAL_BOX_W, gbox_h * 2), field_color, false, line_w)
	# Right goal box
	draw_rect(Rect2(FX2 - GOAL_BOX_W, gbox_top, GOAL_BOX_W, gbox_h * 2), field_color, false, line_w)

	# Penalty spots
	var pen_spot_dist: float = 280.0
	draw_circle(Vector2(FX1 + pen_spot_dist, FIELD_CY), 6.0, field_color)
	draw_circle(Vector2(FX2 - pen_spot_dist, FIELD_CY), 6.0, field_color)

	# Corner arcs
	var corner_r: float = 40.0
	draw_arc(Vector2(FX1, FY1), corner_r, 0, PI * 0.5, 16, field_color, line_w)
	draw_arc(Vector2(FX2, FY1), corner_r, PI * 0.5, PI, 16, field_color, line_w)
	draw_arc(Vector2(FX1, FY2), corner_r, -PI * 0.5, 0, 16, field_color, line_w)
	draw_arc(Vector2(FX2, FY2), corner_r, PI, PI * 1.5, 16, field_color, line_w)
