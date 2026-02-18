extends Control
## Stadium hex pedestal card: 3D hexagonal shape, holographic glow ring,
## metallic teal border (normal) or gold border (selected).

const STADIUM_GOLD := Color(0.94, 0.75, 0.25)
const CARD_BG := Color(0.05, 0.1, 0.16, 0.92)
const CARD_BG_TOP := Color(0.08, 0.16, 0.24, 0.7)
const TEAL_BORDER := Color(0.13, 0.63, 0.7)
const TEAL_GLOW := Color(0.0, 0.9, 1.0)
const SHADOW_COL := Color(0, 0, 0, 0.55)

var hero_data: Dictionary = {}
var hero_texture: Texture2D
var is_selected: bool = false

var _glow_pulse_val: float = 1.0
var glow_pulse: float:
	get: return _glow_pulse_val
	set(v):
		_glow_pulse_val = v
		queue_redraw()

var _hero_rect: TextureRect
var _name_label: Label
var _role_icon: Control
var _idle_tween: Tween
var _pulse_tween: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	clip_contents = false
	_clamp_size()

func _draw() -> void:
	var cx := size.x * 0.5
	var cy := size.y * 0.5
	var card_r := Rect2(Vector2.ZERO, size)

	# Holographic glow ellipse underneath
	var glow_cx := cx
	var glow_cy := size.y + 4.0
	var glow_w := size.x * 0.7
	var glow_h := 16.0
	var glow_col: Color
	if is_selected:
		glow_col = Color(STADIUM_GOLD.r, STADIUM_GOLD.g, STADIUM_GOLD.b, 0.4 * _glow_pulse_val)
	else:
		glow_col = Color(TEAL_GLOW.r, TEAL_GLOW.g, TEAL_GLOW.b, 0.2)
	_draw_ellipse_filled(Vector2(glow_cx, glow_cy), glow_w, glow_h, glow_col)
	if is_selected:
		_draw_ellipse_filled(Vector2(glow_cx, glow_cy), glow_w * 1.4, glow_h * 1.8, Color(STADIUM_GOLD.r, STADIUM_GOLD.g, STADIUM_GOLD.b, 0.12 * _glow_pulse_val))

	# Shadow
	var shadow_pts := _hex_points(cx + 3, cy + 4, size.x * 0.48, size.y * 0.46)
	draw_colored_polygon(shadow_pts, SHADOW_COL)

	# Card body (hex shape)
	var body_pts := _hex_points(cx, cy, size.x * 0.48, size.y * 0.46)
	draw_colored_polygon(body_pts, CARD_BG)

	# Top gradient overlay
	var top_h := size.y * 0.45
	var grad_pts := PackedVector2Array([
		Vector2(size.x * 0.08, size.y * 0.06),
		Vector2(size.x * 0.92, size.y * 0.06),
		Vector2(size.x * 0.92, top_h),
		Vector2(size.x * 0.08, top_h),
	])
	var grad_cols := PackedColorArray([CARD_BG_TOP, CARD_BG_TOP, Color(CARD_BG_TOP.r, CARD_BG_TOP.g, CARD_BG_TOP.b, 0.0), Color(CARD_BG_TOP.r, CARD_BG_TOP.g, CARD_BG_TOP.b, 0.0)])
	draw_polygon(grad_pts, grad_cols)

	# Border (hex outline)
	var border_col: Color
	var border_w: float
	if is_selected:
		border_col = Color(STADIUM_GOLD.r, STADIUM_GOLD.g, STADIUM_GOLD.b, 0.9 * _glow_pulse_val)
		border_w = 3.0
	else:
		border_col = Color(TEAL_BORDER.r, TEAL_BORDER.g, TEAL_BORDER.b, 0.6)
		border_w = 2.0
	var border_pts := _hex_points(cx, cy, size.x * 0.48, size.y * 0.46)
	border_pts.append(border_pts[0])
	draw_polyline(border_pts, border_col, border_w, true)

	# Inner highlight line (top edge of hex)
	if is_selected:
		var inner_pts := _hex_points(cx, cy, size.x * 0.45, size.y * 0.43)
		draw_line(inner_pts[5], inner_pts[0], Color(STADIUM_GOLD.r, STADIUM_GOLD.g, STADIUM_GOLD.b, 0.25), 1.5)
		draw_line(inner_pts[0], inner_pts[1], Color(STADIUM_GOLD.r, STADIUM_GOLD.g, STADIUM_GOLD.b, 0.25), 1.5)

