extends Control
## Brawl Stars-inspired pedestal hero gallery.
## Glowing circular pedestals, stats panel, role/tactical panel, center glow.

# --- Node refs ---
@onready var hero_row: HBoxContainer = $MainVBox/CarouselPanel/CarouselMargin/HeroScroll/HeroRow
@onready var play_button: Button = $MainVBox/BottomBar/BottomMargin/BottomHBox/PlayButton
@onready var title_label: Label = $MainVBox/TopBar/TopMargin/ContentHBox/TitleVBox/Title
@onready var subtitle_label: Label = $MainVBox/TopBar/TopMargin/ContentHBox/TitleVBox/Subtitle
@onready var top_bar: PanelContainer = $MainVBox/TopBar
@onready var carousel_panel: PanelContainer = $MainVBox/CarouselPanel
@onready var bottom_bar: PanelContainer = $MainVBox/BottomBar
@onready var stats_container: VBoxContainer = $MainVBox/TopBar/TopMargin/ContentHBox/StatsPanel/StatsMargin/StatsVBox/StatsContainer
@onready var role_title: Label = $MainVBox/TopBar/TopMargin/ContentHBox/RolePanel/RoleMargin/RoleVBox/RoleTitle
@onready var role_desc: Label = $MainVBox/TopBar/TopMargin/ContentHBox/RolePanel/RoleMargin/RoleVBox/RoleDesc
@onready var hero_scroll: ScrollContainer = $MainVBox/CarouselPanel/CarouselMargin/HeroScroll
@onready var background_layer: Control = $BackgroundLayer

const STAT_NAMES := ["Speed", "Shooting", "Passing", "Defense", "Control"]

# --- Hero data with roles, glow, stats, tactical ---
const HERO_DATA: Array[Dictionary] = [
	{"id": "arlo",   "name": "Arlo",   "role": "Playmaker",      "desc": "Precision passing playmaker.",             "glow": Color(0.16, 0.66, 1.0),
	 "stats": {"speed": 70, "shooting": 45, "passing": 92, "defense": 38, "control": 85},
	 "tactical": "Precision passing playmaker. Dictates tempo, creates chances through vision and through balls."},
	{"id": "axel",   "name": "Axel",   "role": "Striker",        "desc": "Elite goal scoring striker.",              "glow": Color(1.0, 0.35, 0.2),
	 "stats": {"speed": 75, "shooting": 90, "passing": 50, "defense": 25, "control": 65},
	 "tactical": "Elite goal scorer. Prioritize shooting positions and exploit space in the final third."},
	{"id": "enzo",   "name": "Enzo",   "role": "Forward",        "desc": "Aggressive pressing forward.",            "glow": Color(0.95, 0.75, 0.2),
	 "stats": {"speed": 82, "shooting": 72, "passing": 55, "defense": 45, "control": 60},
	 "tactical": "Aggressive pressing forward. High work rate, closes down defenders, wins the ball high."},
	{"id": "johan",  "name": "Johan",  "role": "General",        "desc": "Tactical field general.",                 "glow": Color(0.3, 0.85, 0.5),
	 "stats": {"speed": 65, "shooting": 55, "passing": 88, "defense": 70, "control": 90},
	 "tactical": "Tactical field general. Maintains structure, controls tempo, creates passing opportunities."},
	{"id": "kai",    "name": "Kai",    "role": "Shooter",        "desc": "Unstoppable power shooter.",               "glow": Color(0.9, 0.2, 0.4),
	 "stats": {"speed": 68, "shooting": 95, "passing": 42, "defense": 22, "control": 58},
	 "tactical": "Unstoppable power shooter. Long range threat, shoot on sight from anywhere."},
	{"id": "kian",   "name": "Kian",   "role": "Midfielder",     "desc": "Dynamic box-to-box midfielder.",          "glow": Color(0.5, 0.9, 0.6),
	 "stats": {"speed": 78, "shooting": 60, "passing": 80, "defense": 62, "control": 75},
	 "tactical": "Dynamic box-to-box midfielder. Covers ground, links defense and attack, versatile."},
	{"id": "leo",    "name": "Leo",    "role": "Defender",       "desc": "Defensive anchor specialist.",            "glow": Color(0.4, 0.6, 1.0),
	 "stats": {"speed": 62, "shooting": 35, "passing": 65, "defense": 92, "control": 70},
	 "tactical": "Defensive anchor specialist. Holds the line, blocks shots, clears danger."},
	{"id": "lionel", "name": "Lionel", "role": "Dribbler",       "desc": "Skillful freestyle dribbler.",             "glow": Color(0.7, 0.3, 0.95),
	 "stats": {"speed": 80, "shooting": 65, "passing": 72, "defense": 30, "control": 95},
	 "tactical": "Skillful freestyle dribbler. Beats defenders one-on-one, creates space with the ball."},
	{"id": "marco",  "name": "Marco",  "role": "Finisher",       "desc": "Clutch finisher hero.",                    "glow": Color(1.0, 0.55, 0.2),
	 "stats": {"speed": 72, "shooting": 88, "passing": 52, "defense": 28, "control": 68},
	 "tactical": "Clutch finisher hero. Composed in front of goal, converts chances under pressure."},
	{"id": "rio",    "name": "Rio",    "role": "Sprint",         "desc": "Rapid counterattack sprinter.",           "glow": Color(0.2, 0.95, 0.5),
	 "stats": {"speed": 95, "shooting": 58, "passing": 60, "defense": 35, "control": 72},
	 "tactical": "Rapid counterattack sprinter. Explosive pace, breaks lines, runs in behind."},
	{"id": "zane",   "name": "Zane",   "role": "Defender",       "desc": "Smart positioning defender.",             "glow": Color(0.55, 0.75, 0.95),
	 "stats": {"speed": 70, "shooting": 40, "passing": 70, "defense": 88, "control": 75},
	 "tactical": "Smart positioning defender. Reads the game, intercepts passes, organizes the back line."},
]

