extends Control
## Stadium background: navy gradient, procedural field lines, green/gold beams, center spotlight.

var center_glow_pos: Vector2 = Vector2(-9999, -9999)

const STADIUM_GREEN := Color(0.2, 0.95, 0.5)
const STADIUM_GOLD := Color(0.94, 0.75, 0.25)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y

	# 1. Navy gradient base
	var top_col := Color(0.04, 0.06, 0.1)
	var bot_col := Color(0.08, 0.12, 0.19)
	var bg_pts := PackedVector2Array([Vector2(0, 0), Vector2(w, 0), Vector2(w, h), Vector2(0, h)])
	var bg_cols := PackedColorArray([top_col, top_col, bot_col, bot_col])
	draw_polygon(bg_pts, bg_cols)

	# 2. Procedural Soccer Field Pattern (Subtle)
	# Draw faint field lines to suggest a pitch
	var line_col := Color(1.0, 1.0, 1.0, 0.03)
	var center := Vector2(w * 0.5, h * 0.55)
	
	# Center circle
	draw_arc(center, 120.0, 0, TAU, 64, line_col, 2.0)
	draw_line(Vector2(0, center.y), Vector2(w, center.y), line_col, 2.0) # Halfway line
	
	# Penalty box hints (sides)
	var box_h := 300.0
	var box_w := 150.0
	# Left box
	draw_polyline(PackedVector2Array([
		Vector2(0, center.y - box_h/2), 
		Vector2(box_w, center.y - box_h/2), 
		Vector2(box_w, center.y + box_h/2), 
		Vector2(0, center.y + box_h/2)
	]), line_col, 2.0)
	# Right box
	draw_polyline(PackedVector2Array([
		Vector2(w, center.y - box_h/2), 
		Vector2(w - box_w, center.y - box_h/2), 
		Vector2(w - box_w, center.y + box_h/2), 
		Vector2(w, center.y + box_h/2)
	]), line_col, 2.0)

	# 3. Spotlight beams from top corners (Green/Gold)
	# Left beam (Green)
	_draw_spotlight_beam(Vector2(w * 0.1, 0), Vector2(w * 0.35, h * 0.7), 220.0, Color(STADIUM_GREEN.r, STADIUM_GREEN.g, STADIUM_GREEN.b, 0.06))
	# Right beam (Green)
	_draw_spotlight_beam(Vector2(w * 0.9, 0), Vector2(w * 0.65, h * 0.7), 220.0, Color(STADIUM_GREEN.r, STADIUM_GREEN.g, STADIUM_GREEN.b, 0.06))
	
	# Inner beams (Gold/Warm)
	_draw_spotlight_beam(Vector2(w * 0.25, 0), Vector2(w * 0.45, h * 0.6), 140.0, Color(STADIUM_GOLD.r, STADIUM_GOLD.g, STADIUM_GOLD.b, 0.04))
	_draw_spotlight_beam(Vector2(w * 0.75, 0), Vector2(w * 0.55, h * 0.6), 140.0, Color(STADIUM_GOLD.r, STADIUM_GOLD.g, STADIUM_GOLD.b, 0.04))

	# 4. Top edge glow (stadium lights)
	for i in range(15):
		var r: float = 400.0 - float(i) * 30.0
		var alpha: float = 0.02 + float(i) * 0.003
		draw_circle(Vector2(w * 0.15, -20), r, Color(STADIUM_GREEN.r, STADIUM_GREEN.g, STADIUM_GREEN.b, alpha))
		draw_circle(Vector2(w * 0.85, -20), r, Color(STADIUM_GREEN.r, STADIUM_GREEN.g, STADIUM_GREEN.b, alpha))

	# 5. Center spotlight behind selected hero (Gold)
	if center_glow_pos.x > -9999:
		var xform: Transform2D = get_global_transform_with_canvas().affine_inverse()
		var local_pos: Vector2 = xform * center_glow_pos
		
		# Draw a "cone" shape on the floor? Or just strong radial glow.
		# Plan says: Gold spotlight cone, strong pulse.
		# We'll do a strong radial gradient.
		
		for i in range(20):
			var r: float = 100.0 + float(i) * 25.0
			var alpha: float = 0.15 - float(i) * 0.007
			if alpha > 0:
				draw_arc(local_pos, r, 0, TAU, 40, Color(STADIUM_GOLD.r, STADIUM_GOLD.g, STADIUM_GOLD.b, alpha))
		
		# Intense inner core
		for i in range(8):
			var r: float = 40.0 + float(i) * 15.0
			var alpha: float = 0.25 - float(i) * 0.03
			if alpha > 0:
				draw_circle(local_pos, r, Color(STADIUM_GOLD.r, STADIUM_GOLD.g, STADIUM_GOLD.b, alpha * 0.5))

func _draw_spotlight_beam(origin: Vector2, target: Vector2, spread: float, col: Color) -> void:
	var dir := (target - origin).normalized()
	var perp := Vector2(-dir.y, dir.x)
	var p1 := origin - perp * 20.0
	var p2 := origin + perp * 20.0
	var p3 := target + perp * spread
	var p4 := target - perp * spread
	var pts := PackedVector2Array([p1, p2, p3, p4])
	var cols := PackedColorArray([col, col, Color(col.r, col.g, col.b, 0.0), Color(col.r, col.g, col.b, 0.0)])
	draw_polygon(pts, cols)
