extends Node
## Esports-balanced maze layout: symmetrische obstacles voor 3-lane gameplay.
## Side lane walls (ruin), midfield chokes (cracked), corner cover (moss).

const MAZE_WALL_SCENE := preload("res://obstacles/MazeWall.tscn")
const TILE_SIZE: int = 64
const FIELD_CX: float = 2100.0
const FIELD_CY: float = 1325.0

## Wall data: [position, type, size]
## type: "ruin" | "moss" | "cracked" | "vines" | "cleanable"
## size: 0=SIZE_1x1, 1=SIZE_1x2, 2=SIZE_2x2
## 60% permanent (ruin, moss), 40% destructible (cracked, vines, cleanable)
const WALL_DATA: Array = [
	# Side lane walls (rock_ruin 2x2) - permanent
	[Vector2(832, 704), "ruin", 2],
	[Vector2(832, 1920), "ruin", 2],
	[Vector2(1280, 1024), "ruin", 2],
	[Vector2(1280, 1664), "ruin", 2],
	[Vector2(700, 1100), "ruin", 2],
	[Vector2(700, 1550), "ruin", 2],
	[Vector2(1500, 800), "ruin", 2],
	[Vector2(1500, 1850), "ruin", 2],
	# Soft cover corners (rock_moss 1x2) - permanent
	[Vector2(512, 512), "moss", 1],
	[Vector2(512, 2176), "moss", 1],
	[Vector2(400, 900), "moss", 1],
	[Vector2(400, 1750), "moss", 1],
	[Vector2(600, 1325), "moss", 1],
	# Midfield chokes (rock_cracked 1x1) - destructible
	[Vector2(1792, 1088), "cracked", 0],
	[Vector2(1792, 1536), "cracked", 0],
	[Vector2(1900, 1325), "cracked", 0],
	# Organic maze walls (rock_vines 1x2) - destructible
	[Vector2(1650, 960), "vines", 1],
	[Vector2(1650, 1690), "vines", 1],
	[Vector2(1550, 1325), "vines", 1],
	# Light breakable stones (rock_cleanable 1x1) - destructible
	[Vector2(1400, 1200), "cleanable", 0],
	[Vector2(1400, 1450), "cleanable", 0],
]

func spawn_maze(arena: Node2D) -> void:
	var container: Node2D = arena.get_node_or_null("YSort") as Node2D
	if not container:
		container = arena
	for entry in WALL_DATA:
		var pos: Vector2 = entry[0]
		var wall_type: String = entry[1]
		var size_id: int = entry[2]
		_spawn_wall(container, pos, wall_type, size_id)
		_spawn_wall(container, _mirror_x(pos), wall_type, size_id)

func _spawn_wall(container: Node2D, pos: Vector2, wall_type: String, size_id: int) -> void:
	var wall: StaticBody2D = MAZE_WALL_SCENE.instantiate() as StaticBody2D
	if not wall:
		return
	wall.global_position = _snap_to_grid(pos)
	wall.setup(wall_type, size_id)
	container.add_child(wall)

func _mirror_x(pos: Vector2) -> Vector2:
	var dx: float = pos.x - FIELD_CX
	return Vector2(FIELD_CX - dx, pos.y)

func _snap_to_grid(pos: Vector2) -> Vector2:
	var sx: int = int(round(pos.x / float(TILE_SIZE))) * TILE_SIZE
	var sy: int = int(round(pos.y / float(TILE_SIZE))) * TILE_SIZE
	return Vector2(sx, sy)
