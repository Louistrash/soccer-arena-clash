extends Control
## Stadium-style hero gallery: rounded cards, green/gold palette, 4x3 grid layout.

# --- Node refs ---
@onready var hero_grid: GridContainer = $MainVBox/CarouselPanel/CarouselMargin/CenterContainer/HeroGrid
@onready var play_button: Button = $MainVBox/BottomBar/BottomMargin/BottomHBox/PlayButton
@onready var title_label: Label = $MainVBox/TopBar/TopMargin/ContentHBox/TitleVBox/Title
@onready var subtitle_label: Label = $MainVBox/TopBar/TopMargin/ContentHBox/TitleVBox/Subtitle
@onready var top_bar: PanelContainer = $MainVBox/TopBar
@onready var carousel_panel: PanelContainer = $MainVBox/CarouselPanel
@onready var bottom_bar: PanelContainer = $MainVBox/BottomBar
@onready var stats_container: VBoxContainer = $MainVBox/TopBar/TopMargin/ContentHBox/StatsPanel/StatsMargin/StatsVBox/StatsContainer
@onready var role_title: Label = $MainVBox/TopBar/TopMargin/ContentHBox/RolePanel/RoleMargin/RoleVBox/RoleTitle
@onready var role_desc: Label = $MainVBox/TopBar/TopMargin/ContentHBox/RolePanel/RoleMargin/RoleVBox/RoleDesc
@onready var background_layer: Control = $BackgroundLayer
@onready var gallery_music: AudioStreamPlayer = $GalleryMusic

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
var _default_stats: Dictionary = {"speed": 60, "shooting": 60, "passing": 60, "defense": 60, "control": 60}

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
	_populate_pedestals()
	_update_grid_layout()
	_select_hero("arlo")
	_screen_open_animation()
	_play_gallery_music()

func _play_gallery_music() -> void:
	if gallery_music.stream is AudioStreamOggVorbis:
		gallery_music.stream.loop = true
	gallery_music.play()

func _on_viewport_resized() -> void:
	_update_grid_layout()

func _update_grid_layout() -> void:
	var win_size := get_viewport_rect().size
	var is_mobile := win_size.x < 1024
	
	if is_mobile:
		hero_grid.columns = 3
		hero_grid.add_theme_constant_override("h_separation", 12)
		hero_grid.add_theme_constant_override("v_separation", 12)
		# Update card sizes for mobile
		for card in _pedestals:
			card.custom_minimum_size = Vector2(100, 130)
			if card.has_method("_clamp_size"):
				card._clamp_size()
	else:
		hero_grid.columns = 4
		hero_grid.add_theme_constant_override("h_separation", 24)
		hero_grid.add_theme_constant_override("v_separation", 24)
		# Update card sizes for desktop
		for card in _pedestals:
			card.custom_minimum_size = Vector2(140, 180)
			if card.has_method("_clamp_size"):
				card._clamp_size()

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
	var PedestalCardScript: GDScript = load("res://scenes/ui/PedestalCard.gd") as GDScript
	for i in range(HERO_DATA.size()):
		var hero: Dictionary = HERO_DATA[i]
		var tex: Texture2D = load(_get_hero_texture_path(hero["id"])) as Texture2D
		var card: Control = PedestalCardScript.new()
		card.setup(hero, tex)
		card.set_meta("hero_id", hero["id"])
		card.set_meta("hero_data", hero)

		hero_grid.add_child(card)

		card.gui_input.connect(_on_pedestal_gui_input.bind(card))
		card.mouse_entered.connect(_on_pedestal_mouse_entered.bind(card))
		card.mouse_exited.connect(_on_pedestal_mouse_exited.bind(card))
		_pedestals.append(card)

func _on_pedestal_mouse_entered(card: Control) -> void:
	if card.get_meta("hero_id") == _selected_id:
		return
	card.pivot_offset = card.size / 2
	var t := create_tween()
	t.tween_property(card, "scale", Vector2(1.08, 1.08), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_pedestal_mouse_exited(card: Control) -> void:
	if card.get_meta("hero_id") == _selected_id:
		return
	var t := create_tween()
	t.tween_property(card, "scale", Vector2.ONE, 0.12).set_ease(Tween.EASE_OUT)

func _on_pedestal_gui_input(event: InputEvent, card: Control) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			var hero_id: String = card.get_meta("hero_id")
			_select_hero(hero_id)
			card.pivot_offset = card.size / 2
			var t := create_tween()
			t.tween_property(card, "scale", Vector2(0.92, 0.92), 0.05)
			t.tween_property(card, "scale", Vector2(1.06, 1.06), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			t.tween_property(card, "scale", Vector2.ONE, 0.08)

# ====================== SELECTION ======================

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
			var t := create_tween()
			t.tween_property(card, "scale", Vector2(1.35, 1.35), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			card.start_idle_bounce()
			card.start_glow_pulse()
		else:
			card.modulate = Color(0.5, 0.55, 0.6) # Desaturated blue/grey
			card.z_index = 0
			var t := create_tween()
			t.tween_property(card, "scale", Vector2.ONE, 0.2).set_ease(Tween.EASE_OUT)
			card.stop_idle_bounce()
			card.stop_glow_pulse()

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
	if GameManager.selected_hero_path.is_empty():
		return
	GameManager.goto_match()
