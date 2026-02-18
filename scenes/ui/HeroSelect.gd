extends Control
## Brawlstars-inspired Soccer Hero Gallery.
## Cards with glow, spotlight, stadium background, punchy animations.

# --- Node refs ---
@onready var hero_row: HBoxContainer = $MainVBox/CarouselPanel/CarouselMargin/HeroScroll/HeroRow
@onready var spotlight_ring: Control = $MainVBox/SpotlightPanel/SpotlightMargin/SpotlightHBox/SpotlightSpriteContainer/SpotlightRing
@onready var play_button: Button = $MainVBox/BottomBar/BottomMargin/BottomHBox/PlayButton
@onready var spotlight_sprite: TextureRect = $MainVBox/SpotlightPanel/SpotlightMargin/SpotlightHBox/SpotlightSpriteContainer/SpotlightSprite
@onready var spotlight_name: Label = $MainVBox/SpotlightPanel/SpotlightMargin/SpotlightHBox/SpotlightInfo/SpotlightName
@onready var spotlight_role: Label = $MainVBox/SpotlightPanel/SpotlightMargin/SpotlightHBox/SpotlightInfo/SpotlightRole
@onready var spotlight_desc: Label = $MainVBox/SpotlightPanel/SpotlightMargin/SpotlightHBox/SpotlightInfo/SpotlightDesc
@onready var title_label: Label = $MainVBox/TopBar/TopMargin/TitleVBox/Title
@onready var subtitle_label: Label = $MainVBox/TopBar/TopMargin/TitleVBox/Subtitle
@onready var top_bar: PanelContainer = $MainVBox/TopBar
@onready var spotlight_panel: PanelContainer = $MainVBox/SpotlightPanel
@onready var carousel_panel: PanelContainer = $MainVBox/CarouselPanel
@onready var bottom_bar: PanelContainer = $MainVBox/BottomBar

# --- Hero data with roles and glow colors ---
const HERO_DATA: Array[Dictionary] = [
	{"id": "arlo",   "name": "Arlo",   "role": "Playmaker",      "desc": "Precision passing playmaker.",             "glow": Color(0.16, 0.66, 1.0)},
	{"id": "axel",   "name": "Axel",   "role": "Striker",        "desc": "Elite goal scoring striker.",              "glow": Color(1.0, 0.35, 0.2)},
	{"id": "enzo",   "name": "Enzo",   "role": "Forward",        "desc": "Aggressive pressing forward.",            "glow": Color(0.95, 0.75, 0.2)},
	{"id": "johan",  "name": "Johan",  "role": "General",        "desc": "Tactical field general.",                 "glow": Color(0.3, 0.85, 0.5)},
	{"id": "kai",    "name": "Kai",    "role": "Shooter",        "desc": "Unstoppable power shooter.",               "glow": Color(0.9, 0.2, 0.4)},
	{"id": "kian",   "name": "Kian",   "role": "Midfielder",     "desc": "Dynamic box-to-box midfielder.",          "glow": Color(0.5, 0.9, 0.6)},
	{"id": "leo",    "name": "Leo",    "role": "Defender",       "desc": "Defensive anchor specialist.",            "glow": Color(0.4, 0.6, 1.0)},
	{"id": "lionel", "name": "Lionel", "role": "Dribbler",       "desc": "Skillful freestyle dribbler.",             "glow": Color(0.7, 0.3, 0.95)},
	{"id": "marco",  "name": "Marco",  "role": "Finisher",       "desc": "Clutch finisher hero.",                    "glow": Color(1.0, 0.55, 0.2)},
	{"id": "rio",    "name": "Rio",    "role": "Sprint",         "desc": "Rapid counterattack sprinter.",           "glow": Color(0.2, 0.95, 0.5)},
	{"id": "zane",   "name": "Zane",   "role": "Defender",       "desc": "Smart positioning defender.",             "glow": Color(0.55, 0.75, 0.95)},
]

var _selected_id: String = ""
var _cards: Array[PanelContainer] = []
var _play_pulse_tween: Tween

func _get_hero_texture_path(hero_id: String) -> String:
	return "res://heroes/" + hero_id + ".png"

func _create_trophy_icon() -> Control:
	var TrophyIcon := preload("res://scenes/ui/TrophyIconDraw.gd") as GDScript
	var c: Control = TrophyIcon.new()
	c.custom_minimum_size = Vector2(24, 24)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return c

func _ready() -> void:
	_style_panels()
	_style_play_button()
	_populate_cards()
	_select_hero("arlo")
	_screen_open_animation()

# ====================== PANEL STYLING ======================

