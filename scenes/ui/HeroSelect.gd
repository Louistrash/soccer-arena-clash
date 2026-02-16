extends Control
## Brawlstars-inspired Soccer Hero Gallery.
## Cards with glow, spotlight, stadium background, punchy animations.

# --- Node refs ---
@onready var background: ColorRect = $Background
@onready var hero_row: HBoxContainer = $MainVBox/CarouselPanel/CarouselMargin/HeroScroll/HeroRow
@onready var play_button: Button = $MainVBox/BottomBar/BottomMargin/BottomHBox/PlayButton
@onready var spotlight_sprite: TextureRect = $MainVBox/SpotlightPanel/SpotlightMargin/SpotlightHBox/SpotlightSprite
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
	{"id": "player1",   "name": "Player 1",  "role": "Striker",  "desc": "Your custom soccer hero.",           "glow": Color(0.2, 0.9, 0.3)},
	{"id": "pulse",     "name": "Pulse",     "role": "Striker",  "desc": "Accurate shots, burst movement.",  "glow": Color(0.16, 0.66, 1.0)},
	{"id": "lionel",    "name": "Lionel",    "role": "Striker",  "desc": "Quick shots and fast dribbles.",   "glow": Color(0.16, 0.66, 1.0)},
	{"id": "forge",     "name": "Forge",     "role": "Tank",     "desc": "Soaks damage, holds midfield.",    "glow": Color(1.0, 0.48, 0.16)},
	{"id": "dreadlord", "name": "Dreadlord", "role": "Tank",     "desc": "Blocks lanes and clears ball.",    "glow": Color(1.0, 0.48, 0.16)},
	{"id": "nova",      "name": "Nova",      "role": "Support",  "desc": "Buffs allies, disrupts enemies.",  "glow": Color(0.36, 1.0, 0.69)},
	{"id": "benny",     "name": "Benny",     "role": "Support",  "desc": "Heals and shields teammates.",     "glow": Color(0.36, 1.0, 0.69)},
	{"id": "glyph",     "name": "Glyph",     "role": "Mage",     "desc": "Tricky zones and control shots.",  "glow": Color(0.66, 0.33, 0.97)},
	{"id": "storm",     "name": "Storm",     "role": "Mage",     "desc": "Area pressure and ball denial.",   "glow": Color(0.40, 0.91, 0.98)},
]

var _selected_id: String = ""
var _cards: Array[PanelContainer] = []
var _play_pulse_tween: Tween

func _get_hero_texture_path(hero_id: String) -> String:
	if hero_id == "player1":
		return "res://assets/player1.png"
	return "res://heroes/" + hero_id + ".png"

func _ready() -> void:
	_style_panels()
	_style_play_button()
	_populate_cards()
	_select_hero("player1")
	_screen_open_animation()

# ====================== PANEL STYLING ======================

func _style_panels() -> void:
	# Dark semi-transparent panels
	for panel: PanelContainer in [top_bar, spotlight_panel, carousel_panel, bottom_bar]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.17, 0.18, 0.21, 0.85)
		sb.corner_radius_top_left = 0
		sb.corner_radius_top_right = 0
		sb.corner_radius_bottom_left = 0
		sb.corner_radius_bottom_right = 0
		panel.add_theme_stylebox_override("panel", sb)

	# Title styling
	title_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.31))
	subtitle_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))

	# Spotlight text
	spotlight_name.add_theme_color_override("font_color", Color.WHITE)
	spotlight_role.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	spotlight_desc.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

func _style_play_button() -> void:
	play_button.disabled = true
	var sb_normal := StyleBoxFlat.new()
	sb_normal.bg_color = Color(0.11, 0.72, 0.33)
	sb_normal.corner_radius_top_left = 16
	sb_normal.corner_radius_top_right = 16
	sb_normal.corner_radius_bottom_left = 16
	sb_normal.corner_radius_bottom_right = 16
	sb_normal.shadow_size = 6
	sb_normal.shadow_color = Color(0.11, 0.72, 0.33, 0.4)
	sb_normal.shadow_offset = Vector2(0, 3)
	play_button.add_theme_stylebox_override("normal", sb_normal)

	var sb_hover := sb_normal.duplicate() as StyleBoxFlat
	sb_hover.bg_color = Color(0.30, 1.0, 0.53)
	play_button.add_theme_stylebox_override("hover", sb_hover)

	var sb_pressed := sb_normal.duplicate() as StyleBoxFlat
	sb_pressed.bg_color = Color(0.08, 0.55, 0.25)
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

# ====================== BACKGROUND ======================

