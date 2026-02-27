extends Control
## Premium horizontal hero carousel: one row, 44% bigger cards, snap scroll, Brawl Stars × FIFA style.

# --- Node refs ---
@onready var hero_row: HBoxContainer = $MainVBox/CarouselPanel/CarouselMargin/ScrollContainer/HeroRow
@onready var scroll_container: ScrollContainer = $MainVBox/CarouselPanel/CarouselMargin/ScrollContainer
@onready var play_button: Button = $MainVBox/BottomBar/BottomMargin/BottomHBox/PlayButton
@onready var title_label: Label = $MainVBox/TopBar/TopMargin/ContentHBox/TitleVBox/Title
@onready var subtitle_label: Label = $MainVBox/TopBar/TopMargin/ContentHBox/TitleVBox/Subtitle
@onready var top_bar: PanelContainer = $MainVBox/TopBar
@onready var carousel_panel: PanelContainer = $MainVBox/CarouselPanel
@onready var carousel_margin: MarginContainer = $MainVBox/CarouselPanel/CarouselMargin
@onready var bottom_bar: PanelContainer = $MainVBox/BottomBar
@onready var stats_container: VBoxContainer = $MainVBox/TopBar/TopMargin/ContentHBox/StatsPanel/StatsMargin/StatsVBox/StatsContainer
@onready var role_title: Label = $MainVBox/TopBar/TopMargin/ContentHBox/RolePanel/RoleMargin/RoleVBox/RoleTitle
@onready var role_desc: Label = $MainVBox/TopBar/TopMargin/ContentHBox/RolePanel/RoleMargin/RoleVBox/RoleDesc
@onready var background_layer: Control = $BackgroundLayer
@onready var gallery_music: AudioStreamPlayer = $GalleryMusic
@onready var speaker_toggle: Button = $MainVBox/TopBar/TopMargin/ContentHBox/SpeakerToggle

var _icon_sound_on: Texture2D
var _icon_sound_off: Texture2D

const STAT_NAMES := ["Speed", "Shooting", "Passing", "Defense", "Control"]

const NAVY := Color(0.04, 0.06, 0.1)
const NAVY_PANEL := Color(0.05, 0.08, 0.14, 0.85)
const STADIUM_GREEN := Color(0.2, 0.95, 0.5)
const STADIUM_GREEN_BORDER := Color(0.2, 0.95, 0.5, 0.3)
const STADIUM_GOLD := Color(0.94, 0.75, 0.25)
const GOLD_BAR := Color(0.84, 0.66, 0.16)

