extends CharacterBody2D
## Ball: FREE, CARRIED, or THROWN. Pickup via Area2D overlap.

enum State { FREE, CARRIED, THROWN }

@onready var pickup_area: Area2D = $PickupArea

const BALL_RADIUS: float = 20.0
const THROW_SPEED: float = 600.0
const FRICTION: float = 0.98
const WALL_BOUNCE: float = 0.6
const CARRY_OFFSET: Vector2 = Vector2(0, -30)

var state: State = State.FREE
var carrier: Node2D
var throw_direction: Vector2 = Vector2.RIGHT

const ARENA_MIN := Vector2(-360, -640)
const ARENA_MAX := Vector2(1640, 1360)

func _ready() -> void:
	add_to_group("ball")
	pickup_area.body_entered.connect(_on_pickup_body_entered)
	queue_redraw()

func _physics_process(_delta: float) -> void:
	queue_redraw()
	match state:
		State.FREE:
			velocity *= FRICTION
			if velocity.length() < 5.0:
				velocity = Vector2.ZERO
			move_and_slide()
			_bounce_off_walls()
			_clamp_to_arena()
		State.CARRIED:
			if carrier and is_instance_valid(carrier):
				global_position = carrier.global_position + carrier.transform.x * CARRY_OFFSET.x + carrier.transform.y * CARRY_OFFSET.y
			else:
				_drop()
		State.THROWN:
			velocity *= FRICTION
			move_and_slide()
			_bounce_off_walls()
			_clamp_to_arena()
			if velocity.length() < 20.0:
				state = State.FREE
				velocity = Vector2.ZERO

func _draw() -> void:
	draw_circle(Vector2.ZERO, BALL_RADIUS, Color(1.0, 1.0, 0.85))
	draw_arc(Vector2.ZERO, BALL_RADIUS, 0, TAU, 32, Color(0.9, 0.9, 0.6), 2.0)

func _on_pickup_body_entered(body: Node2D) -> void:
	if state != State.FREE:
		return
	if body.has_method("pick_up_ball"):
		body.pick_up_ball(self)

func carry(by: Node2D) -> void:
	state = State.CARRIED
	carrier = by
	velocity = Vector2.ZERO

func throw(direction: Vector2) -> void:
	if state != State.CARRIED:
		return
	state = State.THROWN
	carrier = null
	if direction.length_squared() < 0.01:
		direction = Vector2.RIGHT
	throw_direction = direction.normalized()
	velocity = throw_direction * THROW_SPEED

func _drop() -> void:
	state = State.FREE
	carrier = null
	velocity = Vector2.ZERO

func drop() -> void:
	_drop()

func _bounce_off_walls() -> void:
	var col: KinematicCollision2D = get_last_slide_collision()
	if col:
		velocity = velocity.bounce(col.get_normal()) * WALL_BOUNCE

func _clamp_to_arena() -> void:
	global_position = global_position.clamp(ARENA_MIN, ARENA_MAX)

func is_free() -> bool:
	return state == State.FREE

func is_carried() -> bool:
	return state == State.CARRIED

func get_carrier() -> Node2D:
	return carrier
