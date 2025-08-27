extends Control

var debug_label: RichTextLabel

func _ready():
	# Create debug display in top-right corner
	debug_label = RichTextLabel.new()
	debug_label.size = Vector2(300, 200)
	debug_label.position = Vector2(get_viewport().get_visible_rect().size.x - 320, 20)
	debug_label.add_theme_color_override("default_color", Color.GREEN)
	debug_label.add_theme_font_size_override("normal_font_size", 12)
	add_child(debug_label)

func _process(_delta):
	if not debug_label:
		return
	
	var text = "[color=yellow]== DEBUG ==[/color]\n"
	text += "FPS: %d\n" % Engine.get_frames_per_second()
	text += "Enemies: %d\n" % EntityManager.get_entity_count()
	text += "State: %s\n" % GameLoop.State.keys()[GameLoop.current_state]
	text += "Spawning: %s\n" % str(GameLoop.spawning_enabled)
	text += "Time: %.1f\n" % GameLoop.game_time
	
	var pool_stats = PoolManager.get_pool_stats()
	text += "\n[color=cyan]Pools:[/color]\n"
	for key in pool_stats:
		text += "%s: %s\n" % [key, pool_stats[key]]
	
	text += "\n[color=yellow]Keys:[/color]\n"
	text += "1: Toggle Spawn\n"
	text += "2: Force Spawn 10\n"
	text += "3: Kill All\n"
	text += "4: Add XP\n"
	text += "5: Print Stats"
	
	debug_label.text = text