const HERO_DATA: Array[Dictionary] = [
	{"id": "arlo",   "name": "Arlo",   "role": "Playmaker",  "desc": "Precision passing playmaker.",   "glow": Color(0.16, 0.66, 1.0),
	 "stats": {"speed": 70, "shooting": 45, "passing": 92, "defense": 38, "control": 85},
	 "trophies": 120,
	 "tactical": "Precision passing playmaker. Dictates tempo, creates chances through vision and through balls."},
	{"id": "axel",   "name": "Axel",   "role": "Striker",    "desc": "Elite goal scoring striker.",    "glow": Color(1.0, 0.35, 0.2),
	 "stats": {"speed": 75, "shooting": 90, "passing": 50, "defense": 25, "control": 65},
	 "trophies": 350,
	 "tactical": "Elite goal scorer. Prioritize shooting positions and exploit space in the final third."},
	{"id": "enzo",   "name": "Enzo",   "role": "Forward",    "desc": "Aggressive pressing forward.",   "glow": Color(0.95, 0.75, 0.2),
	 "stats": {"speed": 82, "shooting": 72, "passing": 55, "defense": 45, "control": 60},
	 "trophies": 0,
	 "tactical": "Aggressive pressing forward. High work rate, closes down defenders, wins the ball high."},
	{"id": "johan",  "name": "Johan",  "role": "General",    "desc": "Tactical field general.",        "glow": Color(0.3, 0.85, 0.5),
	 "stats": {"speed": 65, "shooting": 55, "passing": 88, "defense": 70, "control": 90},
	 "trophies": 500,
	 "tactical": "Tactical field general. Maintains structure, controls tempo, creates passing opportunities."},
	{"id": "kai",    "name": "Kai",    "role": "Shooter",    "desc": "Unstoppable power shooter.",     "glow": Color(0.9, 0.2, 0.4),
	 "stats": {"speed": 68, "shooting": 95, "passing": 42, "defense": 22, "control": 58},
	 "trophies": 80,
	 "tactical": "Unstoppable power shooter. Long range threat, shoot on sight from anywhere."},
	{"id": "kian",   "name": "Kian",   "role": "Midfielder", "desc": "Dynamic box-to-box midfielder.", "glow": Color(0.5, 0.9, 0.6),
	 "stats": {"speed": 78, "shooting": 60, "passing": 80, "defense": 62, "control": 75},
	 "trophies": 210,
	 "tactical": "Dynamic box-to-box midfielder. Covers ground, links defense and attack, versatile."},
	{"id": "leo",    "name": "Leo",    "role": "Defender",   "desc": "Defensive anchor specialist.",   "glow": Color(0.4, 0.6, 1.0),
	 "stats": {"speed": 62, "shooting": 35, "passing": 65, "defense": 92, "control": 70},
	 "trophies": 450,
	 "tactical": "Defensive anchor specialist. Holds the line, blocks shots, clears danger."},
	{"id": "lionel", "name": "Lionel", "role": "Dribbler",   "desc": "Skillful freestyle dribbler.",   "glow": Color(0.7, 0.3, 0.95),
	 "stats": {"speed": 80, "shooting": 65, "passing": 72, "defense": 30, "control": 95},
	 "trophies": 600,
	 "tactical": "Skillful freestyle dribbler. Beats defenders one-on-one, creates space with the ball."},
	{"id": "marco",  "name": "Marco",  "role": "Finisher",   "desc": "Clutch finisher hero.",          "glow": Color(1.0, 0.55, 0.2),
	 "stats": {"speed": 72, "shooting": 88, "passing": 52, "defense": 28, "control": 68},
	 "trophies": 150,
	 "tactical": "Clutch finisher hero. Composed in front of goal, converts chances under pressure."},
	{"id": "rio",    "name": "Rio",    "role": "Sprint",     "desc": "Rapid counterattack sprinter.",  "glow": Color(0.2, 0.95, 0.5),
	 "stats": {"speed": 95, "shooting": 58, "passing": 60, "defense": 35, "control": 72},
	 "trophies": 40,
	 "tactical": "Rapid counterattack sprinter. Explosive pace, breaks lines, runs in behind."},
	{"id": "zane",   "name": "Zane",   "role": "Defender",   "desc": "Smart positioning defender.",    "glow": Color(0.55, 0.75, 0.95),
	 "stats": {"speed": 70, "shooting": 40, "passing": 70, "defense": 88, "control": 75},
	 "trophies": 280,
	 "tactical": "Smart positioning defender. Reads the game, intercepts passes, organizes the back line."},
]

var _selected_id: String = ""
var _pedestals: Array = []
var _play_pulse_tween: Tween
var _scroll_snap_tween: Tween
var _default_stats: Dictionary = {"speed": 60, "shooting": 60, "passing": 60, "defense": 60, "control": 60}
var _card_w: int = 236
var _card_h: int = 370
var _card_gap: int = 28
var _arrow_left: Button
var _arrow_right: Button
var _scroll_idle_frames: int = 0
var _last_scroll_h: int = -1
var _left_spacer: Control
var _right_spacer: Control

func _get_hero_texture_path(hero_id: String) -> String:
	return "res://heroes/" + hero_id + ".png"

func _get_hero_stats(hero: Dictionary) -> Dictionary:
	if hero.has("stats"):
		return hero["stats"]
	return _default_stats.duplicate()

func _ready() -> void:
	get_tree().root.size_changed.connect(_on_viewport_resized)
	_style_panels()
	_style_play_button()
	_icon_sound_on = load("res://ui/icons/on.png") as Texture2D
	_icon_sound_off = load("res://ui/icons/sound_off.png") as Texture2D
	# Defer heavy work so loader can hide and first frame can paint (fixes stuck loader on web)
	call_deferred("_deferred_gallery_init")

