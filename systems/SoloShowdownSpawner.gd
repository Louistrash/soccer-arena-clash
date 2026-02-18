extends Node
## Solo mode: alleen Hero vs enemies. +1 enemy per gewonnen ronde, max 11.

const ENEMY_SCENE := preload("res://actors/Enemy.tscn")
const ENEMY_TYPES: Array[String] = ["razor", "bulwark", "vinewitch"]

# Field bounds (match GameCamera)
const FIELD_LEFT := 200.0
const FIELD_RIGHT := 4000.0
const FIELD_TOP := 150.0
const FIELD_BOTTOM := 2500.0
const FIELD_CX := 2100.0
const FIELD_CY := 1325.0
const MIN_ENEMIES := 3
const MAX_ENEMIES := 11

enum Role { DEFENDER, MIDFIELDER, STRIKER }

var arena: Node2D
var enemy_container: Node2D
var hero_ref: WeakRef = WeakRef.new()

var _opponents: Array[CharacterBody2D] = []
var _last_opponents_count: int = -1
var _current_wave: int = 1
var _had_opponents: bool = false

signal teammates_count_changed(count: int)
signal opponents_count_changed(count: int)
signal enemy_count_changed(count: int)
signal wave_completed(wave: int)

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
	if _had_opponents and c == 0:
		_had_opponents = false
		wave_completed.emit(_current_wave)
		_spawn_next_wave()

func spawn_all() -> void:
	if not enemy_container:
		return
	_current_wave = 1
	_spawn_opponents()
	_had_opponents = _opponents.size() > 0
	teammates_count_changed.emit(0)
	opponents_count_changed.emit(_opponents.size())
	enemy_count_changed.emit(_opponents.size())

func _spawn_next_wave() -> void:
	_current_wave += 1
	_opponents.clear()
	_spawn_opponents()
	_had_opponents = _opponents.size() > 0
	teammates_count_changed.emit(0)
	opponents_count_changed.emit(_opponents.size())
	enemy_count_changed.emit(_opponents.size())

func _spawn_opponents() -> void:
	var count: int = mini(MIN_ENEMIES + _current_wave - 1, MAX_ENEMIES)
	var positions: Array[Vector2] = _get_spawn_positions(count)
	var roles: Array[int] = [Role.DEFENDER, Role.MIDFIELDER, Role.STRIKER]
	for i in range(count):
		var pos: Vector2 = positions[i] + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		var role_id: int = roles[i % roles.size()]
		var bot: CharacterBody2D = _spawn_opponent_at(pos, role_id, i)
		if bot:
			_opponents.append(bot)

func _get_spawn_positions(count: int) -> Array[Vector2]:
	# Posities verspreid over het veld (links, rechts, hoeken)
	var pool: Array[Vector2] = [
		Vector2(800, 1000), Vector2(900, 1700), Vector2(600, 1400),
		Vector2(2800, 900), Vector2(3000, 1200), Vector2(2600, 1600),
		Vector2(3400, 1100), Vector2(3600, 1500), Vector2(3200, 1800),
		Vector2(1500, 800), Vector2(1800, 1900), Vector2(2400, 700),
	]
	var positions: Array[Vector2] = []
	for i in range(count):
		positions.append(pool[i % pool.size()])
	return positions

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
	return _current_wave

func get_last_spawn_zone() -> String:
	return "SOLO"
