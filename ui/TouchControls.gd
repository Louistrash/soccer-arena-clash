extends CanvasLayer
## Touch controls: move joystick (left) + aim/shoot joystick (right).
## Right joystick: drag to aim, release to shoot (Brawl Stars style).
## Only visible on touch devices. Feeds InputRouter.

@onready var move_joystick: Control = $Root/MoveJoystick
@onready var aim_joystick: Control = $Root/AimJoystick

func _ready() -> void:
	layer = 25
	if not _is_touch_device():
		queue_free()
		return
	visible = true
	# Remove shoot button if it exists (no longer needed)
	var shoot_btn: Node = get_node_or_null("Root/ShootButton")
	if shoot_btn:
		shoot_btn.queue_free()
	_setup_connections()

func _is_touch_device() -> bool:
	var os_name: String = OS.get_name()
	if os_name in ["iOS", "Android"]:
		return true
	if os_name == "Web":
		# Op Web: meerdere checks - iPad in desktopmodus rapporteert vaak maxTouchPoints=0
		if OS.has_feature("web"):
			var js := """
			(function() {
				if (navigator.maxTouchPoints > 0) return true;
				if ('ontouchstart' in window) return true;
				if (window.matchMedia && window.matchMedia('(pointer: coarse)').matches) return true;
				// Tablet-viewport fallback (iPad etc. wanneer maxTouchPoints faalt)
				var w = window.innerWidth || screen.width;
				var h = window.innerHeight || screen.height;
				return (w <= 1024 || h <= 900);
			})()
			"""
			var result = JavaScriptBridge.eval(js, true)
			return result == true
		return false
	# Native desktop: alleen bij fysieke touchscreen
	return DisplayServer.is_touchscreen_available()

func _setup_connections() -> void:
	if move_joystick and move_joystick.has_signal("output_changed"):
		move_joystick.output_changed.connect(_on_move_output)
	if aim_joystick:
		if aim_joystick.has_signal("output_changed"):
			aim_joystick.output_changed.connect(_on_aim_output)
		if aim_joystick.has_signal("released_with_direction"):
			aim_joystick.released_with_direction.connect(_on_aim_released)

func _process(_delta: float) -> void:
	if not move_joystick:
		return
	if InputRouter:
		InputRouter.set_touch_move(move_joystick.output)

func _on_move_output(v: Vector2) -> void:
	if InputRouter:
		InputRouter.set_touch_move(v)

func _on_aim_output(v: Vector2) -> void:
	if InputRouter and v.length_squared() > 0.01:
		InputRouter.set_touch_aim(v)

func _on_aim_released(direction: Vector2) -> void:
	# Shoot in the aimed direction on release
	if InputRouter:
		InputRouter.set_touch_aim(direction)
		InputRouter.set_touch_shoot(true)
