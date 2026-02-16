extends CanvasLayer
## Debug overlay: enemy count, last spawn. Toggle with F3.

@onready var label: Label = $Label

var spawner: Node
var _visible: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Always update even when paused

func setup(p_spawner: Node) -> void:
	spawner = p_spawner
	if spawner and spawner.has_signal("enemy_spawned"):
		spawner.enemy_spawned.connect(_on_enemy_spawned)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_toggle"):
		_visible = not _visible
		if label:
			label.visible = _visible

func _process(_delta: float) -> void:
	if not label:
		return
	if spawner and spawner.has_method("get_enemies_alive_count") and spawner.has_method("get_last_spawn_pos"):
		var count: int = spawner.get_enemies_alive_count()
		var pos: Vector2 = spawner.get_last_spawn_pos()
		label.text = "Enemies alive: %d | Last spawn: (%.0f, %.0f)" % [count, pos.x, pos.y]
	else:
		label.text = "Enemies alive: -- | Last spawn: (--, --)"

func _on_enemy_spawned(_enemy: Node, _pos: Vector2) -> void:
	# Console print already in EnemySpawner
	pass
