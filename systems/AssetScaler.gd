extends Node
## Centralized sprite scaling based on target pixel size.
## Autoload: AssetScaler
##
## All asset sizes:
##   Heroes: 1024x1024 PNG
##   Obstacles: ~2000x2000 PNG
##   Pickups: ~2000x2000 PNG
##   Grass background: 2000x2000 PNG

const HERO_TARGET_PX := 90.0
const OBSTACLE_TARGET_PX := 80.0
const PICKUP_TARGET_PX := 56.0
const PROJECTILE_TARGET_PX := 30.0
const BACKGROUND_TARGET_PX := 1280.0  # fill viewport width

static func apply(sprite: Sprite2D, target_px: float) -> void:
	if sprite.texture:
		var tex_size := float(sprite.texture.get_width())
		if tex_size > 0.0:
			sprite.scale = Vector2.ONE * (target_px / tex_size)
