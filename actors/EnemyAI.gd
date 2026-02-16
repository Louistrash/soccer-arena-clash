extends Node
## Brawl-style AI: state machine with IDLE, CHASE, ATTACK, RETREAT.
## Targets nearest opponent.

enum State { IDLE, CHASE, ATTACK, RETREAT }

const SPEED: float = 140.0
const CHASE_RANGE: float = 300.0
const ATTACK_RANGE: float = 120.0
const RETREAT_HP_RATIO: float = 0.25
const SHOOT_COOLDOWN_MIN: float = 0.8
const SHOOT_COOLDOWN_MAX: float = 1.5
const ATTACK_PAUSE: float = 0.2

var state: State = State.IDLE
var _shoot_cooldown: float = 0.0
var _attack_pause_timer: float = 0.0
var _wander_dir: Vector2 = Vector2.ZERO
var _wander_timer: float = 0.0

func _process(delta: float) -> void:
	var enemy: CharacterBody2D = get_parent() as CharacterBody2D
	if not enemy or enemy.is_dead:
		return

	_shoot_cooldown -= delta
	_attack_pause_timer -= delta

	var target: Node2D = _find_best_target(enemy)

	# State selection
	_select_state(enemy, target)

	# Execute state
	match state:
		State.IDLE:
			_do_idle(enemy, delta)
		State.CHASE:
			if target:
				_move_toward(enemy, target.global_position)
		State.ATTACK:
			if target:
				if _attack_pause_timer > 0:
					enemy.velocity = Vector2.ZERO
				else:
					_move_toward(enemy, target.global_position)
				_try_shoot(enemy, target.global_position)
		State.RETREAT:
			if target:
				var away: Vector2 = (enemy.global_position - target.global_position).normalized()
				_move_toward(enemy, enemy.global_position + away * 200)
			else:
				_do_idle(enemy, delta)

func _select_state(enemy: CharacterBody2D, target: Node2D) -> void:
	var hp_ratio: float = enemy.health / enemy.max_health if enemy.max_health > 0 else 1.0

	if hp_ratio < RETREAT_HP_RATIO:
		state = State.RETREAT
		return

	if not target:
		state = State.IDLE
		return

	var dist: float = enemy.global_position.distance_to(target.global_position)
	if dist < ATTACK_RANGE:
		state = State.ATTACK
	elif dist < CHASE_RANGE:
		state = State.CHASE
	else:
		state = State.IDLE

func _find_best_target(enemy: CharacterBody2D) -> Node2D:
	var best: Node2D = null
	var best_dist: float = 99999.0

	# Check heroes
	var heroes: Array = get_tree().get_nodes_in_group("hero")
	for h in heroes:
		if not is_instance_valid(h) or h == enemy:
			continue
		if "is_dead" in h and h.is_dead:
			continue
		var dist: float = enemy.global_position.distance_to(h.global_position)
		if dist < best_dist:
			best = h
			best_dist = dist

	# Check other enemies
	var enemies: Array = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		if not is_instance_valid(e) or e == enemy:
			continue
		if "is_dead" in e and e.is_dead:
			continue
		var dist: float = enemy.global_position.distance_to(e.global_position)
		if dist < best_dist:
			best = e
			best_dist = dist

	return best

func _do_idle(enemy: CharacterBody2D, delta: float) -> void:
	_wander_timer -= delta
	if _wander_timer <= 0:
		_wander_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		_wander_timer = randf_range(1.0, 3.0)
	enemy.velocity = _wander_dir * SPEED * 0.4

func _move_toward(enemy: CharacterBody2D, target: Vector2) -> void:
	var dir: Vector2 = (target - enemy.global_position).normalized()
	dir += Vector2(randf_range(-0.15, 0.15), randf_range(-0.15, 0.15))
	dir += _separation_vector(enemy)
	dir = dir.normalized()
	enemy.velocity = dir * SPEED

func _separation_vector(enemy: CharacterBody2D) -> Vector2:
	var sep := Vector2.ZERO
	var container: Node = enemy.get_parent()
	if not container:
		return sep
	for c in container.get_children():
		if c == enemy or not c is CharacterBody2D:
			continue
		if "is_dead" in c and c.is_dead:
			continue
		var diff: Vector2 = enemy.global_position - c.global_position
		var dist: float = diff.length()
		if dist < 80 and dist > 1:
			sep += diff.normalized() * (80 - dist) / 80.0
	return sep * 0.6

func _try_shoot(enemy: CharacterBody2D, target_pos: Vector2) -> void:
	if _shoot_cooldown > 0:
		return
	var dir: Vector2 = (target_pos - enemy.global_position).normalized()
	var proj_scene: PackedScene = preload("res://actors/Projectile.tscn")
	var proj: Area2D = proj_scene.instantiate() as Area2D
	if proj:
		proj.direction = dir
		proj.source_group = "enemy"
		proj.global_position = enemy.global_position + dir * 40
		var container: Node = enemy.get_parent().get_node_or_null("ProjectileManager")
		if container:
			container.add_child(proj)
		else:
			enemy.get_parent().add_child(proj)
		_shoot_cooldown = randf_range(SHOOT_COOLDOWN_MIN, SHOOT_COOLDOWN_MAX)
		_attack_pause_timer = ATTACK_PAUSE
