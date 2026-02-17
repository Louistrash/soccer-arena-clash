extends Area2D
## Neon laser projectile. Drawn via _draw(), no sprite needed.

const HIT_SPARK_SCENE := preload("res://actors/HitSpark.tscn")

var direction: Vector2 = Vector2.RIGHT
var source_group: String = "hero"
@export var speed: float = 600.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if sprite:
		sprite.visible = false
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction.normalized() * speed * delta
	rotation = direction.angle()
	queue_redraw()
	if position.x < -100 or position.x > 4400 or position.y < -100 or position.y > 2800:
		queue_free()

func _draw() -> void:
	var core_color: Color
	var glow_color: Color
	if source_group == "hero":
		core_color = Color(0.0, 1.0, 0.53, 1.0)
		glow_color = Color(0.0, 1.0, 0.53, 0.25)
	else:
		core_color = Color(1.0, 0.2, 0.4, 1.0)
		glow_color = Color(1.0, 0.2, 0.4, 0.25)

	# Outer glow
	draw_rect(Rect2(-10, -7, 50, 14), glow_color)
	# Inner core
	draw_rect(Rect2(-6, -3, 42, 6), core_color)
	# Bright tip
	draw_circle(Vector2(36, 0), 4.0, Color(1, 1, 1, 0.8))

func _on_body_entered(body: Node2D) -> void:
	if body is StaticBody2D:
		queue_free()
	elif body is CharacterBody2D:
		# Don't damage same team
		var body_team: String = body.get("team") if "team" in body else ("player" if body.is_in_group("hero") else "opponent")
		var shooter_team: String = "player" if source_group == "hero" else "opponent"
		if body_team == shooter_team:
			return
		_spawn_hit_spark()
		if body.has_method("take_damage"):
			var kb: Vector2 = direction.normalized()
			body.take_damage(15.0, kb)
		queue_free()

func _spawn_hit_spark() -> void:
	var spark: Node2D = HIT_SPARK_SCENE.instantiate() as Node2D
	if spark:
		spark.global_position = global_position
		var arena: Node2D = get_parent().get_parent().get_parent() as Node2D
		if arena:
			arena.add_child(spark)
		else:
			get_tree().current_scene.add_child(spark)
