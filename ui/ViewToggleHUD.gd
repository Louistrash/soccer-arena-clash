extends CanvasLayer
## View toggle: switch between GAMEPLAY and OVERVIEW camera modes.

@onready var toggle_btn: Button = $Margin/VBox/ToggleButton

var _camera: Node

func _ready() -> void:
	layer = 30
	_style_button()
	var icon := load("res://ui/icons/toggle_view.png") as Texture2D
	if toggle_btn:
		if icon:
			toggle_btn.icon = icon
			toggle_btn.text = ""
			toggle_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		toggle_btn.focus_mode = Control.FOCUS_NONE
		toggle_btn.pressed.connect(_on_toggle_pressed)

func setup(p_camera: Node) -> void:
	_camera = p_camera

func _style_button() -> void:
	if not toggle_btn:
		return
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.06, 0.09, 0.13, 0.82)
	sb.set_corner_radius_all(12)
	sb.set_border_width_all(2)
	sb.border_color = Color(0.0, 0.85, 1.0, 0.75)
	toggle_btn.add_theme_stylebox_override("normal", sb)
	toggle_btn.add_theme_stylebox_override("hover", sb)
	var sb_pressed := sb.duplicate() as StyleBoxFlat
	sb_pressed.bg_color = Color(0.04, 0.12, 0.16, 0.9)
	toggle_btn.add_theme_stylebox_override("pressed", sb_pressed)

func _on_toggle_pressed() -> void:
	if _camera and _camera.has_method("toggle_mode"):
		_camera.toggle_mode()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_overview"):
		if _camera and _camera.has_method("toggle_mode"):
			_camera.toggle_mode()
		get_viewport().set_input_as_handled()