func _deferred_gallery_init() -> void:
	_update_speaker_toggle_ui()
	_play_gallery_music()
	_populate_pedestals()
	_update_carousel_layout()
	# Open de gallery met Johan gecentreerd in de rij
	_select_hero("johan")
	_screen_open_animation()
	_build_arrow_buttons()
	if scroll_container.get_h_scroll_bar():
		scroll_container.get_h_scroll_bar().scrolling.connect(_on_scroll_started)
	call_deferred("_update_carousel_layout")
	var t := get_tree().create_timer(0.3)
	t.timeout.connect(_update_carousel_layout)

func _play_gallery_music() -> void:
	if not gallery_music or not gallery_music.stream:
		return
	if not GameManager.sound_enabled:
		return
	if gallery_music.stream is AudioStreamOggVorbis:
		gallery_music.stream.loop = true
	gallery_music.play()

func _ensure_gallery_music_playing() -> void:
	if GameManager.sound_enabled and gallery_music and gallery_music.stream and not gallery_music.playing:
		if gallery_music.stream is AudioStreamOggVorbis:
			gallery_music.stream.loop = true
		gallery_music.play()

func _update_speaker_toggle_ui() -> void:
	if not speaker_toggle:
		return
	if not _icon_sound_on:
		_icon_sound_on = load("res://ui/icons/on.png") as Texture2D
	if not _icon_sound_off:
		_icon_sound_off = load("res://ui/icons/sound_off.png") as Texture2D
	speaker_toggle.focus_mode = Control.FOCUS_NONE
	if _icon_sound_on and _icon_sound_off:
		speaker_toggle.icon = _icon_sound_on if GameManager.sound_enabled else _icon_sound_off
		speaker_toggle.text = ""
		speaker_toggle.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		speaker_toggle.expand_icon = true
	else:
		speaker_toggle.text = "🔊" if GameManager.sound_enabled else "🔇"
	speaker_toggle.tooltip_text = "Sound on/off"
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.05, 0.08, 0.14, 0.9)
	sb.set_corner_radius_all(8)
	sb.set_border_width_all(1)
	sb.border_color = Color(STADIUM_GREEN.r, STADIUM_GREEN.g, STADIUM_GREEN.b, 0.4)
	speaker_toggle.add_theme_stylebox_override("normal", sb)
	speaker_toggle.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	speaker_toggle.add_theme_font_size_override("font_size", 24)

func _on_speaker_toggle_pressed() -> void:
	GameManager.toggle_sound()
	if gallery_music:
		if GameManager.sound_enabled:
			if gallery_music.stream:
				gallery_music.play()
		else:
			gallery_music.stop()
	_update_speaker_toggle_ui()

func _on_viewport_resized() -> void:
	_update_carousel_layout()

func _build_arrow_buttons() -> void:
	_arrow_left = Button.new()
	_arrow_left.text = "‹"
	_arrow_left.add_theme_font_size_override("font_size", 36)
	_arrow_left.custom_minimum_size = Vector2(56, 80)
	_arrow_left.flat = true
	_arrow_left.focus_mode = Control.FOCUS_NONE
	_arrow_left.add_theme_color_override("font_color", STADIUM_GOLD)
	_arrow_left.add_theme_color_override("font_hover_color", Color.WHITE)
	_arrow_left.pressed.connect(_on_arrow_left_pressed)
	carousel_margin.add_child(_arrow_left)
	_arrow_left.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	_arrow_left.anchor_top = 0.5
	_arrow_left.anchor_bottom = 0.5
	_arrow_left.offset_left = 4
	_arrow_left.offset_top = -36
	_arrow_left.offset_right = 52
	_arrow_left.offset_bottom = 36

	_arrow_right = Button.new()
	_arrow_right.text = "›"
	_arrow_right.add_theme_font_size_override("font_size", 36)
	_arrow_right.custom_minimum_size = Vector2(56, 80)
	_arrow_right.flat = true
	_arrow_right.focus_mode = Control.FOCUS_NONE
	_arrow_right.pressed.connect(_on_arrow_right_pressed)
	_arrow_right.add_theme_color_override("font_color", STADIUM_GOLD)
	_arrow_right.add_theme_color_override("font_hover_color", Color.WHITE)
	carousel_margin.add_child(_arrow_right)
	_arrow_right.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	_arrow_right.anchor_top = 0.5
	_arrow_right.anchor_bottom = 0.5
	_arrow_right.offset_left = -52
	_arrow_right.offset_top = -36
	_arrow_right.offset_right = -4
	_arrow_right.offset_bottom = 36

