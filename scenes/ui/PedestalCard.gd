extends Control
## Brawl Stars-style pedestal: round base, glow ring, hero on top, depth shadow.
## Selected = larger, golden glow. Unselected = smaller, role-coded glow.

const STADIUM_GOLD := Color(0.95, 0.78, 0.25)
const PEDESTAL_DARK := Color(0.12, 0.14, 0.11)
const SHADOW_COLOR := Color(0, 0, 0, 0.5)

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
	_clamp_size()

func _draw() -> void:
	var cx := size.x * 0.5
	var cy := size.y * 0.5
	var base_radius: float = min(size.x, size.y) * 0.38
	var glow_radius: float = base_radius + 8.0

	# Depth shadow (oval, top-down perspective)
	var shadow_w := base_radius * 2.2
	var shadow_h := base_radius * 0.6
	_draw_oval(Vector2(cx, cy + base_radius * 0.4), Vector2(shadow_w, shadow_h), SHADOW_COLOR)

	# Pedestal base (dark circle)
	draw_circle(Vector2(cx, cy), base_radius, PEDESTAL_DARK)

	# Glow ring under hero
	var glow: Color = hero_data.get("glow", Color(0.4, 0.6, 1.0))
	if is_selected:
		glow = STADIUM_GOLD
	var alpha_mult: float = glow_pulse * (0.7 if is_selected else 0.4)
	for i in range(4):
		var r: float = glow_radius + float(i) * 6.0
		var a: float = (0.2 - float(i) * 0.04) * alpha_mult
		draw_arc(Vector2(cx, cy), r, 0, TAU, 32, Color(glow.r, glow.g, glow.b, a))
	draw_arc(Vector2(cx, cy), glow_radius, 0, TAU, 32, Color(glow.r, glow.g, glow.b, 0.6 * alpha_mult))

	# Border ring
	var border_color: Color = STADIUM_GOLD if is_selected else Color(glow.r, glow.g, glow.b, 0.5)
	var border_w: float = 4.0 if is_selected else 2.0
	draw_arc(Vector2(cx, cy), base_radius - 2, 0, TAU, 32, border_color)

func _draw_oval(center: Vector2, radii: Vector2, col: Color) -> void:
	var points := PackedVector2Array()
	var steps := 24
	for i in steps:
		var angle: float = TAU * float(i) / float(steps)
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, col)

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

func _build_ui() -> void:
	# Hero sprite container (centered on pedestal)
	var sprite_container := Control.new()
	sprite_container.set_anchors_preset(Control.PRESET_CENTER)
	sprite_container.anchor_left = 0.5
	sprite_container.anchor_right = 0.5
	sprite_container.anchor_top = 0.5
	sprite_container.anchor_bottom = 0.5
	sprite_container.offset_left = -60
	sprite_container.offset_top = -70
	sprite_container.offset_right = 60
	sprite_container.offset_bottom = 30
	sprite_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sprite_container)

	_hero_rect = TextureRect.new()
	_hero_rect.custom_minimum_size = Vector2(100, 100)
	_hero_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_hero_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_hero_rect.texture = hero_texture
	_hero_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite_container.add_child(_hero_rect)

	# Name + role at bottom
	var info_vbox := VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 2)
	info_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	info_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	info_vbox.anchor_top = 1.0
	info_vbox.anchor_bottom = 1.0
	info_vbox.offset_top = -48
	info_vbox.offset_bottom = 0
	info_vbox.offset_left = 8
	info_vbox.offset_right = -8
	add_child(info_vbox)

	var name_role_row := HBoxContainer.new()
	name_role_row.add_theme_constant_override("separation", 6)
	name_role_row.alignment = BoxContainer.ALIGNMENT_CENTER
	name_role_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.add_child(name_role_row)

	_name_label = Label.new()
	_name_label.text = hero_data.get("name", "?")
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 16)
	_name_label.add_theme_color_override("font_color", Color.WHITE)
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_role_row.add_child(_name_label)

	_role_icon = Control.new()
	_role_icon.set_script(load("res://scenes/ui/RoleIconDraw.gd") as GDScript)
	_role_icon.role = hero_data.get("role", "")
	_role_icon.custom_minimum_size = Vector2(16, 16)
	_role_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_role_row.add_child(_role_icon)

func _update_size() -> void:
	if is_selected:
		custom_minimum_size = Vector2(200, 260)
	else:
		custom_minimum_size = Vector2(140, 180)
	_clamp_size()

func _clamp_size() -> void:
	# Ensure size is set for layout
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = Vector2(140, 180)

func start_idle_bounce() -> void:
	if _hero_rect == null:
		return
	if _idle_tween and _idle_tween.is_valid():
		_idle_tween.kill()
	_hero_rect.pivot_offset = _hero_rect.size * 0.5
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(_hero_rect, "scale", Vector2(1.02, 1.02), 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_idle_tween.tween_property(_hero_rect, "scale", Vector2.ONE, 0.6).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func stop_idle_bounce() -> void:
	if _idle_tween and _idle_tween.is_valid():
		_idle_tween.kill()
	if _hero_rect:
		_hero_rect.scale = Vector2.ONE

func start_glow_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(self, "glow_pulse", 1.2, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(self, "glow_pulse", 0.85, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func stop_glow_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	glow_pulse = 1.0
	queue_redraw()
