extends CanvasLayer
## View toggle: switch between GAMEPLAY and OVERVIEW camera modes.

@onready var toggle_btn: Button = $Margin/VBox/ToggleButton

var _camera: Node
var _view_icon_node: Control = null
var _is_overview: bool = false

func _ready() -> void:
	layer = 30
	_style_button()
	if toggle_btn:
		toggle_btn.icon = null
		toggle_btn.text = ""
		toggle_btn.focus_mode = Control.FOCUS_NONE
		toggle_btn.pressed.connect(_on_toggle_pressed)
		_view_icon_node = Control.new()
		_view_icon_node.set_script(load("res://ui/ViewIconDraw.gd") as GDScript)
		_view_icon_node.custom_minimum_size = Vector2(32, 32)
		_view_icon_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_view_icon_node.set_anchors_preset(Control.PRESET_FULL_RECT)
		toggle_btn.add_child(_view_icon_node)
		_view_icon_node.set("overview_mode", false)

func setup(p_camera: Node) -> void:
	_camera = p_camera

func _style_button() -> void:
	if not toggle_btn:
		return
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.08, 0.12, 0.9)
	sb.set_corner_radius_all(8)
	sb.set_border_width_all(1)
	sb.border_color = Color(0.2, 0.95, 0.5, 0.4)
	toggle_btn.add_theme_stylebox_override("normal", sb)
	toggle_btn.add_theme_stylebox_override("hover", sb)
	var sb_pressed := sb.duplicate() as StyleBoxFlat
	sb_pressed.bg_color = Color(0.04, 0.12, 0.16, 0.9)
	toggle_btn.add_theme_stylebox_override("pressed", sb_pressed)

func _on_toggle_pressed() -> void:
	if _camera and _camera.has_method("toggle_mode"):
		_camera.toggle_mode()
	_is_overview = not _is_overview
	if _view_icon_node:
		_view_icon_node.set("overview_mode", _is_overview)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_overview"):
		if _camera and _camera.has_method("toggle_mode"):
			_camera.toggle_mode()
		_is_overview = not _is_overview
		if _view_icon_node:
			_view_icon_node.set("overview_mode", _is_overview)
		get_viewport().set_input_as_handled()
