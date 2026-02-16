extends Camera2D
## Juicy Striker Camera: gameplay / overview toggle, trauma shake, tilt.

enum Mode { GAMEPLAY, OVERVIEW }

signal mode_changed(new_mode: Mode)

var target: Node2D

# Mode zoom levels
var gameplay_zoom := Vector2(1.15, 1.15)
var overview_zoom := Vector2(0.55, 0.55)

# Mode state
var current_mode: Mode = Mode.GAMEPLAY
var target_zoom := Vector2(1.15, 1.15)

# Follow strength per mode (higher = snappier)
var gameplay_follow_speed := 6.0
var overview_follow_speed := 3.0

# Trauma / shake (disabled in overview)
var trauma := 0.0
var trauma_decay := 2.0
var max_offset := Vector2(4, 3)
var max_tilt := 0.012

# Field center for overview soft drift (optional)
var field_center := Vector2(640, 360)

func _ready() -> void:
	add_to_group("game_camera")
	target_zoom = gameplay_zoom
	zoom = gameplay_zoom

func _process(delta: float) -> void:
	# Target position: follow player
	var target_pos: Vector2 = field_center
	if target and is_instance_valid(target):
		target_pos = target.global_position

	var follow_speed := gameplay_follow_speed if current_mode == Mode.GAMEPLAY else overview_follow_speed
	global_position = global_position.lerp(target_pos, follow_speed * delta)

	# Trauma decay (only in gameplay)
	if current_mode == Mode.GAMEPLAY:
		trauma = max(trauma - trauma_decay * delta, 0)

	# Apply shake + tilt (only in gameplay, reduced in overview)
	if current_mode == Mode.GAMEPLAY and trauma > 0.01:
		var shake_strength := trauma * trauma
		offset = Vector2(
			randf_range(-max_offset.x, max_offset.x),
			randf_range(-max_offset.y, max_offset.y)
		) * shake_strength
		rotation = randf_range(-max_tilt, max_tilt) * shake_strength
	else:
		offset = Vector2.ZERO
		rotation = lerp(rotation, 0.0, 5 * delta)

	# Zoom interpolation (smooth ~0.25-0.5s transition)
	zoom = zoom.lerp(target_zoom, 4 * delta)

func set_mode(mode: Mode) -> void:
	current_mode = mode
	if mode == Mode.GAMEPLAY:
		target_zoom = gameplay_zoom
	else:
		target_zoom = overview_zoom
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
	# No-op: fixed zoom per mode. Kept for compatibility with SoccerBallProjectile.
	pass
