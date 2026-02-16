extends Camera2D
## Smart Soccer Camera: pro dual-mode with auto-framing.

enum Mode { GAMEPLAY, OVERVIEW }

signal mode_changed(new_mode: Mode)

var target: Node2D

# Fixed field bounds (matches ArenaFloor field lines)
const FIELD_LEFT := 200.0
const FIELD_RIGHT := 4000.0
const FIELD_TOP := 150.0
const FIELD_BOTTOM := 2500.0
const FIELD_CENTER := Vector2(2100.0, 1325.0)

# Mode state
var current_mode: Mode = Mode.GAMEPLAY
var target_zoom := Vector2(1.1, 1.1)
var target_position := Vector2.ZERO

# Gameplay zoom
var gameplay_zoom := Vector2(1.1, 1.1)

# Follow strength per mode
var gameplay_follow_speed := 6.0
var overview_follow_speed := 4.0

# Transition speed (ease-out feel via lerp weight)
var transition_speed := 5.0

# Trauma / shake (gameplay only)
var trauma := 0.0
var trauma_decay := 2.0
var max_offset := Vector2(4, 3)
var max_tilt := 0.012

func _ready() -> void:
	add_to_group("game_camera")
	target_zoom = gameplay_zoom
	zoom = gameplay_zoom
	# Set camera limits to field bounds with small margin
	limit_left = int(FIELD_LEFT - 200)
	limit_right = int(FIELD_RIGHT + 200)
	limit_top = int(FIELD_TOP - 200)
	limit_bottom = int(FIELD_BOTTOM + 200)
	limit_smoothed = true

func _process(delta: float) -> void:
	var player_pos: Vector2 = FIELD_CENTER
	if target and is_instance_valid(target):
		player_pos = target.global_position

	if current_mode == Mode.GAMEPLAY:
		# Tight player follow
		target_position = player_pos
		global_position = global_position.lerp(target_position, gameplay_follow_speed * delta)

		# Trauma decay + shake
		trauma = max(trauma - trauma_decay * delta, 0)
		if trauma > 0.01:
			var shake_strength := trauma * trauma
			offset = Vector2(
				randf_range(-max_offset.x, max_offset.x),
				randf_range(-max_offset.y, max_offset.y)
			) * shake_strength
			rotation = randf_range(-max_tilt, max_tilt) * shake_strength
		else:
			offset = Vector2.ZERO
			rotation = lerp(rotation, 0.0, 8.0 * delta)
	else:
		# Overview: smart field framing with soft player pull (20%)
		target_position = FIELD_CENTER.lerp(player_pos, 0.20)
		global_position = global_position.lerp(target_position, overview_follow_speed * delta)

		# No shake in overview, smooth out any residual
		offset = offset.lerp(Vector2.ZERO, 8.0 * delta)
		rotation = lerp(rotation, 0.0, 8.0 * delta)
		trauma = 0.0

	# Smooth zoom transition (ease-out via lerp)
	zoom = zoom.lerp(target_zoom, transition_speed * delta)

func _calculate_overview_zoom() -> Vector2:
	var viewport_size: Vector2 = get_viewport_rect().size
	if viewport_size.x <= 0 or viewport_size.y <= 0:
		return Vector2(0.3, 0.3)
	var field_w: float = FIELD_RIGHT - FIELD_LEFT
	var field_h: float = FIELD_BOTTOM - FIELD_TOP
	# Calculate zoom to fit field in viewport with 8% padding
	var zoom_x: float = viewport_size.x / (field_w * 1.08)
	var zoom_y: float = viewport_size.y / (field_h * 1.08)
	var z: float = min(zoom_x, zoom_y)
	return Vector2(z, z)

func set_mode(mode: Mode) -> void:
	current_mode = mode
	if mode == Mode.GAMEPLAY:
		target_zoom = gameplay_zoom
		# Restore camera limits for gameplay
		limit_left = int(FIELD_LEFT - 200)
		limit_right = int(FIELD_RIGHT + 200)
		limit_top = int(FIELD_TOP - 200)
		limit_bottom = int(FIELD_BOTTOM + 200)
	else:
		target_zoom = _calculate_overview_zoom()
		# Widen limits slightly so field center stays centered
		limit_left = int(FIELD_LEFT - 600)
		limit_right = int(FIELD_RIGHT + 600)
		limit_top = int(FIELD_TOP - 600)
		limit_bottom = int(FIELD_BOTTOM + 600)
	mode_changed.emit(mode)

func toggle_mode() -> void:
	if current_mode == Mode.GAMEPLAY:
		set_mode(Mode.OVERVIEW)
	else:
		set_mode(Mode.GAMEPLAY)

func is_overview_mode() -> bool:
	return current_mode == Mode.OVERVIEW

func add_trauma(amount: float) -> void:
	if current_mode == Mode.GAMEPLAY:
		trauma = clampf(trauma + amount, 0.0, 1.0)

func zoom_combat() -> void:
	pass