func _on_arrow_left_pressed() -> void:
	var idx := _get_selected_index()
	if idx > 0:
		_select_hero(HERO_DATA[idx - 1]["id"])
		_scroll_to_center_selected(true)

func _on_arrow_right_pressed() -> void:
	var idx := _get_selected_index()
	if idx >= 0 and idx < HERO_DATA.size() - 1:
		_select_hero(HERO_DATA[idx + 1]["id"])
		_scroll_to_center_selected(true)

func _get_selected_index() -> int:
	for i in range(HERO_DATA.size()):
		if HERO_DATA[i]["id"] == _selected_id:
			return i
	return 0

func _on_scroll_started() -> void:
	_last_scroll_h = scroll_container.scroll_horizontal

func _process(_delta: float) -> void:
	if _pedestals.is_empty() or not is_instance_valid(scroll_container):
		return
	# Snap to nearest card when user stops scrolling (swipe/drag end)
	if _scroll_snap_tween and _scroll_snap_tween.is_valid() and _scroll_snap_tween.is_running():
		_last_scroll_h = scroll_container.scroll_horizontal
		_scroll_idle_frames = 0
		return
	if scroll_container.scroll_horizontal != _last_scroll_h:
		_last_scroll_h = scroll_container.scroll_horizontal
		_scroll_idle_frames = 0
		return
	_scroll_idle_frames += 1
	if _scroll_idle_frames == 12:  # ~0.2s at 60 FPS
		_snap_to_nearest_card()
		_scroll_idle_frames = 0

func _snap_to_nearest_card() -> void:
	var view_w: float = scroll_container.size.x
	var half_pad: float = maxf(0, view_w * 0.5 - _card_w * 0.5)
	var scroll := scroll_container.scroll_horizontal
	var center_x: float = scroll + view_w * 0.5
	var best_idx := 0
	var best_dist: float = 1e9
	for i in range(_pedestals.size()):
		var card_center_x: float = half_pad + i * (_card_w + _card_gap) + _card_w * 0.5
		var d: float = abs(card_center_x - center_x)
		if d < best_dist:
			best_dist = d
			best_idx = i
	if best_idx >= 0 and best_idx < HERO_DATA.size() and HERO_DATA[best_idx]["id"] != _selected_id:
		_select_hero(HERO_DATA[best_idx]["id"])
	_scroll_to_center_selected(true)

