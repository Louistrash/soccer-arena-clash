extends Node
## Solo Showdown: 2-2-2 formatie. 3 teammates (2 links, 1 midden) + 2 opponents (rechts).
## Hero spawnt in midden. Totaal 4 vs 2.

const ENEMY_SCENE := preload("res://actors/Enemy.tscn")
const ENEMY_TYPES: Array[String] = ["razor", "bulwark", "vinewitch"]
const TEAMMATE_HERO_IDS: Array[String] = ["arlo", "axel", "enzo", "johan", "kai", "kian", "leo", "lionel", "marco", "rio", "zane"]

# Field bounds (match GameCamera)
const FIELD_LEFT := 200.0
const FIELD_RIGHT := 4000.0
const FIELD_TOP := 150.0
const FIELD_BOTTOM := 2500.0
const FIELD_CX := 2100.0
const FIELD_CY := 1325.0

enum Role { DEFENDER, MIDFIELDER, STRIKER }

var arena: Node2D
var enemy_container: Node2D
var hero_ref: WeakRef = WeakRef.new()

var _teammates: Array[CharacterBody2D] = []
var _opponents: Array[CharacterBody2D] = []
var _last_opponents_count: int = -1

signal teammates_count_changed(count: int)
signal opponents_count_changed(count: int)
signal enemy_count_changed(count: int)

func setup(p_arena: Node2D, p_hero: Node2D) -> void:
	arena = p_arena
	hero_ref = weakref(p_hero)
	enemy_container = arena.get_node_or_null("YSort/EnemyContainer") as Node2D
	if not enemy_container:
		enemy_container = arena.get_node_or_null("YSort") as Node2D

func _process(_delta: float) -> void:
	var c: int = get_opponents_alive()
	if c != _last_opponents_count:
		_last_opponents_count = c
		enemy_count_changed.emit(c)

func spawn_all() -> void:
	if not enemy_container:
		return
	_spawn_teammates()
	_spawn_opponents()
	teammates_count_changed.emit(_teammates.size())
	opponents_count_changed.emit(_opponents.size())
	enemy_count_changed.emit(_opponents.size())

func _spawn_teammates() -> void:
	# 2 links (uit elkaar), 1 midden (naast Hero)
	var positions: Array[Vector2] = [
		Vector2(800, 1000),
		Vector2(900, 1650),
		Vector2(2000, FIELD_CY),
	]
	var roles: Array[int] = [Role.DEFENDER, Role.DEFENDER, Role.MIDFIELDER]
	for i in range(3):
		var pos: Vector2 = positions[i] + Vector2(randf_range(-30, 30), randf_range(-30, 30))
		var bot: CharacterBody2D = _spawn_bot_at(pos, "player", roles[i], i, true)
		if bot:
			_teammates.append(bot)

func _spawn_opponents() -> void:
	# 2 rechts, goed uit elkaar
	var positions: Array[Vector2] = [
		Vector2(3300, 1100),
		Vector2(3400, 1550),
	]
	var roles: Array[int] = [Role.DEFENDER, Role.MIDFIELDER]
	for i in range(2):
		var pos: Vector2 = positions[i] + Vector2(randf_range(-30, 30), randf_range(-30, 30))
		var bot: CharacterBody2D = _spawn_bot_at(pos, "opponent", roles[i], i, false)
		if bot:
			_opponents.append(bot)

func _spawn_bot_at(pos: Vector2, team_name: String, role_id: int, idx: int, is_teammate: bool) -> CharacterBody2D:
	var bot: CharacterBody2D = ENEMY_SCENE.instantiate() as CharacterBody2D
	if not bot:
		return null
	bot.global_position = pos
	bot.setup_team(team_name)
	bot.setup_role(role_id)
	if is_teammate:
		var hero_idx: int = idx % TEAMMATE_HERO_IDS.size()
		bot.setup_teammate_texture(TEAMMATE_HERO_IDS[hero_idx])
	else:
		var type_idx: int = idx % ENEMY_TYPES.size()
		bot.setup_type(ENEMY_TYPES[type_idx])
	enemy_container.add_child(bot)
	return bot

func get_teammates_alive() -> int:
	var c: int = 0
	for b in _teammates:
		if is_instance_valid(b) and not b.is_dead:
			c += 1
	return c

func get_opponents_alive() -> int:
	var c: int = 0
	for b in _opponents:
		if is_instance_valid(b) and not b.is_dead:
			c += 1
	return c

func get_enemies_alive_count() -> int:
	return get_opponents_alive()

func get_wave_number() -> int:
	return 1

func get_last_spawn_zone() -> String:
	return "2-2-2"
