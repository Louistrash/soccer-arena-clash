extends Control
## Overgrown arena background: dark grass, stadium lines, vine overlays, lighting gradients.

const GRASS_PATH := "res://obstacles/grass.png"
const VINES_PATH := "res://obstacles/rock_vines.png"

var _grass_tex: Texture2D
var _vines_tex: Texture2D

func _ready() -> void:
	_grass_tex = load(GRASS_PATH) as Texture2D
	_vines_tex = load(VINES_PATH) as Texture2D
	queue_redraw()

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)

	# Base gradient (fallback)
	var top_color := Color(0.05, 0.12, 0.08)
	var bot_color := Color(0.08, 0.18, 0.12)
	var points := PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])
	var colors := PackedColorArray([top_color, top_color, bot_color, bot_color])
	draw_polygon(points, colors)

	# Grass texture overlay (dark modulate)
	if _grass_tex:
		var grass_color := Color(0.08, 0.14, 0.1)
		draw_set_transform(Vector2.ZERO, 0, Vector2(size.x / float(_grass_tex.get_width()), size.y / float(_grass_tex.get_height())))
		draw_texture(_grass_tex, Vector2.ZERO, grass_color)
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

	# Subtle grass stripes (stadium lines feel)
	var stripe_color := Color(1, 1, 1, 0.04)
	for y_pos in range(0, int(size.y), 48):
		draw_line(Vector2(0, y_pos), Vector2(size.x, y_pos), stripe_color, 1.0)

	# Stadium lines: center horizontal, penalty boxes, center circle
	var line_color := Color(0.3, 0.5, 0.35, 0.07)
	var cx := size.x * 0.5
	var cy := size.y * 0.5
	draw_line(Vector2(0, cy), Vector2(size.x, cy), line_color, 2.0)
	draw_line(Vector2(size.x * 0.2, 0), Vector2(size.x * 0.2, size.y), line_color, 1.5)
	draw_line(Vector2(size.x * 0.8, 0), Vector2(size.x * 0.8, size.y), line_color, 1.5)
	draw_arc(Vector2(cx, cy), 80.0, 0, TAU, 32, line_color)

	# Vine overlays at edges
	if _vines_tex:
		var vine_color := Color(1, 1, 1, 0.12)
		var vine_w := min(200.0, size.x * 0.15)
		draw_texture_rect_region(_vines_tex, Rect2(0, 0, vine_w, size.y), Rect2(0, 0, _vines_tex.get_width(), _vines_tex.get_height()), vine_color)
		draw_texture_rect_region(_vines_tex, Rect2(size.x - vine_w, 0, vine_w, size.y), Rect2(0, 0, _vines_tex.get_width(), _vines_tex.get_height()), vine_color)

	# Stadium lighting gradients (top corners)
	for i in range(10):
		var r: float = 350.0 - float(i) * 38.0
		var alpha: float = 0.025 + float(i) * 0.004
		draw_circle(Vector2(80, 40), r, Color(0.9, 0.95, 0.7, alpha))
		draw_circle(Vector2(size.x - 80, 40), r, Color(0.9, 0.95, 0.7, alpha))
