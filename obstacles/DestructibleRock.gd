extends StaticBody2D
## Cracked rock obstacle that breaks when hit by soccer ball explosion.

const ROCK_CRACKED_PATH: String = "res://obstacles/rock_cracked.png"
const FALLBACK_TEXTURE: String = "res://obstacles/stone_wall.png"
const TARGET_SIZE_PX: float = 200.0
const SOURCE_SIZE_PX: float = 1024.0

var health: float = 30.0
var max_health: float = 30.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("destructible")
	_setup_sprite()

func _setup_sprite() -> void:
	if not sprite:
		return
	var tex: Texture2D = load(ROCK_CRACKED_PATH) as Texture2D
	if tex:
		sprite.texture = tex
		var scale_val: float = TARGET_SIZE_PX / SOURCE_SIZE_PX
		sprite.scale = Vector2(scale_val, scale_val)
	else:
		sprite.texture = load(FALLBACK_TEXTURE) as Texture2D
		sprite.scale = Vector2(0.02, 0.02)
		push_warning("DestructibleRock: missing %s, using fallback" % ROCK_CRACKED_PATH)

func take_damage(_amount: float, _knockback_dir: Vector2 = Vector2.ZERO, _knockback_strength: float = 0.0) -> void:
	health -= _amount
	if health <= 0:
		_break()

func _break() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.12)
	tween.tween_property(self, "scale", Vector2(0.3, 0.3), 0.12).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)
