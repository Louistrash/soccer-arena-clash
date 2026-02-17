extends Node
## Solo Showdown: spawns 4 teammate bots + 5 opponent bots at match start.
## 5v5 combat: Hero + 4 teammates vs 5 opponents. No respawn.

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
	# Player team attacks right. Formation: 2 def, 2 mid, 1 striker
	var def_positions: Array[Vector2] = [
		Vector2(700, FIELD_CY - 200),
		Vector2(800, FIELD_CY + 200),
	]
	var mid_positions: Array[Vector2] = [
		Vector2(1800, FIELD_CY - 150),
		Vector2(2000, FIELD_CY + 150),
	]
	var str_positions: Array[Vector2] = [
		Vector2(3200, FIELD_CY),
	]
	var all_positions: Array[Vector2] = def_positions + mid_positions + str_positions
	var roles: Array[int] = [Role.DEFENDER, Role.DEFENDER, Role.MIDFIELDER, Role.MIDFIELDER, Role.STRIKER]
	for i in range(4):
		var pos: Vector2 = all_positions[i] + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		var bot: CharacterBody2D = _spawn_bot_at(pos, "player", roles[i], i, true)
		if bot:
			_teammates.append(bot)

func _spawn_opponents() -> void:
	# Opponent team attacks left. Formation: 2 def, 2 mid, 1 striker
	var def_positions: Array[Vector2] = [
		Vector2(3500, FIELD_CY - 200),
		Vector2(3400, FIELD_CY + 200),
	]
	var mid_positions: Array[Vector2] = [
		Vector2(2400, FIELD_CY - 150),
		Vector2(2200, FIELD_CY + 150),
	]
	var str_positions: Array[Vector2] = [
		Vector2(1000, FIELD_CY),
	]
	var all_positions: Array[Vector2] = def_positions + mid_positions + str_positions
	var roles: Array[int] = [Role.DEFENDER, Role.DEFENDER, Role.MIDFIELDER, Role.MIDFIELDER, Role.STRIKER]
	for i in range(5):
		var pos: Vector2 = all_positions[i] + Vector2(randf_range(-40, 40), randf_range(-40, 40))
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
	return "5v5 SHOWDOWN"
