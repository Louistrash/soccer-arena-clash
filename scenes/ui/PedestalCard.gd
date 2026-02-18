extends Control
## Stadium FIFA-style card: Rounded rect, circular shadow, glow ring.
## Stadium green + gold palette.

const STADIUM_GOLD := Color(0.94, 0.75, 0.25)
const CARD_BG := Color(0.05, 0.1, 0.16, 0.92)
const CARD_BG_TOP := Color(0.08, 0.16, 0.24, 0.7)
const STADIUM_GREEN := Color(0.2, 0.95, 0.5)
const TEAL_GLOW := Color(0.0, 0.9, 1.0) # Kept for role text fallback
const SHADOW_COL := Color(0, 0, 0, 0.25) # Softer shadow

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
var _trophy_label: Label
var _idle_tween: Tween
var _pulse_tween: Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	clip_contents = false
	_clamp_size()

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, size)
	var radius := 12.0
	
	# 1. Soft circular shadow (underneath)
	var shadow_center := Vector2(size.x * 0.5, size.y - 10)
	var shadow_radius := size.x * 0.55
	draw_circle(shadow_center, shadow_radius, SHADOW_COL)

	# 2. Glow ring (only if selected)
	if is_selected:
		var glow_col := Color(STADIUM_GOLD.r, STADIUM_GOLD.g, STADIUM_GOLD.b, 0.5 * _glow_pulse_val)
		# Draw a glow rect slightly larger than the card
		var glow_rect := rect.grow(4.0)
		_draw_rounded_rect_outline(glow_rect, radius + 2, glow_col, 4.0)

	# 3. Card Body (Rounded Rect)
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = CARD_BG
	style_box.set_corner_radius_all(int(radius))
	style_box.draw(get_canvas_item(), rect)

	# 4. Top Gradient Overlay
	# We can't easily clip a polygon to a rounded rect in _draw without a shader or clip_children.
	# For simplicity, we'll skip the gradient or draw a smaller inner rect.
	# Let's try a StyleBox with gradient? No, StyleBoxFlat doesn't support gradient.
	# We'll just skip the complex gradient for now to keep it clean, or use a slightly lighter top part.
	
	# 5. Border
	var border_col: Color
	var border_w: float
	if is_selected:
		border_col = Color(STADIUM_GOLD.r, STADIUM_GOLD.g, STADIUM_GOLD.b, 0.9 * _glow_pulse_val)
		border_w = 3.0
	else:
		border_col = Color(STADIUM_GREEN.r, STADIUM_GREEN.g, STADIUM_GREEN.b, 0.4)
		border_w = 2.0
	
	_draw_rounded_rect_outline(rect, radius, border_col, border_w)

func _draw_rounded_rect_outline(rect: Rect2, radius: float, col: Color, width: float) -> void:
	var pts := PackedVector2Array()
	var corners := 4
	var segments := 8
	
	# Top-left
	for i in range(segments + 1):
		var angle = PI + (PI / 2) * i / segments
		pts.append(rect.position + Vector2(radius, radius) + Vector2(cos(angle), sin(angle)) * radius)
	
	# Top-right
	for i in range(segments + 1):
		var angle = 1.5 * PI + (PI / 2) * i / segments
		pts.append(rect.position + Vector2(rect.size.x - radius, radius) + Vector2(cos(angle), sin(angle)) * radius)
	
	# Bottom-right
	for i in range(segments + 1):
		var angle = 0 + (PI / 2) * i / segments
		pts.append(rect.position + Vector2(rect.size.x - radius, rect.size.y - radius) + Vector2(cos(angle), sin(angle)) * radius)
		
	# Bottom-left
	for i in range(segments + 1):
		var angle = PI / 2 + (PI / 2) * i / segments
		pts.append(rect.position + Vector2(radius, rect.size.y - radius) + Vector2(cos(angle), sin(angle)) * radius)
	
	pts.append(pts[0]) # Close loop
	draw_polyline(pts, col, width, true)

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
	_hero_rect.custom_minimum_size = Vector2(80, 80) # Slightly larger
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
	_name_label.add_theme_font_size_override("font_size", 14)
	_name_label.add_theme_color_override("font_color", Color.WHITE)
	_name_label.add_theme_constant_override("outline_size", 2)
	_name_label.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.08))
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.add_child(_name_label)

	var role_container := HBoxContainer.new()
	role_container.alignment = BoxContainer.ALIGNMENT_CENTER
	role_container.add_theme_constant_override("separation", 6)
	role_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.add_child(role_container)

	_role_icon = Control.new()
	_role_icon.set_script(load("res://scenes/ui/RoleIconDraw.gd") as GDScript)
	_role_icon.role = hero_data.get("role", "")
	_role_icon.custom_minimum_size = Vector2(18, 18) # Larger icon
	_role_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	role_container.add_child(_role_icon)

	var role_lbl := Label.new()
	role_lbl.text = hero_data.get("role", "")
	role_lbl.add_theme_font_size_override("font_size", 11)
	role_lbl.add_theme_color_override("font_color", hero_data.get("glow", TEAL_GLOW))
	role_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	role_container.add_child(role_lbl)

	# Trophies
	var trophy_container := HBoxContainer.new()
	trophy_container.alignment = BoxContainer.ALIGNMENT_CENTER
	trophy_container.add_theme_constant_override("separation", 2)
	trophy_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.add_child(trophy_container)

	var trophy_icon := Label.new()
	trophy_icon.text = "🏆"
	trophy_icon.add_theme_font_size_override("font_size", 10)
	trophy_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	trophy_container.add_child(trophy_icon)

	_trophy_label = Label.new()
	var trophy_count = hero_data.get("trophies", 0)
	_trophy_label.text = str(trophy_count)
	_trophy_label.add_theme_font_size_override("font_size", 12)
	
	# Rank color logic
	var trophy_color = STADIUM_GOLD
	if trophy_count < 100:
		trophy_color = Color(0.8, 0.5, 0.2) # Bronze
	elif trophy_count < 300:
		trophy_color = Color(0.75, 0.75, 0.75) # Silver
	else:
		trophy_color = STADIUM_GOLD # Gold
		
	_trophy_label.add_theme_color_override("font_color", trophy_color)
	_trophy_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	trophy_container.add_child(_trophy_label)

func _update_size() -> void:
	# Size controlled by grid, but we set min size
	custom_minimum_size = Vector2(140, 180) 
	_clamp_size()

func _clamp_size() -> void:
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = Vector2(140, 180)

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
	# 2s loop: 1s up, 1s down
	_pulse_tween.tween_property(self, "glow_pulse", 1.0, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(self, "glow_pulse", 0.5, 1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func stop_glow_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	glow_pulse = 1.0
	queue_redraw()
