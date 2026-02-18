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
var _trophy_container: HBoxContainer
var _rank_tier_label: Label
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
	update_trophy_visuals(selected)
	queue_redraw()
	z_index = 10 if is_selected else 0

func _build_ui() -> void:
	# Hero sprite (upper 65%)
	var sprite_container := Control.new()
	sprite_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	sprite_container.anchor_bottom = 0.65
	sprite_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sprite_container)

	_hero_rect = TextureRect.new()
	_hero_rect.custom_minimum_size = Vector2(56, 56)
	_hero_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_hero_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_hero_rect.texture = hero_texture
	_hero_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hero_rect.set_anchors_preset(Control.PRESET_CENTER)
	sprite_container.add_child(_hero_rect)

	# Name + role at bottom
	var info_vbox := VBoxContainer.new()
	info_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	info_vbox.add_theme_constant_override("separation", 2)
	info_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	info_vbox.anchor_top = 0.65
	info_vbox.anchor_bottom = 1.0
	info_vbox.offset_bottom = -6
	add_child(info_vbox)

	_name_label = Label.new()
	_name_label.text = hero_data.get("name", "?")
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.text_overrun_behavior = TextServer.OVERRUN_TRUNCATE_ELLIPSIS
	_name_label.add_theme_font_size_override("font_size", 12)
	_name_label.add_theme_color_override("font_color", Color.WHITE)
	_name_label.add_theme_constant_override("outline_size", 1)
	_name_label.add_theme_color_override("font_outline_color", Color(0.02, 0.04, 0.08))
	_name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.add_child(_name_label)

	# Trophies (Directly under name, BEFORE role)
	_trophy_container = HBoxContainer.new()
	_trophy_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_trophy_container.add_theme_constant_override("separation", 3)
	_trophy_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_trophy_container.pivot_offset = Vector2(0, 0) # Will be updated after layout
	info_vbox.add_child(_trophy_container)

	var trophy_icon := Label.new()
	trophy_icon.text = "🏆"
	trophy_icon.add_theme_font_size_override("font_size", 14)
	trophy_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_trophy_container.add_child(trophy_icon)

	_trophy_label = Label.new()
	var trophy_count = hero_data.get("trophies", 0)
	_trophy_label.text = str(trophy_count)
	
	# Rank color logic (compact font sizes for 6-column layout)
	var trophy_color = STADIUM_GOLD
	var base_font_size = 14
	var outline_size = 2
	
	if trophy_count < 100:
		trophy_color = Color(0.85, 0.55, 0.2) # Bronze
		base_font_size = 12 # Smaller for low rank
	elif trophy_count < 300:
		trophy_color = Color(0.9, 0.9, 0.95) # Silver
	elif trophy_count < 600:
		trophy_color = Color(1.0, 0.84, 0.0) # Gold
	else:
		trophy_color = Color(0.6, 0.85, 1.0) # Diamond
		base_font_size = 15 # Larger for high rank
		outline_size = 3
		
	_trophy_label.add_theme_font_size_override("font_size", base_font_size)
	_trophy_label.add_theme_constant_override("outline_size", outline_size)
	_trophy_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	_trophy_label.set_meta("base_font_size", base_font_size) # Store for focus scaling
	
	_trophy_label.add_theme_color_override("font_color", trophy_color)
	_trophy_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_trophy_container.add_child(_trophy_label)

	# Rank Tier Label (Under trophies)
	_rank_tier_label = Label.new()
	_rank_tier_label.text = _get_rank_tier(trophy_count)
	_rank_tier_label.add_theme_font_size_override("font_size", 9)
	_rank_tier_label.add_theme_color_override("font_color", trophy_color)
	_rank_tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_rank_tier_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_vbox.add_child(_rank_tier_label)

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
	role_lbl.text_overrun_behavior = TextServer.OVERRUN_TRUNCATE_ELLIPSIS
	role_lbl.add_theme_font_size_override("font_size", 10)
	role_lbl.add_theme_color_override("font_color", hero_data.get("glow", TEAL_GLOW))
	role_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	role_container.add_child(role_lbl)

func _get_rank_tier(count: int) -> String:
	if count < 100: return "Bronze"
	if count < 200: return "Silver I"
	if count < 300: return "Silver II"
	if count < 400: return "Silver III"
	if count < 500: return "Gold I"
	if count < 600: return "Gold II"
	if count < 700: return "Gold III"
	return "Diamond"

func update_trophy_visuals(selected: bool) -> void:
	if not _trophy_container or not _trophy_label:
		return
		
	var base_scale := Vector2.ONE
	var base_font_size: int = _trophy_label.get_meta("base_font_size", 14)
	var outline_col := Color(0, 0, 0, 0.8)
	var outline_size := 2
	
	if selected:
		# Selected focus: Scale up trophy section, add glow
		_trophy_container.scale = Vector2(1.15, 1.15)
		_trophy_container.pivot_offset = _trophy_container.size / 2
		_trophy_label.add_theme_font_size_override("font_size", base_font_size + 2)
		_trophy_label.add_theme_color_override("font_outline_color", STADIUM_GOLD)
		_trophy_label.add_theme_constant_override("outline_size", 3)
	else:
		# Reset to normal
		_trophy_container.scale = Vector2.ONE
		_trophy_container.pivot_offset = Vector2.ZERO
		_trophy_label.add_theme_font_size_override("font_size", base_font_size)
		_trophy_label.add_theme_color_override("font_outline_color", outline_col)
		_trophy_label.add_theme_constant_override("outline_size", outline_size)

func _update_size() -> void:
	# Size controlled by grid; compact default for 6-column layout
	custom_minimum_size = Vector2(110, 155)
	_clamp_size()

func _clamp_size() -> void:
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = Vector2(110, 155)

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