func _style_panels() -> void:
	# Deep green panels with neon accents (overgrown arena + esports)
	const DEEP_GREEN := Color(0.06, 0.12, 0.08)
	const NEON_BORDER := Color(0.2, 0.9, 0.6, 0.3)
	const STADIUM_GOLD := Color(0.95, 0.78, 0.25)
	for panel: PanelContainer in [top_bar, spotlight_panel, carousel_panel, bottom_bar]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(DEEP_GREEN.r, DEEP_GREEN.g, DEEP_GREEN.b, 0.9)
		sb.corner_radius_top_left = 12
		sb.corner_radius_top_right = 12
		sb.corner_radius_bottom_left = 12
		sb.corner_radius_bottom_right = 12
		sb.border_width_left = 2
		sb.border_width_top = 2
		sb.border_width_right = 2
		sb.border_width_bottom = 2
		sb.border_color = NEON_BORDER
		panel.add_theme_stylebox_override("panel", sb)

	# Title styling - stadium gold
	title_label.add_theme_color_override("font_color", STADIUM_GOLD)
	subtitle_label.add_theme_color_override("font_color", Color(0.75, 0.85, 0.7))
	subtitle_label.text = "Enter the overgrown arena"

	# Spotlight text
	spotlight_name.add_theme_color_override("font_color", Color.WHITE)
	spotlight_role.add_theme_color_override("font_color", Color(0.2, 0.95, 0.7))
	spotlight_desc.add_theme_color_override("font_color", Color(0.6, 0.75, 0.6))

func _style_play_button() -> void:
	play_button.disabled = true
	var sb_normal := StyleBoxFlat.new()
	sb_normal.bg_color = Color(0.15, 0.65, 0.35)
	sb_normal.corner_radius_top_left = 20
	sb_normal.corner_radius_top_right = 20
	sb_normal.corner_radius_bottom_left = 20
	sb_normal.corner_radius_bottom_right = 20
	sb_normal.border_width_left = 2
	sb_normal.border_width_top = 2
	sb_normal.border_width_right = 2
	sb_normal.border_width_bottom = 2
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
	sb_disabled.corner_radius_top_left = 16
	sb_disabled.corner_radius_top_right = 16
	sb_disabled.corner_radius_bottom_left = 16
	sb_disabled.corner_radius_bottom_right = 16
	play_button.add_theme_stylebox_override("disabled", sb_disabled)

	play_button.add_theme_color_override("font_color", Color.WHITE)
	play_button.add_theme_color_override("font_hover_color", Color.WHITE)
	play_button.add_theme_color_override("font_pressed_color", Color(0.9, 0.9, 0.9))
	play_button.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.5))

# ====================== HERO CARDS ======================

func _populate_cards() -> void:
	for hero in HERO_DATA:
		var card := _create_hero_card(hero)
		var wrapper := MarginContainer.new()
		wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrapper.add_child(card)
		hero_row.add_child(wrapper)
		card.set_meta("wrapper", wrapper)
		_cards.append(card)

func _create_hero_card(hero: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 260)
	card.set_meta("hero_id", hero["id"])
	card.set_meta("hero_data", hero)
	card.mouse_filter = Control.MOUSE_FILTER_STOP

	# Card StyleBox - larger, more rounded, role glow
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.08, 0.12, 0.1)
	sb.corner_radius_top_left = 24
	sb.corner_radius_top_right = 24
	sb.corner_radius_bottom_left = 24
	sb.corner_radius_bottom_right = 24
	sb.border_width_left = 3
	sb.border_width_top = 3
	sb.border_width_right = 3
	sb.border_width_bottom = 3
	sb.border_color = Color(hero["glow"].r, hero["glow"].g, hero["glow"].b, 0.35)
	sb.shadow_size = 6
	sb.shadow_offset = Vector2(0, 3)
	sb.shadow_color = Color(0, 0, 0, 0.45)
	card.add_theme_stylebox_override("panel", sb)

	# Inner margin
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(vbox)

	# Trophy row (top-right area)
	var trophy_row := HBoxContainer.new()
	trophy_row.add_theme_constant_override("separation", 4)
	trophy_row.alignment = BoxContainer.ALIGNMENT_END
	trophy_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(trophy_row)
	var trophy_spacer := Control.new()
	trophy_spacer.custom_minimum_size = Vector2(140, 0)
	trophy_spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	trophy_row.add_child(trophy_spacer)
	var trophy_icon := _create_trophy_icon()
	trophy_row.add_child(trophy_icon)

	# Portrait
	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(170, 150)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex_path: String = _get_hero_texture_path(hero["id"])
	var tex: Texture2D = load(tex_path) as Texture2D
	if tex:
		portrait.texture = tex
	vbox.add_child(portrait)

	# Name label
	var name_lbl := Label.new()
	name_lbl.text = hero["name"]
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 18)
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_lbl)

	# Role badge (rounded pill with role text)
	var role_badge := PanelContainer.new()
	role_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var role_sb := StyleBoxFlat.new()
	role_sb.bg_color = Color(hero["glow"].r, hero["glow"].g, hero["glow"].b, 0.28)
	role_sb.corner_radius_top_left = 10
	role_sb.corner_radius_top_right = 10
	role_sb.corner_radius_bottom_left = 10
	role_sb.corner_radius_bottom_right = 10
	role_sb.border_width_left = 1
	role_sb.border_width_top = 1
	role_sb.border_width_right = 1
	role_sb.border_width_bottom = 1
	role_sb.border_color = Color(hero["glow"].r, hero["glow"].g, hero["glow"].b, 0.6)
	role_badge.add_theme_stylebox_override("panel", role_sb)
	var role_lbl := Label.new()
	role_lbl.text = hero["role"]
	role_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_lbl.add_theme_font_size_override("font_size", 12)
	role_lbl.add_theme_color_override("font_color", hero["glow"])
	role_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	role_badge.add_child(role_lbl)
	vbox.add_child(role_badge)

	# Signals
	card.gui_input.connect(_on_card_gui_input.bind(card))
	card.mouse_entered.connect(_on_card_mouse_entered.bind(card))
	card.mouse_exited.connect(_on_card_mouse_exited.bind(card))

	return card

