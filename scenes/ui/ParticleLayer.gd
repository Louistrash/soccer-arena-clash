extends Control
## Subtle floating particles for lobby atmosphere.

const PARTICLE_COUNT := 20

var _particles: Array[Dictionary] = []

func _ready() -> void:
	var vs := get_viewport_rect().size
	for i in PARTICLE_COUNT:
		_particles.append({
			"pos": Vector2(randf() * vs.x, randf() * vs.y),
			"vel": Vector2(randf_range(-8, 8), randf_range(-12, -4)),
			"life": randf(),
			"size": randf_range(1.5, 4.0),
			"max_life": randf_range(2.0, 5.0),
		})
	queue_redraw()

func _process(delta: float) -> void:
	for p in _particles:
		p.pos += p.vel * delta
		p.life += delta
		if p.pos.x < -10:
			p.pos.x = size.x + 10
		elif p.pos.x > size.x + 10:
			p.pos.x = -10
		if p.pos.y < -10:
			p.pos.y = size.y + 10
		elif p.pos.y > size.y + 10:
			p.pos.y = -10
		if p.life >= p.max_life:
			p.life = 0.0
			var vs := get_viewport_rect().size
			p.pos = Vector2(randf() * vs.x, randf() * vs.y)
	queue_redraw()

func _draw() -> void:
	for p in _particles:
		var alpha: float = 0.12 * (1.0 - p.life / p.max_life)
		draw_circle(p.pos, p.size, Color(0.9, 0.95, 0.85, alpha))
