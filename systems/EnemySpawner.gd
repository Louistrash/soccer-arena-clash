extends Node
## Dynamic Brawl-style enemy spawner.
## Spawns bots every 3-6s at corners or center. Max 3 alive.

const ENEMY_SCENE := preload("res://actors/Enemy.tscn")
const MAX_ENEMIES: int = 3
const SPAWN_INTERVAL_MIN: float = 3.0
const SPAWN_INTERVAL_MAX: float = 6.0
const CENTER_SPAWN_CHANCE: float = 0.3
const ENEMY_TYPES: Array[String] = ["razor", "bulwark", "vinewitch"]

var arena: Node2D
var enemy_container: Node2D
var corner_spawns: Array[Marker2D] = []
var center_spawn: Marker2D
var hero_ref: WeakRef = WeakRef.new()

var _enemies: Array[CharacterBody2D] = []
var _respawn_timer: float = 2.0
var _last_spawn_pos: Vector2 = Vector2.ZERO
var _last_spawn_zone: String = "CENTER"
var _wave_number: int = 0
var _last_emitted_count: int = -1

signal enemy_spawned(enemy: CharacterBody2D, pos: Vector2)
signal enemy_count_changed(count: int)

func setup(p_arena: Node2D, p_hero: Node2D) -> void:
	arena = p_arena
	hero_ref = weakref(p_hero)

	enemy_container = arena.get_node_or_null("YSort/EnemyContainer") as Node2D
	if not enemy_container:
		enemy_container = arena.get_node_or_null("YSort") as Node2D

	var spawns_node: Node2D = arena.get_node_or_null("YSort/SpawnPoints") as Node2D
	if spawns_node:
		for child in spawns_node.get_children():
			if child is Marker2D:
				if child.name == "CenterSpawn":
					center_spawn = child as Marker2D
				else:
					corner_spawns.append(child as Marker2D)

func _process(delta: float) -> void:
	_clean_dead_enemies()
	var count: int = _get_enemies_alive()
	if count != _last_emitted_count:
		_last_emitted_count = count
		enemy_count_changed.emit(count)
	if count < MAX_ENEMIES:
		_respawn_timer -= delta
		if _respawn_timer <= 0.0:
			_spawn_one()
			_respawn_timer = randf_range(SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_spawn"):
		_spawn_near_player()

func _get_enemies_alive() -> int:
	var count: int = 0
	for e in _enemies:
		if is_instance_valid(e) and not e.is_dead:
			count += 1
	return count

func _clean_dead_enemies() -> void:
	_enemies = _enemies.filter(func(e): return is_instance_valid(e) and not e.is_dead)

func _pick_spawn_point() -> Vector2:
	# 30% chance center, 70% corners
	if center_spawn and randf() < CENTER_SPAWN_CHANCE:
		return center_spawn.global_position
	if corner_spawns.size() > 0:
		var idx: int = randi() % corner_spawns.size()
		return corner_spawns[idx].global_position
	return Vector2(2100, 1325)

func _spawn_one() -> void:
	if not enemy_container:
		return
	var pos: Vector2 = _pick_spawn_point()
	var offset: Vector2 = Vector2(randf_range(-30, 30), randf_range(-30, 30))
	_spawn_at(pos + offset)

func _spawn_at(pos: Vector2) -> void:
	if not enemy_container:
		return
	_wave_number += 1
	_last_spawn_pos = pos
	_last_spawn_zone = _pos_to_zone_name(pos)
	var enemy: CharacterBody2D = ENEMY_SCENE.instantiate() as CharacterBody2D
	if not enemy:
		return
	
	# Pick enemy type to ensure variety (avoid duplicates)
	var counts: Dictionary = {}
	for t in ENEMY_TYPES:
		counts[t] = 0
	
	for e in _enemies:
		if is_instance_valid(e) and "enemy_type" in e:
			var t: String = e.enemy_type
			if t in counts:
				counts[t] += 1
	
	var min_count: int = 999
	for t in counts:
		if counts[t] < min_count:
			min_count = counts[t]
	
	var candidates: Array[String] = []
	for t in counts:
		if counts[t] == min_count:
			candidates.append(t)
	
	if candidates.size() > 0:
		var chosen: String = candidates[randi() % candidates.size()]
		if enemy.has_method("setup_type"):
			enemy.setup_type(chosen)

	enemy.global_position = pos
	enemy_container.add_child(enemy)
	_enemies.append(enemy)
	enemy_spawned.emit(enemy, pos)
	_last_emitted_count = _get_enemies_alive()
	enemy_count_changed.emit(_last_emitted_count)

func _spawn_near_player() -> void:
	var hero: Node2D = hero_ref.get_ref() as Node2D
	if not hero:
		_spawn_one()
		return
	var offset: Vector2 = Vector2(randf_range(-80, 80), randf_range(-80, 80))
	_spawn_at(hero.global_position + offset)

func spawn_initial() -> void:
	for i in 2:
		_spawn_one()

func get_enemies_alive_count() -> int:
	return _get_enemies_alive()

func get_last_spawn_pos() -> Vector2:
	return _last_spawn_pos

func get_last_spawn_zone() -> String:
	return _last_spawn_zone

func get_wave_number() -> int:
	return _wave_number

func _pos_to_zone_name(pos: Vector2) -> String:
	var zones: Array[Dictionary] = [
		{"pos": Vector2(300, 250), "name": "NORTH WEST"},
		{"pos": Vector2(3900, 250), "name": "NORTH EAST"},
		{"pos": Vector2(300, 2400), "name": "SOUTH WEST"},
		{"pos": Vector2(3900, 2400), "name": "SOUTH EAST"},
		{"pos": Vector2(2100, 1325), "name": "CENTER"},
	]
	var best: String = "CENTER"
	var best_dist: float = INF
	for z in zones:
		var d: float = pos.distance_squared_to(z.pos)
		if d < best_dist:
			best_dist = d
			best = z.name
	return best
