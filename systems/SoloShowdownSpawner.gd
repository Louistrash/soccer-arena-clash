extends Node
## Solo mode: alleen Hero vs enemies. Geen teammates.

const ENEMY_SCENE := preload("res://actors/Enemy.tscn")
const ENEMY_TYPES: Array[String] = ["razor", "bulwark", "vinewitch"]

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
	_spawn_opponents()
	teammates_count_changed.emit(0)
	opponents_count_changed.emit(_opponents.size())
	enemy_count_changed.emit(_opponents.size())

func _spawn_opponents() -> void:
	# 3 opponents verspreid over het veld (links, midden-rechts, rechts)
	var positions: Array[Vector2] = [
		Vector2(900, 1200),
		Vector2(2800, 1000),
		Vector2(3500, 1550),
	]
	var roles: Array[int] = [Role.DEFENDER, Role.MIDFIELDER, Role.STRIKER]
	for i in range(3):
		var pos: Vector2 = positions[i] + Vector2(randf_range(-30, 30), randf_range(-30, 30))
		var bot: CharacterBody2D = _spawn_opponent_at(pos, roles[i], i)
		if bot:
			_opponents.append(bot)

func _spawn_opponent_at(pos: Vector2, role_id: int, idx: int) -> CharacterBody2D:
	var bot: CharacterBody2D = ENEMY_SCENE.instantiate() as CharacterBody2D
	if not bot:
		return null
	bot.global_position = pos
	bot.setup_team("opponent")
	bot.setup_role(role_id)
	var type_idx: int = idx % ENEMY_TYPES.size()
	bot.setup_type(ENEMY_TYPES[type_idx])
	enemy_container.add_child(bot)
	return bot

func get_teammates_alive() -> int:
	return 0

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
	return "SOLO"