var _selected_id: String = ""
var _pedestals: Array = []  # PedestalCard or Control
var _play_pulse_tween: Tween
var _default_stats: Dictionary = {"speed": 60, "shooting": 60, "passing": 60, "defense": 60, "control": 60}

func _get_hero_texture_path(hero_id: String) -> String:
	return "res://heroes/" + hero_id + ".png"

func _get_hero_stats(hero: Dictionary) -> Dictionary:
	if hero.has("stats"):
		return hero["stats"]
	var role_stats: Dictionary = {}
	match hero.get("role", "").to_lower():
		"striker", "shooter", "finisher":
			role_stats = {"speed": 75, "shooting": 90, "passing": 50, "defense": 25, "control": 65}
		"defender":
			role_stats = {"speed": 65, "shooting": 38, "passing": 65, "defense": 90, "control": 70}
		"general":
			role_stats = {"speed": 65, "shooting": 55, "passing": 88, "defense": 70, "control": 90}
		_:
			role_stats = _default_stats.duplicate()
	return role_stats

func _ready() -> void:
	_style_panels()
	_style_play_button()
	_populate_pedestals()
	_select_hero("arlo")
	_screen_open_animation()

# ====================== PANEL STYLING ======================

func _style_panels() -> void:
	const DEEP_GREEN := Color(0.06, 0.12, 0.08)
	const NEON_BORDER := Color(0.2, 0.9, 0.6, 0.3)
	const STADIUM_GOLD := Color(0.95, 0.78, 0.25)
	for panel: PanelContainer in [top_bar, carousel_panel, bottom_bar]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(DEEP_GREEN.r, DEEP_GREEN.g, DEEP_GREEN.b, 0.9)
		sb.set_corner_radius_all(12)
		sb.set_border_width_all(2)
		sb.border_color = NEON_BORDER
		panel.add_theme_stylebox_override("panel", sb)

	# Stats and Role panels (nested)
	var stats_panel: PanelContainer = $MainVBox/TopBar/TopMargin/ContentHBox/StatsPanel
	var role_panel: PanelContainer = $MainVBox/TopBar/TopMargin/ContentHBox/RolePanel
	for p in [stats_panel, role_panel]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(DEEP_GREEN.r, DEEP_GREEN.g, DEEP_GREEN.b, 0.85)
		sb.set_corner_radius_all(8)
		sb.set_border_width_all(1)
		sb.border_color = Color(NEON_BORDER.r, NEON_BORDER.g, NEON_BORDER.b, 0.2)
		p.add_theme_stylebox_override("panel", sb)

	title_label.add_theme_color_override("font_color", STADIUM_GOLD)
	subtitle_label.add_theme_color_override("font_color", Color(0.75, 0.85, 0.7))
	subtitle_label.text = "Choose your hero for the arena"

	role_title.add_theme_color_override("font_color", Color(0.2, 0.95, 0.7))
	role_desc.add_theme_color_override("font_color", Color(0.6, 0.75, 0.6))

func _style_play_button() -> void:
	play_button.disabled = true
	var sb_normal := StyleBoxFlat.new()
	sb_normal.bg_color = Color(0.15, 0.65, 0.35)
	sb_normal.set_corner_radius_all(20)
	sb_normal.set_border_width_all(2)
	sb_normal.border_color = Color(0.95, 0.78, 0.25, 0.5)
	sb_normal.shadow_size = 8
	sb_normal.shadow_color = Color(0.2, 0.95, 0.5, 0.4)
	sb_normal.shadow_offset = Vector2(0, 4)
	play_button.add_theme_stylebox_override("normal", sb_normal)

	var sb_hover := sb_normal.duplicate() as StyleBoxFlat
	sb_hover.bg_color = Color(0.25, 0.9, 0.5)
	play_button.add_theme_stylebox_override("hover", sb_hover)

	var sb_pressed := sb_normal.duplicate() as StyleBoxFlat
	sb_pressed.bg_color = Color(0.1, 0.5, 0.28)
	play_button.add_theme_stylebox_override("pressed", sb_pressed)

	var sb_disabled := StyleBoxFlat.new()
	sb_disabled.bg_color = Color(0.3, 0.3, 0.3, 0.6)
	sb_disabled.set_corner_radius_all(16)
	play_button.add_theme_stylebox_override("disabled", sb_disabled)

	play_button.add_theme_color_override("font_color", Color.WHITE)
	play_button.add_theme_color_override("font_hover_color", Color.WHITE)
	play_button.add_theme_color_override("font_pressed_color", Color(0.9, 0.9, 0.9))
	play_button.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.5))

