extends CanvasLayer
## Glass Neon Arcade scoreboard. Floating HUD met neon glow.

@onready var timer_label: Label = $Margin/HBoxMain/TimerPanel/TimerLabel
@onready var float_target: Control = $Margin
@onready var info_panel: PanelContainer = $Margin/HBoxMain/InfoPanel
@onready var wave_label: Label = $Margin/HBoxMain/InfoPanel/HBoxInfo/WaveLabel
@onready var enemies_label: Label = $Margin/HBoxMain/InfoPanel/HBoxInfo/EnemiesLabel
@onready var status_label: Label = $Margin/HBoxMain/InfoPanel/HBoxInfo/StatusLabel
@onready var zone_label: Label = $Margin/HBoxMain/InfoPanel/HBoxInfo/ZoneLabel

var _idle_base_y: float = 0.0
var _spawner: Node

const PLAYER_COLOR: Color = Color(0.235, 1.0, 0.431)
const ENEMY_COLOR: Color = Color(1.0, 0.302, 0.302)
const ACCENT_COLOR: Color = Color(0.0, 0.898, 1.0)

func _ready() -> void:
	add_to_group("glass_scoreboard")
	_style_panels()
	if float_target:
		_idle_base_y = float_target.position.y

func setup(p_spawner: Node) -> void:
	_spawner = p_spawner
	if not _spawner:
		return
	if _spawner.has_signal("enemy_spawned"):
		_spawner.enemy_spawned.connect(_on_enemy_spawned)
	if _spawner.has_signal("enemy_count_changed"):
		_spawner.enemy_count_changed.connect(_on_enemy_count_changed)
	_refresh_info()

func _process(delta: float) -> void:
	# Idle floating hover
	if float_target:
		float_target.position.y = _idle_base_y + sin(Time.get_ticks_msec() * 0.002) * 2.0

func _style_panels() -> void:
	# Info panel (Brawlball style)
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.063, 0.094, 0.125, 0.65)
	sb.corner_radius_top_left = 24
	sb.corner_radius_top_right = 24
	sb.corner_radius_bottom_left = 24
	sb.corner_radius_bottom_right = 24
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = ACCENT_COLOR
	sb.shadow_size = 8
	sb.shadow_offset = Vector2(0, 3)
	sb.shadow_color = Color(0, 0, 0, 0.5)

	if info_panel:
		var isb: StyleBoxFlat = sb.duplicate()
		isb.corner_radius_top_left = 20
		isb.corner_radius_top_right = 20
		isb.corner_radius_bottom_left = 20
		isb.corner_radius_bottom_right = 20
		isb.bg_color = Color(0.043, 0.122, 0.102, 0.65)
		info_panel.add_theme_stylebox_override("panel", isb)
		for label in [wave_label, enemies_label, status_label, zone_label]:
			if label:
				label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.95))
		# Divider color (soft cyan)
		var div1: Label = $Margin/HBoxMain/InfoPanel/HBoxInfo/Divider1
		var div2: Label = $Margin/HBoxMain/InfoPanel/HBoxInfo/Divider2
		var div3: Label = $Margin/HBoxMain/InfoPanel/HBoxInfo/Divider3
		for div in [div1, div2, div3]:
			if div:
				div.add_theme_color_override("font_color", Color(0.0, 0.898, 1.0, 0.8))

	var timer_panel: PanelContainer = $Margin/HBoxMain/TimerPanel
	var tsb: StyleBoxFlat = sb.duplicate()
	tsb.corner_radius_top_left = 16
	tsb.corner_radius_top_right = 16
	tsb.corner_radius_bottom_left = 16
	tsb.corner_radius_bottom_right = 16
	timer_panel.add_theme_stylebox_override("panel", tsb)

	timer_label.add_theme_color_override("font_color", Color(1.0, 0.847, 0.302))

func set_timer_text(t: String, low_time: bool = false) -> void:
	timer_label.text = t
	if low_time:
		timer_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	else:
		timer_label.add_theme_color_override("font_color", Color(1.0, 0.847, 0.302))

func trigger_goal_glow() -> void:
	if info_panel:
		_glow_pulse(info_panel, 0.15, _create_info_panel_style())

func trigger_explosion_pulse() -> void:
	if info_panel:
		_glow_pulse(info_panel, 0.12, _create_info_panel_style())

func _refresh_info() -> void:
	if not _spawner:
		return
	var count: int = 0
	var wave: int = 0
	var zone: String = "CENTER"
	if _spawner.has_method("get_enemies_alive_count"):
		count = _spawner.get_enemies_alive_count()
	if _spawner.has_method("get_wave_number"):
		wave = _spawner.get_wave_number()
	if _spawner.has_method("get_last_spawn_zone"):
		zone = _spawner.get_last_spawn_zone()
	if wave_label:
		wave_label.text = "W%d  1v%d" % [wave, count]
	if enemies_label:
		enemies_label.text = "%d ENEMIES" % count
	if zone_label:
		zone_label.text = ""
	if status_label:
		if count >= 5:
			status_label.text = "HIGH PRESSURE"
		elif count >= 2:
			status_label.text = "ARENA ACTIVE"
		elif count == 1:
			status_label.text = "ONE LEFT"
		else:
			status_label.text = "FIELD CONTROL"

func _on_enemy_spawned(_enemy: Node, _pos: Vector2) -> void:
	_refresh_info()
	if info_panel:
		_glow_pulse(info_panel, 0.15, _create_info_panel_style())
	if enemies_label:
		_pop_scale(enemies_label)

func _on_enemy_count_changed(_count: int) -> void:
	_refresh_info()

func trigger_ball_spin() -> void:
	# Ball stays fixed; no spin animation
	pass

func _pop_scale(node: Control) -> void:
	var t: Tween = create_tween()
	t.tween_property(node, "scale", Vector2(1.25, 1.25), 0.08).set_ease(Tween.EASE_OUT)
	t.tween_property(node, "scale", Vector2(1.0, 1.0), 0.12).set_ease(Tween.EASE_IN_OUT)

func _glow_pulse(panel: PanelContainer, dur: float, restore_style: StyleBoxFlat = null) -> void:
	var sb: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	sb.border_color = Color(1.0, 1.0, 1.0, 0.9)
	sb.shadow_color = ACCENT_COLOR
	sb.shadow_size = 16
	panel.add_theme_stylebox_override("panel", sb)
	var style_to_restore: StyleBoxFlat = restore_style if restore_style else _create_default_panel_style()
	var t: Tween = create_tween()
	t.tween_interval(dur)
	t.tween_callback(func(): panel.add_theme_stylebox_override("panel", style_to_restore))

func _create_info_panel_style() -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.043, 0.122, 0.102, 0.65)
	sb.corner_radius_top_left = 20
	sb.corner_radius_top_right = 20
	sb.corner_radius_bottom_left = 20
	sb.corner_radius_bottom_right = 20
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = ACCENT_COLOR
	sb.shadow_size = 8
	sb.shadow_offset = Vector2(0, 3)
	sb.shadow_color = Color(0, 0, 0, 0.5)
	return sb

func _create_default_panel_style() -> StyleBoxFlat:
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.063, 0.094, 0.125, 0.65)
	sb.corner_radius_top_left = 24
	sb.corner_radius_top_right = 24
	sb.corner_radius_bottom_left = 24
	sb.corner_radius_bottom_right = 24
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = ACCENT_COLOR
	sb.shadow_size = 8
	sb.shadow_offset = Vector2(0, 3)
	sb.shadow_color = Color(0, 0, 0, 0.5)
	return sb