func _hex_points(cx: float, cy: float, rx: float, ry: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(6):
		var angle := TAU * float(i) / 6.0 - PI / 2.0
		pts.append(Vector2(cx + cos(angle) * rx, cy + sin(angle) * ry))
	return pts

func _draw_ellipse_filled(center: Vector2, rx: float, ry: float, col: Color) -> void:
	var pts := PackedVector2Array()
	var segs := 24
	for i in range(segs):
		var a := TAU * float(i) / float(segs)
		pts.append(Vector2(center.x + cos(a) * rx, center.y + sin(a) * ry))
	draw_colored_polygon(pts, col)

func setup(data: Dictionary, tex: Texture2D) -> void:
	hero_data = data
	hero_texture = tex
	_build_ui()
	set_selected(false)
	queue_redraw()

func set_selected(selected: bool) -> void:
	if is_selected == selected:
		return
	is_selected = selected
	_update_size()
	queue_redraw()
	z_index = 10 if is_selected else 0

func _build_ui() -> void:
	# Hero sprite (upper 70%)
	var sprite_container := Control.new()
	sprite_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	sprite_container.anchor_bottom = 0.68
	sprite_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sprite_container)

	_hero_rect = TextureRect.new()
	_hero_rect.custom_minimum_size = Vector2(72, 72)
	_hero_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_hero_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_hero_rect.texture = hero_texture
	_hero_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hero_rect.set_anchors_preset(Control.PRESET_CENTER)
	sprite_container.add_child(_hero_rect)

	# Name + role at bottom
	var info_vbox := VBoxContainer.new()
	info_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	info_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	info_vbox.anchor_top = 0.68
	info_vbox.anchor_bottom = 1.0
	info_vbox.offset_bottom = -8
	add_child(info_vbox)

	_name_label = Label.new()
	_name_label.text = hero_data.get("name", "?")
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 13)
	_name_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.98))
	_name_label.add_theme_constant_override("outline_size", 2)
	_name_label.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.08))
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.add_child(_name_label)

	var role_container := HBoxContainer.new()
	role_container.alignment = BoxContainer.ALIGNMENT_CENTER
	role_container.add_theme_constant_override("separation", 4)
	role_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.add_child(role_container)

	_role_icon = Control.new()
	_role_icon.set_script(load("res://scenes/ui/RoleIconDraw.gd") as GDScript)
	_role_icon.role = hero_data.get("role", "")
	_role_icon.custom_minimum_size = Vector2(14, 14)
	_role_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	role_container.add_child(_role_icon)

	var role_lbl := Label.new()
	role_lbl.text = hero_data.get("role", "")
	role_lbl.add_theme_font_size_override("font_size", 10)
	role_lbl.add_theme_color_override("font_color", hero_data.get("glow", TEAL_GLOW))
	role_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	role_container.add_child(role_lbl)

func _update_size() -> void:
	custom_minimum_size = Vector2(120, 155)
	_clamp_size()

func _clamp_size() -> void:
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = Vector2(120, 155)

func start_idle_bounce() -> void:
	if _hero_rect == null:
		return
	if _idle_tween and _idle_tween.is_valid():
		_idle_tween.kill()
	_hero_rect.pivot_offset = _hero_rect.size * 0.5
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(_hero_rect, "scale", Vector2(1.06, 1.06), 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_idle_tween.tween_property(_hero_rect, "scale", Vector2.ONE, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func stop_idle_bounce() -> void:
	if _idle_tween and _idle_tween.is_valid():
		_idle_tween.kill()
	if _hero_rect:
		_hero_rect.scale = Vector2.ONE

func start_glow_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(self, "glow_pulse", 1.0, 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(self, "glow_pulse", 0.5, 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func stop_glow_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	glow_pulse = 1.0
	queue_redraw()
