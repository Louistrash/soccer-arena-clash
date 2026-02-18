extends Control
## Premium hero card: glassmorphism, role glow, stadium-grade polish.
## Selected = spotlight elevation, gold rim glow, subtle inner vignette.

const STADIUM_GOLD := Color(0.95, 0.78, 0.25)
const CARD_BG_DARK := Color(0.04, 0.07, 0.05, 0.92)
const CARD_BG_LIGHT := Color(0.08, 0.14, 0.1, 0.6)
const SHADOW_DEEP := Color(0, 0, 0, 0.6)
const SHADOW_SOFT := Color(0, 0, 0, 0.35)

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

# Styleboxes for drawing
var _bg_sb: StyleBoxFlat
var _border_sb: StyleBoxFlat

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	
	_bg_sb = StyleBoxFlat.new()
	_bg_sb.bg_color = CARD_BG_DARK
	_bg_sb.set_corner_radius_all(16)
	
	_border_sb = StyleBoxFlat.new()
	_border_sb.draw_center = false
	_border_sb.set_border_width_all(3)
	_border_sb.set_corner_radius_all(16)
	
	_clamp_size()

func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	
	# Deep shadow (elevation)
	var shadow_offs := 8 if is_selected else 6
	var shadow_rect := Rect2(Vector2(shadow_offs, shadow_offs), size - Vector2(shadow_offs, shadow_offs))
	draw_rect(shadow_rect, SHADOW_DEEP if is_selected else SHADOW_SOFT, true)
	
	# Base + subtle top gradient
	draw_rect(r, CARD_BG_DARK, true)
	var pts := PackedVector2Array([Vector2(0, 0), Vector2(size.x, 0), Vector2(size.x, size.y * 0.5), Vector2(0, size.y * 0.5)])
	var cols := PackedColorArray([CARD_BG_LIGHT, CARD_BG_LIGHT, CARD_BG_DARK, CARD_BG_DARK])
	draw_polygon(pts, cols)
	
	# Border
	var role_color: Color = hero_data.get("glow", Color.WHITE)
	if is_selected:
		_border_sb.border_color = STADIUM_GOLD
		_border_sb.border_color.a = _glow_pulse_val * 0.95
		_border_sb.set_border_width_all(4)
		# Subtle inner gold highlight (filled)
		draw_rect(Rect2(6, 6, size.x - 12, size.y - 12), Color(STADIUM_GOLD.r, STADIUM_GOLD.g, STADIUM_GOLD.b, 0.06), true)
	else:
		_border_sb.border_color = role_color
		_border_sb.border_color.a = 0.55
		_border_sb.set_border_width_all(2)
	
	draw_style_box(_border_sb, r)

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
	
	if is_selected:
		z_index = 10 # Pop to front
	else:
		z_index = 0

func _build_ui() -> void:
	# Hero sprite container (Top 2/3)
	var sprite_container := Control.new()
	sprite_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	sprite_container.anchor_bottom = 0.75
	sprite_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sprite_container)

	_hero_rect = TextureRect.new()
	_hero_rect.custom_minimum_size = Vector2(96, 96)
	_hero_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_hero_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_hero_rect.texture = hero_texture
	_hero_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Center sprite in top container
	_hero_rect.set_anchors_preset(Control.PRESET_CENTER)
	sprite_container.add_child(_hero_rect)

	# Name + role at bottom
	var info_vbox := VBoxContainer.new()
	info_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	info_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	info_vbox.anchor_top = 0.7
	info_vbox.anchor_bottom = 1.0
	info_vbox.offset_bottom = -10
	add_child(info_vbox)

	_name_label = Label.new()
	_name_label.text = hero_data.get("name", "?").to_upper()
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.add_theme_font_size_override("font_size", 16)
	_name_label.add_theme_color_override("font_color", Color(1.0, 0.98, 0.9))
	_name_label.add_theme_constant_override("outline_size", 2)
	_name_label.add_theme_color_override("font_outline_color", Color(0.1, 0.08, 0.05))
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.add_child(_name_label)
	
	# Role badge centered under name
	var role_container := HBoxContainer.new()
	role_container.alignment = BoxContainer.ALIGNMENT_CENTER
	info_vbox.add_child(role_container)

	_role_icon = Control.new()
	_role_icon.set_script(load("res://scenes/ui/RoleIconDraw.gd") as GDScript)
	_role_icon.role = hero_data.get("role", "")
	_role_icon.custom_minimum_size = Vector2(18, 18)
	_role_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	role_container.add_child(_role_icon)
	
	var role_lbl := Label.new()
	role_lbl.text = hero_data.get("role", "")
	role_lbl.add_theme_font_size_override("font_size", 11)
	role_lbl.add_theme_color_override("font_color", hero_data.get("glow", Color.WHITE))
	role_container.add_child(role_lbl)

func _update_size() -> void:
	# Larger premium cards
	custom_minimum_size = Vector2(160, 215)
	_clamp_size()
	
	# Scale animation is handled by tweens in HeroSelect.gd or start_idle_bounce
	if is_selected:
		pass

func _clamp_size() -> void:
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = Vector2(160, 215)

func start_idle_bounce() -> void:
	if _hero_rect == null:
		return
	if _idle_tween and _idle_tween.is_valid():
		_idle_tween.kill()
	_hero_rect.pivot_offset = _hero_rect.size * 0.5
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(_hero_rect, "scale", Vector2(1.05, 1.05), 0.7).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_idle_tween.tween_property(_hero_rect, "scale", Vector2.ONE, 0.7).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func stop_idle_bounce() -> void:
	if _idle_tween and _idle_tween.is_valid():
		_idle_tween.kill()
	if _hero_rect:
		_hero_rect.scale = Vector2.ONE

func start_glow_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.tween_property(self, "glow_pulse", 1.0, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(self, "glow_pulse", 0.5, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func stop_glow_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	glow_pulse = 1.0
	queue_redraw()

func _on_focus_entered() -> void:
	# For controller support
	gui_input.emit(InputEventMouseButton.new()) # Hacky signal propagation or just handle selection
	pass

