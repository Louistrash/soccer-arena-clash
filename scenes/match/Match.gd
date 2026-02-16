extends Node

@onready var arena: Node2D = $Arena
@onready var camera: Camera2D = $Camera2D
@onready var health_bar: ProgressBar = $HUD/HealthBar
@onready var goal_label: Label = $HUD/GoalLabel
@onready var match_over_label: Label = $HUD/MatchOverLabel

var hero: CharacterBody2D
var enemy_spawner: Node
var match_time: float = 120.0
var score_left: int = 0
var score_right: int = 0
var match_ended: bool = false
var _dirty_spawn_timer: float = 0.0
var _destructible_spawn_timer: float = 22.0
var _destructibles_spawned: int = 0
const DIRTY_SPAWN_INTERVAL_MIN: float = 15.0
const DIRTY_SPAWN_INTERVAL_MAX: float = 20.0
const DESTRUCTIBLE_SPAWN_INTERVAL: float = 22.0
const MAX_DESTRUCTIBLES: int = 3
const ARENA_MIN: Vector2 = Vector2(350, 250)
const ARENA_MAX: Vector2 = Vector2(3850, 2400)

var glass_scoreboard: CanvasLayer

func _ready() -> void:
	_spawn_hero()
	_setup_enemy_spawner()
	_setup_glass_scoreboard()
	_setup_view_toggle()
	_setup_touch_controls()
	_setup_goal_areas()
	_spawn_initial_dirty_zones()
	_update_score_ui()

func _setup_glass_scoreboard() -> void:
	var scene: PackedScene = load("res://ui/GlassNeonScoreboard.tscn") as PackedScene
	if scene:
		glass_scoreboard = scene.instantiate() as CanvasLayer
		if glass_scoreboard:
			$HUD.add_child(glass_scoreboard)
			if glass_scoreboard.has_method("setup"):
				glass_scoreboard.setup(enemy_spawner)

func _setup_touch_controls() -> void:
	var scene: PackedScene = load("res://ui/TouchControls.tscn") as PackedScene
	if scene:
		var touch: CanvasLayer = scene.instantiate() as CanvasLayer
		if touch:
			add_child(touch)

func _setup_view_toggle() -> void:
	var scene: PackedScene = load("res://ui/ViewToggleHUD.tscn") as PackedScene
	if scene and camera:
		var view_toggle: CanvasLayer = scene.instantiate() as CanvasLayer
		if view_toggle:
			$HUD.add_child(view_toggle)
			if view_toggle.has_method("setup"):
				view_toggle.setup(camera)

func _setup_goal_areas() -> void:
	var goal_left: Node = arena.get_node_or_null("GoalLeft")
	var goal_right: Node = arena.get_node_or_null("GoalRight")
	if goal_left and goal_left.has_signal("goal_scored"):
		goal_left.goal_scored.connect(_on_goal)
	if goal_right and goal_right.has_signal("goal_scored"):
		goal_right.goal_scored.connect(_on_goal)

func _on_goal(team: String) -> void:
	if team == "left":
		score_left += 1
	else:
		score_right += 1
	_update_score_ui()
	if goal_label:
		goal_label.visible = true
		var t: Tween = create_tween()
		t.tween_interval(1.2)
		t.tween_callback(func(): goal_label.visible = false)
	if glass_scoreboard and glass_scoreboard.has_method("trigger_goal_glow"):
		glass_scoreboard.trigger_goal_glow()

func _spawn_hero() -> void:
	var hero_scene: PackedScene = load("res://actors/Hero.tscn") as PackedScene
	if not hero_scene:
		return
	hero = hero_scene.instantiate() as CharacterBody2D
	if not hero:
		return
	var ysort: Node2D = arena.get_node_or_null("YSort") as Node2D
	var spawn_point: Marker2D = arena.get_node_or_null("YSort/SpawnPoint") as Marker2D
	if spawn_point:
		hero.global_position = spawn_point.global_position
	else:
		hero.global_position = Vector2(2100, 1325)
	if ysort:
		ysort.add_child(hero)
	else:
		arena.add_child(hero)
	# Fallback when Match runs directly (e.g. Run Current Scene) without HeroSelect
	var hero_path: String = GameManager.selected_hero_path
	var hero_name_str: String = GameManager.selected_hero_name
	if hero_path.is_empty():
		hero_path = "res://assets/player1.png"
		hero_name_str = "Player 1"
		GameManager.selected_hero_id = "player1"
	hero.set_hero_texture(hero_path)
	hero.set_hero_name(hero_name_str)
	camera.target = hero
	camera.global_position = hero.global_position
	camera.make_current()

