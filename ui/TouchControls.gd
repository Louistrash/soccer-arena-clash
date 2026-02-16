extends CanvasLayer
## Touch controls overlay: move joystick + aim joystick + shoot button.
## Only visible on touch devices. Feeds InputRouter.

@onready var move_joystick: Control = $Root/MoveJoystick
@onready var aim_joystick: Control = $Root/AimJoystick
@onready var shoot_btn: Button = $Root/ShootButton

func _ready() -> void:
	layer = 25
	# Only show on touch devices
	if not _is_touch_device():
		queue_free()
		return
	visible = true
	_setup_connections()
	_style_shoot_button()

func _is_touch_device() -> bool:
	if DisplayServer.is_touchscreen_available():
		return true
	# Fallback: show on Web (iPad/Android) and mobile exports
	var os_name: String = OS.get_name()
	return os_name in ["iOS", "Android", "Web"]

func _setup_connections() -> void:
	if move_joystick and move_joystick.has_signal("output_changed"):
		move_joystick.output_changed.connect(_on_move_output)
	if aim_joystick and aim_joystick.has_signal("output_changed"):
		aim_joystick.output_changed.connect(_on_aim_output)
	if shoot_btn:
		shoot_btn.pressed.connect(_on_shoot_pressed)
		shoot_btn.button_down.connect(_on_shoot_down)
		shoot_btn.button_up.connect(_on_shoot_up)

func _process(_delta: float) -> void:
	if not move_joystick:
		return
	# Keep pushing move to InputRouter (joystick holds state)
	if InputRouter:
		InputRouter.set_touch_move(move_joystick.output)

func _on_move_output(v: Vector2) -> void:
	if InputRouter:
		InputRouter.set_touch_move(v)

func _on_aim_output(v: Vector2) -> void:
	if InputRouter and v.length_squared() > 0.01:
		InputRouter.set_touch_aim(v)

func _on_shoot_pressed() -> void:
	pass

func _on_shoot_down() -> void:
	if InputRouter:
		InputRouter.set_touch_shoot(true)

func _on_shoot_up() -> void:
	if InputRouter:
		InputRouter.set_touch_shoot(false)

func _style_shoot_button() -> void:
	if not shoot_btn:
		return
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.1, 0.5, 0.2, 0.7)
	sb.corner_radius_top_left = 40
	sb.corner_radius_top_right = 40
	sb.corner_radius_bottom_left = 40
	sb.corner_radius_bottom_right = 40
	sb.border_width_left = 3
	sb.border_width_top = 3
	sb.border_width_right = 3
	sb.border_width_bottom = 3
	sb.border_color = Color(0.3, 1.0, 0.5, 0.9)
	shoot_btn.add_theme_stylebox_override("normal", sb)
	var sb_pressed: StyleBoxFlat = sb.duplicate()
	sb_pressed.bg_color = Color(0.05, 0.35, 0.15, 0.9)
	shoot_btn.add_theme_stylebox_override("pressed", sb_pressed)
	shoot_btn.add_theme_color_override("font_color", Color.WHITE)
	shoot_btn.add_theme_font_size_override("font_size", 20)
