extends CharacterBody2D
## Hero: movement + shooting. All input via InputRouter.
## Use set_hero_texture(path) to assign a hero sprite.

@onready var sprite: Sprite2D = $Sprite2D
@onready var name_label: Label = $UnitUI/NameLabel
@onready var health_bar_fill: ColorRect = $UnitUI/HealthBarFill
@onready var respawn_label: Label = $UnitUI/RespawnLabel

const SPEED: float = 200.0
const SOCCER_BALL_SCENE := preload("res://projectiles/SoccerBallProjectile.tscn")
const LASER_PROJECTILE_SCENE := preload("res://actors/Projectile.tscn")
const DUST_PUFF_SCENE := preload("res://actors/DustPuff.tscn")
const PROJECTILE_SPAWN_OFFSET: float = 40.0

const HEALTH_BAR_WIDTH: float = 50.0

var hero_name: String = ""
var health: float = 100.0
var max_health: float = 100.0
var invulnerable: bool = false
var is_dead: bool = false

var projectile_container: Node
var _dust_timer: float = 0.0
var _shoot_cooldown: float = 0.0
const SHOOT_COOLDOWN: float = 0.45
const MAX_ACTIVE_BALLS: int = 8

func _ready() -> void:
	add_to_group("hero")
	if name_label:
		name_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
	# Scale applied in set_hero_texture when texture is set
	if sprite.texture:
		AssetScaler.apply(sprite, AssetScaler.HERO_TARGET_PX)
	InputRouter.register_hero(self)
	projectile_container = get_parent().get_node_or_null("ProjectileManager")
	if not projectile_container:
		projectile_container = get_parent()

func set_hero_texture(path: String) -> void:
	if path.is_empty():
		return
	var tex: Texture2D = load(path) as Texture2D
	if tex and sprite:
		sprite.texture = tex
		AssetScaler.apply(sprite, AssetScaler.HERO_TARGET_PX)

func set_hero_name(hero_display_name: String) -> void:
	hero_name = hero_display_name
	if name_label:
		name_label.text = hero_name

func _physics_process(_delta: float) -> void:
	if is_dead:
		return

	if invulnerable:
		modulate.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.02)
		velocity = InputRouter.move_direction * SPEED
		move_and_slide()
		_update_health_bar()
		return

	velocity = InputRouter.move_direction * SPEED
	move_and_slide()

	if velocity.length() > 10:
		_dust_timer -= get_physics_process_delta_time()
		if _dust_timer <= 0:
			_dust_timer = 0.3
			_spawn_dust_puff()

	_shoot_cooldown -= get_physics_process_delta_time()
	var shoot_pressed: bool = InputRouter.shoot_just_pressed or Input.is_action_just_pressed("shoot")
	if shoot_pressed and _shoot_cooldown <= 0:
		_shoot(InputRouter.aim_direction)
		InputRouter.consume_shoot()

	queue_redraw()
	_update_health_bar()

func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO, _knockback_strength: float = 200.0) -> void:
	if invulnerable or is_dead:
		return
	var cam: Node = get_tree().get_first_node_in_group("game_camera")
	if cam and cam.has_method("add_trauma"):
		cam.add_trauma(0.22)
	health -= amount
	if health <= 0:
		health = 0
		_die()
	else:
		if knockback_dir.length_squared() > 0.01:
			velocity = knockback_dir.normalized() * _knockback_strength

func _die() -> void:
	is_dead = true
	collision_layer = 0
	collision_mask = 0
	sprite.visible = false
	if has_node("Shadow"):
		get_node("Shadow").visible = false
	if name_label:
		name_label.visible = false
	if health_bar_fill:
		health_bar_fill.get_parent().visible = false  # HealthBarBG
		health_bar_fill.visible = false
	if respawn_label:
		respawn_label.visible = true
	_respawn_timer()

func _respawn_timer() -> void:
	for i in range(3, 0, -1):
		if respawn_label:
			respawn_label.text = "Respawning in %d..." % i
		await get_tree().create_timer(1.0).timeout
	if respawn_label:
		respawn_label.visible = false
	_respawn()

func _respawn() -> void:
	is_dead = false
	collision_layer = 2
	collision_mask = 3
	sprite.visible = true
	if has_node("Shadow"):
		get_node("Shadow").visible = true
	if name_label:
		name_label.visible = true
	if health_bar_fill:
		health_bar_fill.get_parent().visible = true
		health_bar_fill.visible = true
	health = max_health
	invulnerable = true
	modulate.a = 1.0
	var spawn_point: Marker2D = get_parent().get_node_or_null("SpawnPoint") as Marker2D
	if spawn_point:
		global_position = spawn_point.global_position
	else:
		global_position = Vector2(2100, 1325)
	# 2s invulnerability
	await get_tree().create_timer(2.0).timeout
	invulnerable = false

func _shoot(direction: Vector2) -> void:
	if direction.length_squared() < 0.01:
		direction = Vector2.RIGHT

	if GameManager.selected_hero_id in ["player1", "lionel"]:
		# Striker: soccer balls
		var balls: Array = get_tree().get_nodes_in_group("soccer_ball")
		var hero_balls: int = 0
		for b in balls:
			if is_instance_valid(b) and "source_group" in b and b.source_group == "hero":
				hero_balls += 1
		if hero_balls >= MAX_ACTIVE_BALLS:
			return
		var projectile: CharacterBody2D = SOCCER_BALL_SCENE.instantiate() as CharacterBody2D
		if projectile:
			projectile.direction = direction
			projectile.source_group = "hero"
			projectile.global_position = global_position + direction * PROJECTILE_SPAWN_OFFSET
		projectile_container.add_child(projectile)
		_shoot_cooldown = SHOOT_COOLDOWN
		var scoreboard: Node = get_tree().get_first_node_in_group("glass_scoreboard")
		if scoreboard and scoreboard.has_method("trigger_ball_spin"):
			scoreboard.trigger_ball_spin()
	else:
		# Other heroes: laser
		var projectile: Area2D = LASER_PROJECTILE_SCENE.instantiate() as Area2D
		if projectile:
			projectile.direction = direction
			projectile.source_group = "hero"
			projectile.global_position = global_position + direction * PROJECTILE_SPAWN_OFFSET
			projectile_container.add_child(projectile)

func _spawn_dust_puff() -> void:
	var dust: Node2D = DUST_PUFF_SCENE.instantiate() as Node2D
	if dust:
		dust.global_position = global_position + Vector2(0, 25)
		var arena: Node2D = get_parent().get_parent() as Node2D
		if arena:
			arena.add_child(dust)

func _update_health_bar() -> void:
	if health_bar_fill:
		var ratio: float = clampf(health / max_health, 0.0, 1.0)
		health_bar_fill.offset_right = health_bar_fill.offset_left + HEALTH_BAR_WIDTH * ratio
		# Color: green > yellow > red
		if ratio > 0.5:
			health_bar_fill.color = Color(0.2, 0.85, 0.2, 1.0)
		elif ratio > 0.25:
			health_bar_fill.color = Color(0.9, 0.8, 0.1, 1.0)
		else:
			health_bar_fill.color = Color(0.9, 0.15, 0.15, 1.0)