func _scroll_to_center_selected(animated: bool) -> void:
	var idx := _get_selected_index()
	if idx < 0 or idx >= _pedestals.size():
		return
	var content_w: float = hero_row.custom_minimum_size.x
	var view_w: float = scroll_container.size.x
	var half_pad: float = maxf(0, view_w * 0.5 - _card_w * 0.5)
	var card_center_x: float = half_pad + idx * (_card_w + _card_gap) + _card_w * 0.5
	var scroll_target: float = card_center_x - view_w * 0.5
	scroll_target = clampf(scroll_target, 0.0, maxf(0, content_w - view_w))
	if _scroll_snap_tween and _scroll_snap_tween.is_valid():
		_scroll_snap_tween.kill()
	if animated:
		_scroll_snap_tween = create_tween()
		_scroll_snap_tween.tween_property(scroll_container, "scroll_horizontal", int(scroll_target), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	else:
		scroll_container.scroll_horizontal = int(scroll_target)

func _update_carousel_layout() -> void:
	var win_size := get_viewport_rect().size
	_card_w = 236
	_card_h = 370
	_card_gap = 28
	var top_h: int = 76 if win_size.y < 800 else 100
	var bottom_h: int = 56 if win_size.y < 800 else 72
	top_bar.custom_minimum_size.y = top_h
	bottom_bar.custom_minimum_size.y = bottom_h
	carousel_panel.custom_minimum_size.y = maxi(340, int(win_size.y * 0.50))
	hero_row.add_theme_constant_override("separation", _card_gap)

	var view_w: float = scroll_container.size.x
	if view_w < 1:
		view_w = win_size.x - 128
	var half_pad: float = maxf(0, view_w * 0.5 - _card_w * 0.5)
	if _left_spacer:
		_left_spacer.custom_minimum_size.x = half_pad
	if _right_spacer:
		_right_spacer.custom_minimum_size.x = half_pad

	var n := HERO_DATA.size()
	var glow_pad := 28
	var row_w: int = int(half_pad * 2) + n * _card_w + (n - 1) * _card_gap
	hero_row.custom_minimum_size = Vector2(row_w, _card_h + glow_pad * 2)
	for card in _pedestals:
		card.custom_minimum_size = Vector2(_card_w, _card_h)
		if card.has_method("_clamp_size"):
			card._clamp_size()
	call_deferred("_scroll_to_center_selected", false)

# ====================== PANEL STYLING ======================

func _style_panels() -> void:
	for panel: PanelContainer in [top_bar, carousel_panel, bottom_bar]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(NAVY_PANEL.r, NAVY_PANEL.g, NAVY_PANEL.b, 0.7 if panel == carousel_panel else 0.85)
		sb.set_corner_radius_all(0)
		sb.set_border_width_all(0)
		panel.add_theme_stylebox_override("panel", sb)

	# Subtle bottom border on top bar
	var top_sb: StyleBoxFlat = top_bar.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	top_sb.border_width_bottom = 1
	top_sb.border_color = STADIUM_GREEN_BORDER
	top_bar.add_theme_stylebox_override("panel", top_sb)

	# Subtle top border on bottom bar
	var bot_sb: StyleBoxFlat = bottom_bar.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	bot_sb.border_width_top = 1
	bot_sb.border_color = STADIUM_GREEN_BORDER
	bottom_bar.add_theme_stylebox_override("panel", bot_sb)

	# Stats and Role panels
	var stats_panel: PanelContainer = $MainVBox/TopBar/TopMargin/ContentHBox/StatsPanel
	var role_panel: PanelContainer = $MainVBox/TopBar/TopMargin/ContentHBox/RolePanel
	for p in [stats_panel, role_panel]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.04, 0.07, 0.12, 0.9)
		sb.set_corner_radius_all(8)
		sb.set_border_width_all(1)
		sb.border_color = Color(STADIUM_GREEN.r, STADIUM_GREEN.g, STADIUM_GREEN.b, 0.2)
		p.add_theme_stylebox_override("panel", sb)

	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.add_theme_font_size_override("font_size", 30)
	subtitle_label.add_theme_color_override("font_color", Color(0.6, 0.75, 0.8))
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.text = "Choose your hero for the arena"

	role_title.add_theme_color_override("font_color", STADIUM_GOLD)
	role_title.add_theme_font_size_override("font_size", 14)
	role_desc.add_theme_color_override("font_color", Color(0.6, 0.72, 0.78))
	role_desc.add_theme_font_size_override("font_size", 12)