func _draw() -> void:
	# Stadium gradient background
	var rect: Rect2 = Rect2(Vector2.ZERO, size)
	var top_color := Color(0.05, 0.11, 0.06)
	var bot_color := Color(0.10, 0.23, 0.12)
	var points := PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)])
	var colors := PackedColorArray([top_color, top_color, bot_color, bot_color])
	draw_polygon(points, colors)

	# Subtle grass stripes
	var stripe_color := Color(1, 1, 1, 0.03)
	for y_pos in range(0, int(size.y), 40):
		draw_line(Vector2(0, y_pos), Vector2(size.x, y_pos), stripe_color, 1.0)

	# Stadium light glows (top corners)
	var glow_color := Color(1, 1, 1, 0.04)
	for i in range(8):
		var r: float = 300.0 - float(i) * 35.0
		var alpha: float = 0.02 + float(i) * 0.005
		draw_circle(Vector2(100, 50), r, Color(1, 1, 1, alpha))
		draw_circle(Vector2(size.x - 100, 50), r, Color(1, 1, 1, alpha))

# ====================== HERO CARDS ======================

func _populate_cards() -> void:
	for hero in HERO_DATA:
		var card := _create_hero_card(hero)
		hero_row.add_child(card)
		_cards.append(card)

func _create_hero_card(hero: Dictionary) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(160, 210)
	card.set_meta("hero_id", hero["id"])
	card.set_meta("hero_data", hero)
	card.mouse_filter = Control.MOUSE_FILTER_STOP

	# Card StyleBox
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.17, 0.18, 0.21)
	sb.corner_radius_top_left = 16
	sb.corner_radius_top_right = 16
	sb.corner_radius_bottom_left = 16
	sb.corner_radius_bottom_right = 16
	sb.border_width_left = 3
	sb.border_width_top = 3
	sb.border_width_right = 3
	sb.border_width_bottom = 3
	sb.border_color = Color(hero["glow"].r, hero["glow"].g, hero["glow"].b, 0.3)
	sb.shadow_size = 4
	sb.shadow_offset = Vector2(0, 2)
	sb.shadow_color = Color(0, 0, 0, 0.4)
	card.add_theme_stylebox_override("panel", sb)

	# Inner margin
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(vbox)

	# Portrait
	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(140, 130)
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
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_lbl)

	# Role label
	var role_lbl := Label.new()
	role_lbl.text = hero["role"]
	role_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	role_lbl.add_theme_font_size_override("font_size", 12)
	role_lbl.add_theme_color_override("font_color", hero["glow"])
	role_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(role_lbl)

	# Signals
	card.gui_input.connect(_on_card_gui_input.bind(card))
	card.mouse_entered.connect(_on_card_mouse_entered.bind(card))
	card.mouse_exited.connect(_on_card_mouse_exited.bind(card))

	return card

# ====================== CARD INTERACTIONS ======================

func _on_card_mouse_entered(card: PanelContainer) -> void:
	if card.get_meta("hero_id") == _selected_id:
		return
	var t := create_tween()
	t.tween_property(card, "scale", Vector2(1.08, 1.08), 0.12).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	card.pivot_offset = card.size / 2

func _on_card_mouse_exited(card: PanelContainer) -> void:
	if card.get_meta("hero_id") == _selected_id:
		return
	var t := create_tween()
	t.tween_property(card, "scale", Vector2.ONE, 0.1)

func _on_card_gui_input(event: InputEvent, card: PanelContainer) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			var hero_id: String = card.get_meta("hero_id")
			_select_hero(hero_id)
			# Click bounce
			card.pivot_offset = card.size / 2
			var t := create_tween()
			t.tween_property(card, "scale", Vector2(0.92, 0.92), 0.06)
			t.tween_property(card, "scale", Vector2(1.05, 1.05), 0.08).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			t.tween_property(card, "scale", Vector2.ONE, 0.06)

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

		if cid == _selected_id:
			sb.border_color = glow
			sb.border_width_left = 4
			sb.border_width_top = 4
			sb.border_width_right = 4
			sb.border_width_bottom = 4
			sb.shadow_color = Color(glow.r, glow.g, glow.b, 0.5)
			sb.shadow_size = 8
			card.modulate = Color.WHITE
			card.scale = Vector2.ONE
		else:
			sb.border_color = Color(glow.r, glow.g, glow.b, 0.2)
			sb.border_width_left = 2
			sb.border_width_top = 2
			sb.border_width_right = 2
			sb.border_width_bottom = 2
			sb.shadow_color = Color(0, 0, 0, 0.3)
			sb.shadow_size = 4
			card.modulate = Color(0.65, 0.65, 0.65)

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
