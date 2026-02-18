extends Node
## Unified input layer: keyboard + mouse (desktop) and touch (mobile/web).
## Autoload: InputRouter

var move_direction: Vector2 = Vector2.ZERO
var aim_direction: Vector2 = Vector2.RIGHT
var shoot_just_pressed: bool = false

var _hero_ref: WeakRef = WeakRef.new()
var _shoot_buffered: bool = false

# Touch input (set by TouchControls when active)
var _touch_move: Vector2 = Vector2.ZERO
var _touch_aim: Vector2 = Vector2.ZERO
var _touch_active: bool = false
var _touch_block_until: float = 0.0  # Block mouse na touch-shoot (dubbel-fire voorkomen)

func register_hero(hero: Node2D) -> void:
	_hero_ref = weakref(hero)

func get_hero() -> Node2D:
	return _hero_ref.get_ref() as Node2D

func consume_shoot() -> void:
	shoot_just_pressed = false
	_shoot_buffered = false

## Touch controls API (called by TouchControls)
func set_touch_move(v: Vector2) -> void:
	_touch_move = v
	if v.length_squared() > 0.01:
		_touch_active = true

func set_touch_aim(v: Vector2) -> void:
	_touch_aim = v
	if v.length_squared() > 0.01:
		_touch_active = true

func set_touch_shoot(pressed: bool) -> void:
	if pressed and not _shoot_buffered:
		_shoot_buffered = true
		shoot_just_pressed = true
	if pressed:
		_touch_block_until = Time.get_ticks_msec() / 1000.0 + 0.15

func _process(_delta: float) -> void:
	# Movement: prefer touch when active, else keyboard
	if _touch_move.length_squared() > 0.01:
		move_direction = _touch_move
	else:
		move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Aim: prefer touch when active, else mouse
	if _touch_aim.length_squared() > 0.01:
		aim_direction = _touch_aim.normalized()
	else:
		var hero: Node2D = _hero_ref.get_ref() as Node2D
		if hero:
			var mouse_pos: Vector2 = hero.get_global_mouse_position()
			var dir: Vector2 = mouse_pos - hero.global_position
			if dir.length_squared() > 1.0:
				aim_direction = dir.normalized()

	# Shoot: only from buffered flag (one shot per press)
	if _shoot_buffered:
		shoot_just_pressed = true
		_shoot_buffered = false

	# Clear _touch_active when geen touch input (user released)
	if _touch_move.length_squared() < 0.01 and _touch_aim.length_squared() < 0.01:
		_touch_active = false

func _input(event: InputEvent) -> void:
	# Op touch: negeer gesimuleerde muisklik (dubbel-fire). Alleen blocken bij actieve touch of net na touch-shoot.
	var now: float = Time.get_ticks_msec() / 1000.0
	var block_mouse: bool = (_touch_active or now < _touch_block_until) and event is InputEventMouseButton
	if block_mouse:
		return

	if event.is_action_pressed("shoot"):
		_shoot_buffered = true
		shoot_just_pressed = true
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_shoot_buffered = true
			shoot_just_pressed = true
