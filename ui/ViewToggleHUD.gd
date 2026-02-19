extends CanvasLayer
## View toggle: switch between GAMEPLAY and OVERVIEW camera modes.
## Glass neon arcade style, top-right.

@onready var toggle_btn: Button = $Margin/VBox/ToggleButton
@onready var tooltip_label: Label = $Margin/VBox/TooltipLabel

var _icon_overview: Texture2D

var _camera: Node
var _tooltip_tween: Tween

func _ready() -> void:
	layer = 30
	_style_button()
	_icon_overview = load("res://ui/icons/toggle_view.png") as Texture2D
	if toggle_btn:
		if _icon_overview:
			toggle_btn.icon = _icon_overview
			toggle_btn.text = ""
			toggle_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if toggle_btn:
		toggle_btn.focus_mode = Control.FOCUS_NONE  # Space blijft voor shoot, niet voor button
		toggle_btn.pressed.connect(_on_toggle_pressed)
		toggle_btn.mouse_entered.connect(_on_button_hovered)
		toggle_btn.mouse_exited.connect(_on_button_exited)
	if tooltip_label:
		tooltip_label.visible = false

func setup(p_camera: Node) -> void:
	_camera = p_camera
	if _camera and _camera.has_signal("mode_changed"):
		_camera.mode_changed.connect(_on_mode_changed)
	_refresh_button_text()

func _style_button() -> void:
	if not toggle_btn:
		return
	var sb: StyleBoxFlat = StyleBoxFlat.new()
	sb.bg_color = Color(0.063, 0.094, 0.125, 0.75)
	sb.corner_radius_top_left = 12
	sb.corner_radius_top_right = 12
	sb.corner_radius_bottom_left = 12
	sb.corner_radius_bottom_right = 12
	sb.border_width_left = 2
	sb.border_width_top = 2
	sb.border_width_right = 2
	sb.border_width_bottom = 2
	sb.border_color = Color(0.0, 0.898, 1.0, 0.9)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0, 2)
	sb.shadow_color = Color(0, 0, 0, 0.4)
	toggle_btn.add_theme_stylebox_override("normal", sb)
	var sb_hover: StyleBoxFlat = sb.duplicate()
	sb_hover.border_color = Color(1.0, 1.0, 1.0, 0.95)
	toggle_btn.add_theme_stylebox_override("hover", sb_hover)
	var sb_pressed: StyleBoxFlat = sb.duplicate()
	sb_pressed.bg_color = Color(0.04, 0.12, 0.15, 0.9)
	toggle_btn.add_theme_stylebox_override("pressed", sb_pressed)
	toggle_btn.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.95))
	toggle_btn.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))

func _on_toggle_pressed() -> void:
	if _camera and _camera.has_method("toggle_mode"):
		_camera.toggle_mode()
	_show_tooltip()

func _on_mode_changed(_new_mode: int) -> void:
	_refresh_button_text()

func _refresh_button_text() -> void:
	if not tooltip_label or not _camera:
		return
	if _camera.has_method("is_overview_mode") and _camera.is_overview_mode():
		tooltip_label.text = "GAMEPLAY VIEW"
	else:
		tooltip_label.text = "FIELD OVERVIEW"

func _on_button_hovered() -> void:
	_show_tooltip()

func _on_button_exited() -> void:
	if tooltip_label:
		tooltip_label.visible = false
	if _tooltip_tween and _tooltip_tween.is_valid():
		_tooltip_tween.kill()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_overview"):
		if _camera and _camera.has_method("toggle_mode"):
			_camera.toggle_mode()
		_show_tooltip()
		get_viewport().set_input_as_handled()

func _show_tooltip() -> void:
	if not tooltip_label:
		return
	tooltip_label.visible = true
	if _tooltip_tween and _tooltip_tween.is_valid():
		_tooltip_tween.kill()
	_tooltip_tween = create_tween()
	_tooltip_tween.tween_interval(0.4)
	_tooltip_tween.tween_callback(func(): tooltip_label.visible = false)