func _style_play_button() -> void:
	play_button.disabled = true
	var sb_normal := StyleBoxFlat.new()
	sb_normal.bg_color = Color(0.78, 0.6, 0.12)
	sb_normal.set_corner_radius_all(8)
	sb_normal.set_border_width_all(2)
	sb_normal.border_color = Color(0.95, 0.78, 0.25, 0.7)
	sb_normal.shadow_size = 8
	sb_normal.shadow_color = Color(0.94, 0.75, 0.15, 0.3)
	sb_normal.shadow_offset = Vector2(0, 4)
	play_button.add_theme_stylebox_override("normal", sb_normal)

	var sb_hover := sb_normal.duplicate() as StyleBoxFlat
	sb_hover.bg_color = Color(0.92, 0.72, 0.18)
	sb_hover.border_color = Color(1.0, 0.85, 0.4, 0.9)
	play_button.add_theme_stylebox_override("hover", sb_hover)

	var sb_pressed := sb_normal.duplicate() as StyleBoxFlat
	sb_pressed.bg_color = Color(0.6, 0.45, 0.08)
	play_button.add_theme_stylebox_override("pressed", sb_pressed)

	var sb_disabled := StyleBoxFlat.new()
	sb_disabled.bg_color = Color(0.2, 0.2, 0.25, 0.6)
	sb_disabled.set_corner_radius_all(8)
	play_button.add_theme_stylebox_override("disabled", sb_disabled)

	play_button.add_theme_color_override("font_color", Color(0.1, 0.08, 0.02))
	play_button.add_theme_color_override("font_hover_color", Color(0.1, 0.06, 0.0))
	play_button.add_theme_color_override("font_pressed_color", Color(0.3, 0.25, 0.1))
	play_button.add_theme_color_override("font_disabled_color", Color(0.4, 0.4, 0.45))

# ====================== PEDESTALS ======================

func _populate_pedestals() -> void:
	_left_spacer = Control.new()
	_left_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero_row.add_child(_left_spacer)

	var PedestalCardScript: GDScript = load("res://scenes/ui/PedestalCard.gd") as GDScript
	for i in range(HERO_DATA.size()):
		var hero: Dictionary = HERO_DATA[i]
		var tex: Texture2D = load(_get_hero_texture_path(hero["id"])) as Texture2D
		var card: Control = PedestalCardScript.new()
		card.setup(hero, tex)
		card.set_meta("hero_id", hero["id"])
		card.set_meta("hero_data", hero)
		card.custom_minimum_size = Vector2(_card_w, _card_h)
		card.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hero_row.add_child(card)

		card.gui_input.connect(_on_pedestal_gui_input.bind(card))
		card.mouse_entered.connect(_on_pedestal_mouse_entered.bind(card))
		card.mouse_exited.connect(_on_pedestal_mouse_exited.bind(card))
		_pedestals.append(card)

	_right_spacer = Control.new()
	_right_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero_row.add_child(_right_spacer)

func _on_pedestal_mouse_entered(card: Control) -> void:
	if card.get_meta("hero_id") == _selected_id:
		return
	card.pivot_offset = card.size / 2
	var t := create_tween()
	t.tween_property(card, "scale", Vector2(1.04, 1.04), 0.14).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_pedestal_mouse_exited(card: Control) -> void:
	if card.get_meta("hero_id") == _selected_id:
		return
	var t := create_tween()
	t.tween_property(card, "scale", Vector2.ONE, 0.12).set_ease(Tween.EASE_OUT)

func _on_pedestal_gui_input(event: InputEvent, card: Control) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_ensure_gallery_music_playing()
			var hero_id: String = card.get_meta("hero_id")
			if hero_id == _selected_id:
				_deselect_hero()
				return
			_select_hero(hero_id)
			_scroll_to_center_selected(true)
			card.pivot_offset = card.size / 2
			var t := create_tween()
			t.tween_property(card, "scale", Vector2(1.06, 1.06), 0.08).set_ease(Tween.EASE_OUT)

# ====================== SELECTION ======================

func _deselect_hero() -> void:
	_selected_id = ""
	GameManager.selected_hero_path = ""
	GameManager.selected_hero_name = ""
	GameManager.selected_hero_id = ""
	for card in _pedestals:
		card.set_selected(false)
		card.modulate = Color.WHITE
		card.z_index = 0
		var t := create_tween()
		t.tween_property(card, "scale", Vector2.ONE, 0.15).set_ease(Tween.EASE_OUT)
		card.stop_idle_bounce()
		card.stop_glow_pulse()
	play_button.disabled = true
	if _play_pulse_tween and _play_pulse_tween.is_valid():
		_play_pulse_tween.kill()
	play_button.scale = Vector2.ONE

