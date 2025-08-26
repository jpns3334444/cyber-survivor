extends Label

var velocity := Vector2(0, -50)
var lifetime := 1.0
var fade_time := 0.5

func _ready():
	set_process(true)
	# Center the label
	pivot_offset = size / 2

func _process(delta):
	position += velocity * delta
	lifetime -= delta
	
	# Start fading in the last half of lifetime
	if lifetime <= fade_time:
		var alpha = lifetime / fade_time
		add_theme_color_override("font_color", Color(1, 0, 0, alpha))
	
	if lifetime <= 0:
		queue_free()