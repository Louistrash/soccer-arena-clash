extends Control
## Virtual joystick for touch: outputs Vector2 (-1..1) based on drag.
## Emits released_with_direction when released while aiming (for shoot-on-release).

signal output_changed(value: Vector2)
signal released_with_direction(direction: Vector2)

var output: Vector2 = Vector2.ZERO:
	set(v):
		if output.distance_to(v) > 0.01:
			output = v
			output_changed.emit(output)

var _tracking_index: int = -1
var _center: Vector2
var _radius: float = 60.0
var _last_aim: Vector2 = Vector2.ZERO
const KNOB_RADIUS := 28.0
const SHOOT_THRESHOLD := 0.3

func _ready() -> void:
	_touch_update_rect()
	queue_redraw()

func _touch_update_rect() -> void:
	_center = size / 2
	_radius = min(size.x, size.y) * 0.35

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_touch_update_rect()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var ev: InputEventScreenTouch = event
		var local := get_global_transform_with_canvas().affine_inverse() * ev.position
		if ev.pressed:
			if _tracking_index < 0 and _is_inside(local):
				_tracking_index = ev.index
				_apply_position(local)
				accept_event()
		else:
			if ev.index == _tracking_index:
				_tracking_index = -1
				# Emit shoot signal if aim was strong enough
				if _last_aim.length() >= SHOOT_THRESHOLD:
					released_with_direction.emit(_last_aim.normalized())
				_last_aim = Vector2.ZERO
				output = Vector2.ZERO
				queue_redraw()
				accept_event()
	elif event is InputEventScreenDrag:
		var ev: InputEventScreenDrag = event
		if ev.index == _tracking_index:
			var local := get_global_transform_with_canvas().affine_inverse() * ev.position
			_apply_position(local)
			accept_event()

func _is_inside(local_pos: Vector2) -> bool:
	return (local_pos - _center).length() < _radius + KNOB_RADIUS

func _apply_position(local_pos: Vector2) -> void:
	var delta: Vector2 = local_pos - _center
	var len := delta.length()
	if len < 1.0:
		output = Vector2.ZERO
	else:
		var clamped := clampf(len / _radius, 0.0, 1.0)
		output = (delta / len) * clamped
	# Track last aim direction for shoot-on-release
	if output.length() >= SHOOT_THRESHOLD:
		_last_aim = output
	queue_redraw()

func _draw() -> void:
	var c := Color(1.0, 1.0, 1.0, 0.2)
	var c2 := Color(1.0, 1.0, 1.0, 0.5)
	# Base circle
	draw_arc(_center, _radius, 0, TAU, 32, c2, 4.0)
	# Knob
	var knob_pos := _center + output * _radius
	draw_circle(knob_pos, KNOB_RADIUS, c)
	draw_arc(knob_pos, KNOB_RADIUS, 0, TAU, 24, c2, 2.0)
	# Aim indicator (glow when strong enough to shoot)
	if output.length() >= SHOOT_THRESHOLD and _tracking_index >= 0:
		var aim_color := Color(0.3, 1.0, 0.5, 0.4)
		draw_arc(knob_pos, KNOB_RADIUS + 4, 0, TAU, 24, aim_color, 3.0)
