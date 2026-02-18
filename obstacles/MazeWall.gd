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
			rect.size = Vector2(64, 64)
		WallSize.SIZE_1x2:
			rect.size = Vector2(64, 128)
		WallSize.SIZE_2x2:
			rect.size = Vector2(128, 128)
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
	var scale_x: float = 64.0 / SOURCE_SIZE_PX
	var scale_y: float = 64.0 / SOURCE_SIZE_PX
	match wall_size:
		WallSize.SIZE_2x2:
			scale_x = 128.0 / SOURCE_SIZE_PX
			scale_y = 128.0 / SOURCE_SIZE_PX
		WallSize.SIZE_1x2:
			scale_x = 64.0 / SOURCE_SIZE_PX
			scale_y = 128.0 / SOURCE_SIZE_PX
	sprite.scale = Vector2(scale_x, scale_y)

func take_damage(_amount: float, _knockback_dir: Vector2 = Vector2.ZERO, _knockback_strength: float = 0.0) -> void:
	if wall_type != "cracked":
		return
	health -= _amount
	if health <= 0:
		_break()

func _break() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.12)
	tween.tween_property(self, "scale", Vector2(0.3, 0.3), 0.12).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)
