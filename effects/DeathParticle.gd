extends Node2D

var velocity := Vector2(randf_range(-200, 200), randf_range(-200, 200))
var lifetime := 0.5
var size := 4.0

func _ready():
	set_physics_process(true)

func _physics_process(delta):
	position += velocity * delta
	velocity *= 0.95  # Friction
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	queue_redraw()

func _draw():
	var alpha = lifetime * 2.0
	draw_rect(Rect2(-size/2, -size/2, size, size), Color(1, 0, 0, alpha))