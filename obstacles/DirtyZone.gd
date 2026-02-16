extends Area2D
## Dirty zone: overgrown rock, reduced by soccer ball explosion (Reverse Spray).

const ROCK_VARIANTS: Array[String] = [
	"rock_moss", "rock_vines", "rock_flower", "rock_ruin", "rock_cleanable",
]
const FALLBACK_TEXTURE: String = "res://obstacles/stone_wall.png"
const TARGET_SIZE_PX: float = 480.0
const SOURCE_SIZE_PX: float = 1024.0

var corruption_value: float = 100.0
const BASE_CORRUPTION: float = 100.0

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("dirty_zone")
	_setup_sprite()

func _setup_sprite() -> void:
	if not sprite:
		return
	var variant: String = ROCK_VARIANTS[randi() % ROCK_VARIANTS.size()]
	var path: String = "res://obstacles/%s.png" % variant
	var tex: Texture2D = load(path) as Texture2D
	if tex:
		sprite.texture = tex
	else:
		sprite.texture = load(FALLBACK_TEXTURE) as Texture2D
		push_warning("DirtyZone: missing %s, using fallback" % path)
	var scale_val: float = TARGET_SIZE_PX / SOURCE_SIZE_PX
	sprite.scale = Vector2(scale_val, scale_val)
	_update_clean_visual()

func clean(amount: float) -> void:
	corruption_value -= amount
	if corruption_value <= 0:
		corruption_value = 0
		_fade_out()
	else:
		_update_clean_visual()

func _update_clean_visual() -> void:
	if sprite:
		var t: float = clampf(corruption_value / BASE_CORRUPTION, 0.0, 1.0)
		sprite.modulate = Color(1.0, 1.0, 1.0).lerp(Color(0.85, 0.95, 0.85), t)

func _fade_out() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	tween.tween_callback(queue_free)
