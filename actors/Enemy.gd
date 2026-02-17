extends CharacterBody2D
## Enemy: AI-controlled bot with death animation and auto-cleanup.

@onready var sprite: Sprite2D = $Sprite2D
@onready var name_label: Label = $UnitUI/NameLabel
@onready var health_bar_fill: ColorRect = $UnitUI/HealthBarFill

const ENEMY_LIST: Array[String] = [
	"razor", "bulwark", "vinewitch",
]

const SPEED: float = 120.0
const HEALTH_BAR_WIDTH: float = 50.0

var enemy_name: String = ""
var enemy_type: String = "razor"
var team: String = "opponent"
var role: int = 0  # EnemyAI.Role
var health: float = 100.0
var max_health: float = 100.0
var invulnerable: bool = false
var is_dead: bool = false
var _stagger_timer: float = 0.0

var projectile_container: Node

const KNOCKBACK_MULT: Dictionary = {
	"bulwark": 0.5,
	"vinewitch": 1.5,
	"razor": 1.0,
}

var _type_assigned: bool = false

func setup_type(id: String) -> void:
	if id in ENEMY_LIST:
		enemy_type = id
		_type_assigned = true

func setup_team(t: String) -> void:
	team = t

func setup_role(r: int) -> void:
	role = r

func setup_teammate_texture(hero_id: String) -> void:
	_type_assigned = true
	enemy_type = hero_id
	var path: String = "res://heroes/" + hero_id + ".png"
	set_enemy_texture(path)
	set_enemy_name(hero_id.capitalize())

func _ready() -> void:
	add_to_group("enemy")

	visible = true
	modulate.a = 1.0
	scale = Vector2.ONE
	z_index = 10

	if not _type_assigned:
		_pick_random_type()
	else:
		set_enemy_type_id(enemy_type)

	# Teammates: green tint. Opponents: red tint
	if team == "player":
		sprite.modulate = Color(0.75, 1.2, 0.75)
		if name_label:
			name_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
		var health_bar_bg: ColorRect = get_node_or_null("UnitUI/HealthBarBG") as ColorRect
		if health_bar_bg:
			health_bar_bg.color = Color(0.1, 0.3, 0.1, 0.8)
	else:
		sprite.modulate = Color(1.2, 0.75, 0.75)
		if name_label:
			name_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
		var health_bar_bg: ColorRect = get_node_or_null("UnitUI/HealthBarBG") as ColorRect
		if health_bar_bg:
			health_bar_bg.color = Color(0.3, 0.1, 0.1, 0.8)

	projectile_container = get_parent().get_node_or_null("ProjectileManager")
	if not projectile_container:
		projectile_container = get_parent()

func _pick_random_type() -> void:
	# Random enemy type (bias away from Razor for variety)
	var weights: Array[int] = [1, 2, 2]
	var total: int = 0
	for w in weights:
		total += w
	var r: int = randi() % total
	var idx: int = 0
	for i in weights.size():
		r -= weights[i]
		if r < 0:
			idx = i
			break
	var enemy_id: String = ENEMY_LIST[idx]
	set_enemy_type_id(enemy_id)

func set_enemy_type_id(id: String) -> void:
	if id not in ENEMY_LIST:
		id = "razor"
	enemy_type = id
	_type_assigned = true
	var path: String = "res://enemies/" + id + ".png"
	set_enemy_texture(path)
	set_enemy_name(id.capitalize())


func set_enemy_texture(path: String) -> void:
	if path.is_empty():
		return
	enemy_type = path.get_file().get_basename().to_lower()
	if enemy_type not in KNOCKBACK_MULT:
		enemy_type = "razor"
	var tex: Texture2D = load(path) as Texture2D
	if tex and sprite:
		sprite.texture = tex
		AssetScaler.apply(sprite, AssetScaler.HERO_TARGET_PX)
	else:
		var fallback: Texture2D = load("res://pickups/xpower.png") as Texture2D
		if fallback and sprite:
			sprite.texture = fallback
			AssetScaler.apply(sprite, AssetScaler.HERO_TARGET_PX)

func set_enemy_name(display_name: String) -> void:
	enemy_name = display_name
	if name_label:
		name_label.text = enemy_name

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	_stagger_timer -= delta
	if _stagger_timer > 0:
		velocity = Vector2.ZERO
		move_and_slide()
		_update_health_bar()
		return

	if invulnerable:
		modulate.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.02)
		move_and_slide()
		_update_health_bar()
		return

	if has_node("EnemyAI"):
		move_and_slide()
	else:
		_wander(delta)

	_update_health_bar()

func _wander(delta: float) -> void:
	if randf() < 0.02:
		velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * SPEED
	move_and_slide()

func take_damage(amount: float, knockback_dir: Vector2 = Vector2.ZERO, knockback_strength: float = 200.0) -> void:
	if invulnerable or is_dead:
		return
	health -= amount
	if health <= 0:
		health = 0
		_die()
	else:
		if knockback_dir.length_squared() > 0.01:
			var mult: float = KNOCKBACK_MULT.get(enemy_type, 1.0)
			velocity = knockback_dir.normalized() * knockback_strength * mult
			_stagger_timer = 0.25

func _die() -> void:
	is_dead = true
	collision_layer = 0
	collision_mask = 0
	# Death animation: shrink + fade
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_property(self, "scale", Vector2(0.3, 0.3), 0.4)
	tween.tween_property(self, "rotation", randf_range(-0.5, 0.5), 0.4)
	tween.chain().tween_callback(queue_free)

func _update_health_bar() -> void:
	if health_bar_fill:
		var ratio: float = clampf(health / max_health, 0.0, 1.0)
		health_bar_fill.offset_right = health_bar_fill.offset_left + HEALTH_BAR_WIDTH * ratio
		if ratio > 0.5:
			health_bar_fill.color = Color(0.85, 0.2, 0.2, 1.0)
		elif ratio > 0.25:
			health_bar_fill.color = Color(0.95, 0.5, 0.2, 1.0)
		else:
			health_bar_fill.color = Color(0.9, 0.15, 0.15, 1.0)