func _select_hero(hero_id: String) -> void:
	_selected_id = hero_id
	var hero_data: Dictionary = {}
	for h in HERO_DATA:
		if h["id"] == hero_id:
			hero_data = h
			break
	if hero_data.is_empty():
		return

	GameManager.selected_hero_path = _get_hero_texture_path(hero_id)
	GameManager.selected_hero_name = hero_data["name"]
	GameManager.selected_hero_id = hero_id

	_update_stats_panel(hero_data)
	_update_role_panel(hero_data)
	_update_pedestal_visuals()
	_update_center_glow()

	play_button.disabled = false
	_start_play_pulse()

func _update_stats_panel(hero: Dictionary) -> void:
	for c in stats_container.get_children():
		c.queue_free()
	var stats: Dictionary = _get_hero_stats(hero)
	for stat_name in STAT_NAMES:
		var key: String = stat_name.to_lower()
		var val: int = stats.get(key, 60)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var lbl := Label.new()
		lbl.text = stat_name
		lbl.custom_minimum_size.x = 70
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(0.65, 0.75, 0.82))
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(lbl)

		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(85, 10)
		bar.max_value = 100.0
		bar.value = float(val)
		bar.show_percentage = false
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.add_theme_stylebox_override("background", _make_bar_bg(Color(0.08, 0.12, 0.18)))
		bar.add_theme_stylebox_override("fill", _make_bar_fill(GOLD_BAR))
		row.add_child(bar)

		var val_lbl := Label.new()
		val_lbl.text = str(val)
		val_lbl.add_theme_font_size_override("font_size", 12)
		val_lbl.add_theme_color_override("font_color", STADIUM_GOLD)
		val_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(val_lbl)

		stats_container.add_child(row)

func _make_bar_bg(col: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(3)
	return sb

func _make_bar_fill(col: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(3)
	return sb

func _update_role_panel(hero: Dictionary) -> void:
	role_title.text = hero.get("role", "").to_upper() + ":"
	role_title.add_theme_color_override("font_color", STADIUM_GOLD)
	role_desc.text = hero.get("tactical", hero.get("desc", ""))

func _update_pedestal_visuals() -> void:
	for card in _pedestals:
		var cid: String = card.get_meta("hero_id")
		card.set_selected(cid == _selected_id)

		if cid == _selected_id:
			card.modulate = Color.WHITE
			card.z_index = 10
			card.pivot_offset = card.size / 2
			card.scale = Vector2(1.06, 1.06)
			card.start_idle_bounce()
			card.start_glow_pulse()
			if card.has_method("update_trophy_visuals"):
				card.update_trophy_visuals(true)
		else:
			card.modulate = Color(0.5, 0.55, 0.6)
			card.z_index = 0
			var t := create_tween()
			t.tween_property(card, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT)
			card.stop_idle_bounce()
			card.stop_glow_pulse()
			if card.has_method("update_trophy_visuals"):
				card.update_trophy_visuals(false)

func _update_center_glow() -> void:
	if not background_layer:
		return
	await get_tree().process_frame
	var idx := 0
	for i in range(HERO_DATA.size()):
		if HERO_DATA[i]["id"] == _selected_id:
			idx = i
			break
	if idx < _pedestals.size():
		var card: Control = _pedestals[idx]
		background_layer.center_glow_pos = card.global_position + card.size * 0.5
		background_layer.queue_redraw()

# ====================== PLAY BUTTON PULSE ======================

func _start_play_pulse() -> void:
	if _play_pulse_tween and _play_pulse_tween.is_valid():
		_play_pulse_tween.kill()
	play_button.pivot_offset = play_button.size / 2
	_play_pulse_tween = create_tween().set_loops()
	_play_pulse_tween.tween_property(play_button, "scale", Vector2(1.03, 1.03), 0.75).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_play_pulse_tween.tween_property(play_button, "scale", Vector2.ONE, 0.75).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

# ====================== SCREEN OPEN ANIMATION ======================

func _screen_open_animation() -> void:
	modulate.a = 0.0
	pivot_offset = size / 2
	scale = Vector2(0.94, 0.94)
	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.35)
	t.parallel().tween_property(self, "scale", Vector2.ONE, 0.35).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# ====================== PLAY ======================

func _on_play_pressed() -> void:
	_ensure_gallery_music_playing()
	if GameManager.selected_hero_path.is_empty():
		return
	GameManager.goto_match()