# ====================== PEDESTALS ======================

func _populate_pedestals() -> void:
	var PedestalCardScript: GDScript = load("res://scenes/ui/PedestalCard.gd") as GDScript
	for hero in HERO_DATA:
		var tex: Texture2D = load(_get_hero_texture_path(hero["id"])) as Texture2D
		var card: Control = PedestalCardScript.new()
		card.setup(hero, tex)
		card.set_meta("hero_id", hero["id"])
		card.set_meta("hero_data", hero)

		var wrapper := MarginContainer.new()
		wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrapper.add_child(card)
		hero_row.add_child(wrapper)
		card.set_meta("wrapper", wrapper)

		card.gui_input.connect(_on_pedestal_gui_input.bind(card))
		card.mouse_entered.connect(_on_pedestal_mouse_entered.bind(card))
		card.mouse_exited.connect(_on_pedestal_mouse_exited.bind(card))

		_pedestals.append(card)

func _on_pedestal_mouse_entered(card: Control) -> void:
	if card.get_meta("hero_id") == _selected_id:
		return
	card.pivot_offset = card.size / 2
	var t := create_tween()
	t.tween_property(card, "scale", Vector2(1.1, 1.1), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

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
			t.tween_property(card, "scale", Vector2(0.94, 0.94), 0.05)
			t.tween_property(card, "scale", Vector2(1.04, 1.04), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
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
	_scroll_to_selected()
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
		row.add_theme_constant_override("separation", 8)
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var lbl := Label.new()
		lbl.text = stat_name + "  "
		lbl.custom_minimum_size.x = 75
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.8))
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(lbl)

		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(80, 10)
		bar.max_value = 100.0
		bar.value = float(val)
		bar.show_percentage = false
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar.add_theme_stylebox_override("background", _make_bar_stylebox(Color(0.1, 0.15, 0.12)))
		bar.add_theme_stylebox_override("fill", _make_fill_stylebox(Color(0.95, 0.78, 0.25, 0.8)))
		row.add_child(bar)

		var val_lbl := Label.new()
		val_lbl.text = str(val)
		val_lbl.add_theme_font_size_override("font_size", 12)
		val_lbl.add_theme_color_override("font_color", Color(0.95, 0.78, 0.25))
		val_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(val_lbl)

		stats_container.add_child(row)

func _make_bar_stylebox(col: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(4)
	return sb

func _make_fill_stylebox(col: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(4)
	return sb

func _update_role_panel(hero: Dictionary) -> void:
	role_title.text = hero.get("role", "") + ":"
	role_title.add_theme_color_override("font_color", hero.get("glow", Color.WHITE))
	role_desc.text = hero.get("tactical", hero.get("desc", ""))

func _update_pedestal_visuals() -> void:
	for card in _pedestals:
		var cid: String = card.get_meta("hero_id")
		var wrapper: MarginContainer = card.get_meta("wrapper", null)
		card.set_selected(cid == _selected_id)

		if cid == _selected_id:
			card.modulate = Color.WHITE
			card.scale = Vector2.ONE
			card.start_idle_bounce()
			card.start_glow_pulse()
			if wrapper:
				wrapper.add_theme_constant_override("margin_top", -10)
				wrapper.add_theme_constant_override("margin_bottom", 10)
		else:
			card.modulate = Color(0.7, 0.7, 0.7)
			card.stop_idle_bounce()
			card.stop_glow_pulse()
			if wrapper:
				wrapper.add_theme_constant_override("margin_top", 0)
				wrapper.add_theme_constant_override("margin_bottom", 0)

func _scroll_to_selected() -> void:
	await get_tree().process_frame
	var idx := 0
	for i in range(HERO_DATA.size()):
		if HERO_DATA[i]["id"] == _selected_id:
			idx = i
			break
	var card: Control = _pedestals[idx] if idx < _pedestals.size() else null
	if card and hero_scroll:
		var wrapper: Control = card.get_parent()
		var center_x: float = wrapper.position.x + card.position.x + card.size.x * 0.5
		hero_scroll.scroll_horizontal = int(center_x - hero_scroll.size.x * 0.5)
		hero_scroll.scroll_horizontal = clampi(hero_scroll.scroll_horizontal, 0, max(0, hero_scroll.get_h_scroll_bar().max_value))

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
	scale = Vector2(0.92, 0.92)
	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.3)
	t.parallel().tween_property(self, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# ====================== PLAY ======================

func _on_play_pressed() -> void:
	if GameManager.selected_hero_path.is_empty():
		return
	GameManager.goto_match()
