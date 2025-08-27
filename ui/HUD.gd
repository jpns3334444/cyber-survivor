extends Control

var player: CharacterBody2D
var health_bar: ProgressBar
var health_bar_bg: Panel
var xp_bar: ProgressBar
var xp_bar_bg: Panel
var level_label: Label
var enemy_counter_label: Label
var game_over_panel: Panel
var restart_button: Button

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block mouse input
	create_ui_elements()
	
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_over.connect(_on_game_over)
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	
	if restart_button:
		restart_button.pressed.connect(_on_restart_button_pressed)

func create_ui_elements():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# XP Bar across entire top of screen
	xp_bar_bg = Panel.new()
	xp_bar_bg.size = Vector2(viewport_size.x, 8)
	xp_bar_bg.position = Vector2(0, 0)
	xp_bar_bg.modulate = Color(0.2, 0.2, 0.2, 0.8)
	add_child(xp_bar_bg)
	
	xp_bar = ProgressBar.new()
	xp_bar.size = Vector2(viewport_size.x, 8)
	xp_bar.position = Vector2(0, 0)
	xp_bar.max_value = 5
	xp_bar.value = 0
	xp_bar.show_percentage = false
	# Style the XP bar
	var xp_style = StyleBoxFlat.new()
	xp_style.bg_color = Color(0.2, 0.8, 0.2, 1.0)  # Green
	xp_bar.add_theme_stylebox_override("fill", xp_style)
	var xp_bg_style = StyleBoxFlat.new()
	xp_bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.7)
	xp_bar.add_theme_stylebox_override("background", xp_bg_style)
	add_child(xp_bar)
	
	# Level indicator in center top
	level_label = Label.new()
	level_label.text = "Level 1"
	level_label.add_theme_font_size_override("font_size", 24)
	level_label.add_theme_color_override("font_color", Color.YELLOW)
	level_label.add_theme_color_override("font_shadow_color", Color.BLACK)
	level_label.add_theme_constant_override("shadow_offset_x", 2)
	level_label.add_theme_constant_override("shadow_offset_y", 2)
	level_label.size = Vector2(100, 40)
	level_label.position = Vector2(viewport_size.x / 2 - 50, 12)
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(level_label)
	
	# Static Health bar in top left corner (below XP bar)
	health_bar_bg = Panel.new()
	health_bar_bg.size = Vector2(200, 20)
	health_bar_bg.position = Vector2(10, 20)
	health_bar_bg.modulate = Color(0.2, 0.2, 0.2, 0.8)
	add_child(health_bar_bg)
	
	health_bar = ProgressBar.new()
	health_bar.size = Vector2(200, 20)
	health_bar.position = Vector2(10, 20)
	health_bar.max_value = 100
	health_bar.value = 100
	health_bar.show_percentage = false
	# Style the health bar
	var health_style = StyleBoxFlat.new()
	health_style.bg_color = Color(0.8, 0.2, 0.2, 1.0)  # Red
	health_bar.add_theme_stylebox_override("fill", health_style)
	var health_bg_style = StyleBoxFlat.new()
	health_bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.7)
	health_bar.add_theme_stylebox_override("background", health_bg_style)
	add_child(health_bar)
	
	# Add HP text label on health bar
	var hp_label = Label.new()
	hp_label.name = "HPLabel"
	hp_label.text = "HP: 100/100"
	hp_label.add_theme_font_size_override("font_size", 14)
	hp_label.add_theme_color_override("font_color", Color.WHITE)
	hp_label.position = Vector2(220, 20)
	add_child(hp_label)
	
	# Enemy counter below health bar
	enemy_counter_label = Label.new()
	enemy_counter_label.text = "Enemies: 0"
	enemy_counter_label.add_theme_font_size_override("font_size", 16)
	enemy_counter_label.add_theme_color_override("font_color", Color.WHITE)
	enemy_counter_label.position = Vector2(10, 45)
	add_child(enemy_counter_label)
	
	# Game Over Panel - centered
	game_over_panel = Panel.new()
	game_over_panel.size = Vector2(400, 250)
	game_over_panel.position = Vector2(viewport_size.x / 2 - 200, viewport_size.y / 2 - 125)
	game_over_panel.visible = false
	# Style the panel
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.8, 0.2, 0.2, 1.0)
	panel_style.corner_radius_top_left = 10
	panel_style.corner_radius_top_right = 10
	panel_style.corner_radius_bottom_left = 10
	panel_style.corner_radius_bottom_right = 10
	game_over_panel.add_theme_stylebox_override("panel", panel_style)
	add_child(game_over_panel)
	
	var game_over_label = Label.new()
	game_over_label.text = "GAME OVER"
	game_over_label.add_theme_font_size_override("font_size", 48)
	game_over_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2, 1.0))
	game_over_label.position = Vector2(65, 40)
	game_over_panel.add_child(game_over_label)
	
	var stats_label = Label.new()
	stats_label.name = "StatsLabel"
	stats_label.text = "Survived: 0:00\nLevel Reached: 1\nEnemies Killed: 0"
	stats_label.add_theme_font_size_override("font_size", 18)
	stats_label.add_theme_color_override("font_color", Color.WHITE)
	stats_label.position = Vector2(100, 100)
	game_over_panel.add_child(stats_label)
	
	restart_button = Button.new()
	restart_button.text = "RESTART"
	restart_button.size = Vector2(150, 50)
	restart_button.position = Vector2(125, 170)
	restart_button.add_theme_font_size_override("font_size", 20)
	game_over_panel.add_child(restart_button)
	
	# Add debug display
	var debug_display = Control.new()
	debug_display.set_script(preload("res://ui/DebugDisplay.gd"))
	add_child(debug_display)

func _process(_delta):
	_update_ui()

func _update_ui():
	player = EntityManager.get_player()
	
	# Update health bar value
	if player and is_instance_valid(player) and player.has_method("get_component"):
		var health = player.get_component("health")
		if health:
			health_bar.value = health.current
			health_bar.max_value = health.max_health
			
			# Update HP text
			var hp_label = get_node_or_null("HPLabel")
			if hp_label:
				hp_label.text = "HP: %d/%d" % [int(health.current), int(health.max_health)]
	
	# Update XP bar
	var stats = GameLoop.get_game_stats()
	if stats:
		xp_bar.value = stats.xp
		xp_bar.max_value = stats.xp_required
		level_label.text = "Level " + str(stats.level)
		
		# Update enemy counter
		enemy_counter_label.text = "Enemies: " + str(stats.enemies)
		
		# Update game over stats
		if game_over_panel.visible:
			var stats_label = game_over_panel.get_node("StatsLabel")
			if stats_label:
				var minutes = int(stats.time) / 60
				var seconds = int(stats.time) % 60
				var enemies_killed = stats.get("enemies_killed", 0)
				stats_label.text = "Survived: %d:%02d\nLevel Reached: %d\nEnemies Killed: %d" % [minutes, seconds, stats.level, enemies_killed]

func _on_game_started():
	game_over_panel.visible = false

func _on_game_over():
	game_over_panel.visible = true

func _on_player_leveled_up(new_level: int):
	level_label.text = "Level " + str(new_level)
	# Add a brief animation
	var tween = create_tween()
	tween.tween_property(level_label, "scale", Vector2(1.5, 1.5), 0.2)
	tween.tween_property(level_label, "scale", Vector2(1.0, 1.0), 0.2)

func _on_restart_button_pressed():
	GameLoop.restart_game()