extends CharacterBody2D
## Soccer ball projectile: bounce + explode. Striker mechanic.

const EXPLOSION_DAMAGE: float = 12.0
const EXPLOSION_KNOCKBACK: float = 220.0
const EXPLOSION_RADIUS: float = 80.0
const BOUNCE_RETENTION: float = 0.8
const MAX_BOUNCES: int = 2
const LIFETIME: float = 2.5
const SPIN_SPEED: float = 8.0
const EXPLOSION_RING_SCENE := preload("res://projectiles/ExplosionRing.tscn")

var direction: Vector2 = Vector2.RIGHT
var source_group: String = "hero"
var speed: float = 550.0

var _bounce_count: int = 0
var _exploded: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var despawn_timer: Timer = $DespawnTimer

func _ready() -> void:
	add_to_group("soccer_ball")
	collision_layer = 4
	collision_mask = 3
	velocity = direction.normalized() * speed

	var tex: Texture2D = load("res://projectiles/soccer_ball.png") as Texture2D
	if tex and sprite:
		sprite.texture = tex
		sprite.scale = Vector2(0.14, 0.14)
	else:
		sprite.visible = false

	if source_group == "enemy":
		modulate = Color(1.2, 0.8, 0.8)

	despawn_timer.wait_time = LIFETIME
	despawn_timer.timeout.connect(_on_lifetime_expired)
	despawn_timer.start()

func _physics_process(delta: float) -> void:
	if _exploded:
		return
	rotation += delta * SPIN_SPEED
	move_and_slide()
	queue_redraw()

	var col: KinematicCollision2D = get_last_slide_collision()
	if col:
		var body: Node2D = col.get_collider() as Node2D
		if body is StaticBody2D:
			_bounce(col.get_normal())
			if body.has_method("take_damage"):
				var hit_dir: Vector2 = col.get_normal()
				body.take_damage(2.0, -hit_dir, 0.0)
		elif body is CharacterBody2D:
			if _should_hit(body):
				_explode()
	if global_position.x < -100 or global_position.x > 4400 or global_position.y < -100 or global_position.y > 2800:
		_explode()

func _draw() -> void:
	# Shadow (ellipse onder de bal)
	draw_set_transform(Vector2(0, 8), 0, Vector2(1.2, 0.4))
	draw_circle(Vector2.ZERO, 14.0, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	if sprite.visible:
		return
	# Fallback: classic FIFA-style black/white pentagon pattern
	var r: float = 12.0
	draw_circle(Vector2.ZERO, r, Color(0.98, 0.98, 0.96))
	# Black pentagon-style arcs (5 segments around center)
	for i in 5:
		var a: float = i * TAU / 5.0
		draw_arc(Vector2.ZERO, r * 0.85, a, a + TAU / 5.0 - 0.1, 8, Color(0.12, 0.12, 0.12), 2.2)
	# Central hexagon band
	draw_arc(Vector2.ZERO, r * 0.55, 0, TAU, 6, Color(0.12, 0.12, 0.12), 1.8)

func _should_hit(body: Node2D) -> bool:
	# Same team never damages each other (hero + teammates vs opponents)
	var body_team: String = body.get("team") if "team" in body else ("player" if body.is_in_group("hero") else "opponent")
	var shooter_team: String = "player" if source_group == "hero" else "opponent"
	if body_team == shooter_team:
		return false
	return true

func _bounce(normal: Vector2) -> void:
	velocity = velocity.bounce(normal) * BOUNCE_RETENTION
	_bounce_count += 1
	if _bounce_count >= MAX_BOUNCES:
		_explode()

func _on_lifetime_expired() -> void:
	if not _exploded:
		_explode()

func _explode() -> void:
	if _exploded:
		return
	_exploded = true

	_spawn_impact_burst()
	_apply_explosion_damage()
	_clean_dirty_zones()
	_screen_shake()
	queue_free()

func _spawn_impact_burst() -> void:
	var burst: Node2D = EXPLOSION_RING_SCENE.instantiate() as Node2D
	if not burst:
		return
	var parent: Node2D = get_parent().get_parent().get_parent() as Node2D
	if not parent:
		parent = get_tree().current_scene as Node2D
	if parent:
		parent.add_child(burst)
		burst.global_position = global_position

func _apply_explosion_damage() -> void:
	var center: Vector2 = global_position
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	var circle: CircleShape2D = CircleShape2D.new()
	circle.radius = EXPLOSION_RADIUS
	query.shape = circle
	query.transform = Transform2D(0, center)
	var results: Array = space.intersect_shape(query, 32)
	for result in results:
		var body: Node2D = result.collider as Node2D
		if body and body.has_method("take_damage"):
			if body.is_in_group("maze_wall"):
				var diff: Vector2 = (body.global_position - center).normalized()
				body.take_damage(1.0, diff, 0.0)
				continue
			var body_team: String = body.get("team") if "team" in body else ("player" if body.is_in_group("hero") else "opponent")
			var shooter_team: String = "player" if source_group == "hero" else "opponent"
			if body_team == shooter_team:
				continue
			var diff: Vector2 = (body.global_position - center).normalized()
			body.take_damage(EXPLOSION_DAMAGE, diff, EXPLOSION_KNOCKBACK)

func _clean_dirty_zones() -> void:
	var zones: Array = get_tree().get_nodes_in_group("dirty_zone")
	for z in zones:
		if not is_instance_valid(z):
			continue
		if z.has_method("clean"):
			var dist: float = global_position.distance_to(z.global_position)
			if dist < EXPLOSION_RADIUS:
				z.clean(25)

func _screen_shake() -> void:
	var cam: Node = get_tree().get_first_node_in_group("game_camera")
	if cam and cam.has_method("add_trauma"):
		cam.add_trauma(0.18)
		if cam.has_method("zoom_combat"):
			cam.zoom_combat()
	var scoreboard: Node = get_tree().get_first_node_in_group("glass_scoreboard")
	if scoreboard and scoreboard.has_method("trigger_explosion_pulse"):
		scoreboard.trigger_explosion_pulse()