# ====================== CARD INTERACTIONS ======================

func _on_card_mouse_entered(card: PanelContainer) -> void:
	if card.get_meta("hero_id") == _selected_id:
		return
	card.pivot_offset = card.size / 2
	var t := create_tween()
	t.tween_property(card, "scale", Vector2(1.06, 1.06), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func _on_card_mouse_exited(card: PanelContainer) -> void:
	if card.get_meta("hero_id") == _selected_id:
		return
	var t := create_tween()
	t.tween_property(card, "scale", Vector2.ONE, 0.12).set_ease(Tween.EASE_OUT)

func _on_card_gui_input(event: InputEvent, card: PanelContainer) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			var hero_id: String = card.get_meta("hero_id")
			_select_hero(hero_id)
			# Click bounce
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

	# Update GameManager
	GameManager.selected_hero_path = _get_hero_texture_path(hero_id)
	GameManager.selected_hero_name = hero_data["name"]
	GameManager.selected_hero_id = hero_id

	# Update spotlight
	var tex: Texture2D = load(GameManager.selected_hero_path) as Texture2D
	if tex:
		spotlight_sprite.texture = tex
	if spotlight_ring:
		spotlight_ring.glow_color = hero_data["glow"]
		spotlight_ring.queue_redraw()
	spotlight_name.text = hero_data["name"]
	spotlight_role.text = hero_data["role"]
	spotlight_role.add_theme_color_override("font_color", hero_data["glow"])
	spotlight_desc.text = hero_data["desc"]

	# Enable play button + start pulse
	play_button.disabled = false
	_start_play_pulse()

	# Update card visuals
	_update_card_visuals()

func _update_card_visuals() -> void:
	for card: PanelContainer in _cards:
		var cid: String = card.get_meta("hero_id")
		var hero: Dictionary = card.get_meta("hero_data")
		var glow: Color = hero["glow"]
		var sb: StyleBoxFlat = card.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
		var wrapper: MarginContainer = card.get_meta("wrapper", null)

		if cid == _selected_id:
			sb.border_color = glow
			sb.border_width_left = 4
			sb.border_width_top = 4
			sb.border_width_right = 4
			sb.border_width_bottom = 4
			sb.shadow_color = Color(glow.r, glow.g, glow.b, 0.55)
			sb.shadow_size = 12
			sb.shadow_offset = Vector2(0, 5)
			card.modulate = Color.WHITE
			card.scale = Vector2.ONE
			if wrapper:
				wrapper.add_theme_constant_override("margin_top", -10)
				wrapper.add_theme_constant_override("margin_bottom", 10)
		else:
			sb.border_color = Color(glow.r, glow.g, glow.b, 0.2)
			sb.border_width_left = 2
			sb.border_width_top = 2
			sb.border_width_right = 2
			sb.border_width_bottom = 2
			sb.shadow_color = Color(0, 0, 0, 0.35)
			sb.shadow_size = 6
			sb.shadow_offset = Vector2(0, 3)
			card.modulate = Color(0.65, 0.65, 0.65)
			if wrapper:
				wrapper.add_theme_constant_override("margin_top", 0)
				wrapper.add_theme_constant_override("margin_bottom", 0)

		card.add_theme_stylebox_override("panel", sb)

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