func _setup_enemy_spawner() -> void:
	var script: GDScript = load("res://systems/EnemySpawner.gd") as GDScript
	enemy_spawner = script.new()
	add_child(enemy_spawner)
	enemy_spawner.setup(arena, hero)
	enemy_spawner.spawn_initial()

func _process(delta: float) -> void:
	if match_ended:
		return

	_update_timer(delta)
	_update_dirty_zones(delta)
	_update_destructibles(delta)

	if match_time <= 0 and not match_ended:
		_end_match()

func _update_timer(delta: float) -> void:
	if match_time > 0.0:
		match_time -= delta
		if match_time < 0.0:
			match_time = 0.0
		var minutes: int = int(match_time) / 60
		var seconds: int = int(match_time) % 60
		var txt: String = "%d:%02d" % [minutes, seconds]
		if glass_scoreboard and glass_scoreboard.has_method("set_timer_text"):
			glass_scoreboard.set_timer_text(txt, match_time < 30.0)

func _update_score_ui() -> void:
	# Scoreboard removed
	pass

func _spawn_initial_dirty_zones() -> void:
	var count: int = randi_range(4, 6)
	for i in count:
		_spawn_dirty_zone()
	_dirty_spawn_timer = randf_range(DIRTY_SPAWN_INTERVAL_MIN, DIRTY_SPAWN_INTERVAL_MAX)

func _update_dirty_zones(delta: float) -> void:
	_dirty_spawn_timer -= delta
	if _dirty_spawn_timer <= 0:
		_spawn_dirty_zone()
		_dirty_spawn_timer = randf_range(DIRTY_SPAWN_INTERVAL_MIN, DIRTY_SPAWN_INTERVAL_MAX)

func _update_destructibles(delta: float) -> void:
	if _destructibles_spawned >= MAX_DESTRUCTIBLES:
		return
	_destructible_spawn_timer -= delta
	if _destructible_spawn_timer <= 0:
		_spawn_destructible_rock()
		_destructible_spawn_timer = DESTRUCTIBLE_SPAWN_INTERVAL
		_destructibles_spawned += 1

func _spawn_destructible_rock() -> void:
	var scene: PackedScene = load("res://obstacles/DestructibleRock.tscn") as PackedScene
	if not scene:
		return
	var rock: StaticBody2D = scene.instantiate() as StaticBody2D
	if not rock:
		return
	rock.global_position = Vector2(
		randf_range(ARENA_MIN.x, ARENA_MAX.x),
		randf_range(ARENA_MIN.y, ARENA_MAX.y)
	)
	var ysort: Node2D = arena.get_node_or_null("YSort") as Node2D
	if ysort:
		ysort.add_child(rock)
	else:
		arena.add_child(rock)

func _spawn_dirty_zone() -> void:
	var scene: PackedScene = load("res://obstacles/DirtyZone.tscn") as PackedScene
	if not scene:
		return
	var zone: Area2D = scene.instantiate() as Area2D
	if not zone:
		return
	zone.global_position = Vector2(
		randf_range(ARENA_MIN.x, ARENA_MAX.x),
		randf_range(ARENA_MIN.y, ARENA_MAX.y)
	)
	var ysort: Node2D = arena.get_node_or_null("YSort") as Node2D
	if ysort:
		ysort.add_child(zone)
	else:
		arena.add_child(zone)

func _end_match() -> void:
	match_ended = true
	var winner: String = "Draw!"
	if score_left > score_right:
		winner = "Left wins!"
	elif score_right > score_left:
		winner = "Right wins!"
	match_over_label.text = winner
	match_over_label.visible = true
	# Return to menu after 3 seconds
	await get_tree().create_timer(3.0).timeout
	GameManager.goto_hero_select()