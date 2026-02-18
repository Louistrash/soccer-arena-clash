extends Control
## Teal/cyan floating sparkle particles for stadium atmosphere.

const PARTICLE_COUNT := 40

var _particles: Array[Dictionary] = []

func _ready() -> void:
	var vs := get_viewport_rect().size
	for i in PARTICLE_COUNT:
		_particles.append(_make_particle(vs, true))
	queue_redraw()

func _make_particle(vs: Vector2, randomize_life: bool) -> Dictionary:
	return {
		"pos": Vector2(randf() * vs.x, randf() * vs.y),
		"vel": Vector2(randf_range(-6, 6), randf_range(-10, -2)),
		"life": randf() * 4.0 if randomize_life else 0.0,
		"size": randf_range(1.0, 3.5),
		"max_life": randf_range(3.0, 7.0),
		"bright": randf() > 0.6,
	}

func _process(delta: float) -> void:
	var vs := get_viewport_rect().size
	for p in _particles:
		p.pos += p.vel * delta
		p.life += delta
		if p.life >= p.max_life or p.pos.y < -20 or p.pos.x < -20 or p.pos.x > vs.x + 20:
			var np := _make_particle(vs, false)
			p.pos = np.pos
			p.vel = np.vel
			p.life = 0.0
			p.size = np.size
			p.max_life = np.max_life
			p.bright = np.bright
	queue_redraw()

func _draw() -> void:
	for p in _particles:
		var life_norm: float = p.life / p.max_life
		var fade: float = sin(life_norm * PI)
		var alpha: float = fade * (0.25 if p.bright else 0.12)
		var col: Color
		if p.bright:
			col = Color(0.4, 0.95, 1.0, alpha)
		else:
			col = Color(0.15, 0.7, 0.85, alpha)
		draw_circle(p.pos, p.size, col)
