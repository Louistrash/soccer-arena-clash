extends Node
## Brawl-style AI: state machine with IDLE, CHASE, ATTACK, RETREAT.
## Targets nearest opponent (opposite team only). Role-based formation.

enum State { IDLE, CHASE, ATTACK, RETREAT }
enum Role { DEFENDER, MIDFIELDER, STRIKER }

const SPEED: float = 140.0
const CHASE_RANGE: float = 300.0
const ATTACK_RANGE: float = 100.0
const CHASE_RANGE_DEFENDER: float = 180.0
const CHASE_RANGE_STRIKER: float = 380.0
const HOME_POSITION_WEIGHT: float = 0.35
const RETREAT_HP_RATIO: float = 0.25
const SHOOT_COOLDOWN_MIN: float = 0.8
const SHOOT_COOLDOWN_MAX: float = 1.5
const ATTACK_PAUSE: float = 0.2

var state: State = State.IDLE
var _shoot_cooldown: float = 0.0
var _attack_pause_timer: float = 0.0
var _wander_dir: Vector2 = Vector2.ZERO
var _wander_timer: float = 0.0
var _home_position: Vector2 = Vector2.ZERO
var _chase_range: float = CHASE_RANGE

func _process(delta: float) -> void:
	var enemy: CharacterBody2D = get_parent() as CharacterBody2D
	if not enemy or enemy.is_dead:
		return
	if _home_position == Vector2.ZERO:
		_home_position = enemy.global_position
		# Role-based chase range
		var r: int = enemy.get("role") if "role" in enemy else Role.MIDFIELDER
		if r == Role.DEFENDER:
			_chase_range = CHASE_RANGE_DEFENDER
		elif r == Role.STRIKER:
			_chase_range = CHASE_RANGE_STRIKER
		else:
			_chase_range = CHASE_RANGE

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
	if dist < 35:
		state = State.RETREAT
	elif dist < ATTACK_RANGE:
		state = State.ATTACK
	elif dist < _chase_range:
		state = State.CHASE
	else:
		state = State.IDLE

func _find_best_target(enemy: CharacterBody2D) -> Node2D:
	var best: Node2D = null
	var best_dist: float = 99999.0
	var my_team: String = enemy.get("team") if "team" in enemy else "opponent"

	# Target opposite team only (hero + teammates vs opponents)
	var candidates: Array[Node2D] = []
	candidates.append_array(get_tree().get_nodes_in_group("hero"))
	candidates.append_array(get_tree().get_nodes_in_group("enemy"))
	for c in candidates:
		if not is_instance_valid(c) or c == enemy:
			continue
		if "is_dead" in c and c.is_dead:
			continue
		var c_team: String = c.get("team") if "team" in c else ("player" if c.is_in_group("hero") else "opponent")
		if c_team == my_team:
			continue
		var dist: float = enemy.global_position.distance_to(c.global_position)
		if dist < best_dist:
			best = c
			best_dist = dist
	return best

func _do_idle(enemy: CharacterBody2D, delta: float) -> void:
	_wander_timer -= delta
	if _wander_timer <= 0:
		_wander_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		_wander_timer = randf_range(1.0, 3.0)
	var dir: Vector2 = _wander_dir
	if _home_position != Vector2.ZERO:
		var to_home: Vector2 = (_home_position - enemy.global_position).normalized()
		dir = (dir + to_home * HOME_POSITION_WEIGHT).normalized()
	enemy.velocity = dir * SPEED * 0.4

func _move_toward(enemy: CharacterBody2D, target: Vector2) -> void:
	var dir: Vector2 = (target - enemy.global_position).normalized()
	dir += Vector2(randf_range(-0.15, 0.15), randf_range(-0.15, 0.15))
	dir += _separation_vector(enemy)
	dir = dir.normalized()
	enemy.velocity = dir * SPEED

func _separation_vector(enemy: CharacterBody2D) -> Vector2:
	var sep := Vector2.ZERO
	# Push away from all nearby characters (enemies + hero)
	var chars: Array = get_tree().get_nodes_in_group("hero") + get_tree().get_nodes_in_group("enemy")
	for c in chars:
		if not is_instance_valid(c) or c == enemy:
			continue
		if "is_dead" in c and c.is_dead:
			continue
		var diff: Vector2 = enemy.global_position - c.global_position
		var dist: float = diff.length()
		if dist < 100 and dist > 2:
			var strength: float = (100 - dist) / 100.0
			sep += diff.normalized() * strength
	return sep * 1.2

func _try_shoot(enemy: CharacterBody2D, target_pos: Vector2) -> void:
	if _shoot_cooldown > 0:
		return
	var dir: Vector2 = (target_pos - enemy.global_position).normalized()
	var container: Node = enemy.get_parent().get_node_or_null("ProjectileManager")
	if not container:
		container = enemy.get_parent()
	var my_team: String = enemy.get("team") if "team" in enemy else "opponent"
	if my_team == "player":
		# Teammates use soccer balls like Hero
		var balls: Array = get_tree().get_nodes_in_group("soccer_ball")
		var hero_balls: int = 0
		for b in balls:
			if is_instance_valid(b) and "source_group" in b and b.source_group == "hero":
				hero_balls += 1
		if hero_balls < 8:
			var proj: CharacterBody2D = preload("res://projectiles/SoccerBallProjectile.tscn").instantiate() as CharacterBody2D
			if proj:
				proj.direction = dir
				proj.source_group = "hero"
				proj.global_position = enemy.global_position + dir * 40
				container.add_child(proj)
				var scoreboard: Node = get_tree().get_first_node_in_group("glass_scoreboard")
				if scoreboard and scoreboard.has_method("trigger_ball_spin"):
					scoreboard.trigger_ball_spin()
	else:
		# Opponents use laser
		var proj: Area2D = preload("res://actors/Projectile.tscn").instantiate() as Area2D
		if proj:
			proj.direction = dir
			proj.source_group = "enemy"
			proj.global_position = enemy.global_position + dir * 40
			container.add_child(proj)
	_shoot_cooldown = randf_range(SHOOT_COOLDOWN_MIN, SHOOT_COOLDOWN_MAX)
	_attack_pause_timer = ATTACK_PAUSE
