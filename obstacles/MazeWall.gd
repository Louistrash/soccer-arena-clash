extends StaticBody2D
## Maze wall obstacle: indestructible (ruin, moss) of destructible (cracked).
## Configurable texture and collision size for esports maze layout.

const TEXTURE_PATHS: Dictionary = {
	"ruin": "res://obstacles/rock_ruin.png",
	"moss": "res://obstacles/rock_moss.png",
	"cracked": "res://obstacles/rock_cracked.png",
}
const FALLBACK_TEXTURE: String = "res://obstacles/stone_wall.png"
const SOURCE_SIZE_PX: float = 1024.0

enum WallSize { SIZE_1x1, SIZE_1x2, SIZE_2x2 }

var wall_type: String = "ruin"
var wall_size: WallSize = WallSize.SIZE_2x2
var health: float = 30.0
var max_health: float = 30.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("maze_wall")
	_setup_collision()
	_setup_sprite()

func setup(p_type: String, p_size_id: int) -> void:
	wall_type = p_type
	match p_size_id:
		0: wall_size = WallSize.SIZE_1x1
		1: wall_size = WallSize.SIZE_1x2
		_: wall_size = WallSize.SIZE_2x2
	if wall_type == "cracked":
		add_to_group("destructible")

func _setup_collision() -> void:
	if not collision_shape:
		return
	var rect: RectangleShape2D = RectangleShape2D.new()
	match wall_size:
		WallSize.SIZE_1x1:
			rect.size = Vector2(128, 128)
		WallSize.SIZE_1x2:
			rect.size = Vector2(128, 256)
		WallSize.SIZE_2x2:
			rect.size = Vector2(256, 256)
	collision_shape.shape = rect

func _setup_sprite() -> void:
	if not sprite:
		return
	var path: String = TEXTURE_PATHS.get(wall_type, TEXTURE_PATHS["ruin"])
	var tex: Texture2D = load(path) as Texture2D
	if tex:
		sprite.texture = tex
	else:
		sprite.texture = load(FALLBACK_TEXTURE) as Texture2D
	var scale_x: float = 128.0 / SOURCE_SIZE_PX
	var scale_y: float = 128.0 / SOURCE_SIZE_PX
	match wall_size:
		WallSize.SIZE_2x2:
			scale_x = 256.0 / SOURCE_SIZE_PX
			scale_y = 256.0 / SOURCE_SIZE_PX
		WallSize.SIZE_1x2:
			scale_x = 128.0 / SOURCE_SIZE_PX
			scale_y = 256.0 / SOURCE_SIZE_PX
	sprite.scale = Vector2(scale_x, scale_y)

func take_damage(_amount: float, _knockback_dir: Vector2 = Vector2.ZERO, _knockback_strength: float = 0.0) -> void:
	_hit_flash()
	_spawn_debris(_knockback_dir)
	if wall_type != "cracked":
		return
	health -= _amount
	if health <= 0:
		_break()

func _hit_flash() -> void:
	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate", Color(2.5, 2.5, 2.5, 1.0), 0.04)
	tw.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.08)

func _spawn_debris(hit_dir: Vector2) -> void:
	var base_dir: Vector2 = hit_dir.normalized() if hit_dir.length_squared() > 0.01 else Vector2.UP
	var count: int = randi_range(3, 5)
	for i in count:
		var p: DebrisParticle = DebrisParticle.new()
		p.position = Vector2.ZERO
		var angle_spread: float = randf_range(-0.8, 0.8)
		p.velocity = base_dir.rotated(angle_spread) * randf_range(80.0, 160.0)
		p.wall_color = _get_debris_color()
		add_child(p)

func _get_debris_color() -> Color:
	match wall_type:
		"ruin":
			return Color(0.55, 0.45, 0.35).lerp(Color(0.4, 0.33, 0.25), randf())
		"moss":
			return Color(0.45, 0.55, 0.35).lerp(Color(0.35, 0.45, 0.25), randf())
		"cracked":
			return Color(0.6, 0.5, 0.4).lerp(Color(0.5, 0.4, 0.3), randf())
	return Color(0.5, 0.45, 0.4)

func _break() -> void:
	_spawn_debris(Vector2.UP)
	_spawn_debris(Vector2.RIGHT)
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_property(self, "scale", Vector2(0.3, 0.3), 0.15).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)


class DebrisParticle extends Node2D:
	var velocity: Vector2 = Vector2.ZERO
	var wall_color: Color = Color(0.5, 0.45, 0.4)
	var _life: float = 0.0
	var _max_life: float = 0.35
	var _size: float = 3.0
	var _gravity: float = 220.0

	func _ready() -> void:
		_size = randf_range(2.0, 5.0)
		z_index = 10

	func _process(delta: float) -> void:
		_life += delta
		if _life >= _max_life:
			queue_free()
			return
		velocity.y += _gravity * delta
		position += velocity * delta
		queue_redraw()

	func _draw() -> void:
		var alpha: float = 1.0 - (_life / _max_life)
		var c: Color = wall_color
		c.a = alpha
		draw_rect(Rect2(-_size * 0.5, -_size * 0.5, _size, _size), c)
