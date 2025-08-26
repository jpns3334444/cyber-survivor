extends Control

@onready var health_bar: ProgressBar
@onready var xp_bar: ProgressBar
@onready var level_label: Label
@onready var enemy_count_label: Label
@onready var time_label: Label
@onready var game_over_panel: Panel
@onready var start_button: Button

var player: CharacterBody2D

func _ready():
	create_ui_elements()
	
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_over.connect(_on_game_over)
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)

func create_ui_elements():
	health_bar = ProgressBar.new()
	health_bar.size = Vector2(200, 20)
	health_bar.position = Vector2(20, 20)
	health_bar.max_value = 100
	health_bar.value = 100
	add_child(health_bar)
	
	var health_label = Label.new()
	health_label.text = "Health"
	health_label.position = Vector2(20, 0)
	add_child(health_label)
	
	xp_bar = ProgressBar.new()
	xp_bar.size = Vector2(200, 20)
	xp_bar.position = Vector2(20, 60)
	xp_bar.max_value = 5
	xp_bar.value = 0
	add_child(xp_bar)
	
	var xp_label = Label.new()
	xp_label.text = "XP"
	xp_label.position = Vector2(20, 40)
	add_child(xp_label)
	
	level_label = Label.new()
	level_label.text = "Level: 1"
	level_label.position = Vector2(240, 20)
	add_child(level_label)
	
	enemy_count_label = Label.new()
	enemy_count_label.text = "Enemies: 0"
	enemy_count_label.position = Vector2(240, 40)
	add_child(enemy_count_label)
	
	time_label = Label.new()
	time_label.text = "Time: 0:00"
	time_label.position = Vector2(240, 60)
	add_child(time_label)
	
	game_over_panel = Panel.new()
	game_over_panel.size = Vector2(300, 200)
	game_over_panel.position = Vector2(get_viewport().get_visible_rect().size.x / 2 - 150, get_viewport().get_visible_rect().size.y / 2 - 100)
	game_over_panel.visible = false
	add_child(game_over_panel)
	
	var game_over_label = Label.new()
	game_over_label.text = "GAME OVER"
	game_over_label.position = Vector2(100, 50)
	game_over_panel.add_child(game_over_label)
	
	start_button = Button.new()
	start_button.text = "START GAME"
	start_button.size = Vector2(120, 40)
	start_button.position = Vector2(90, 100)
	game_over_panel.add_child(start_button)

func _process(delta):
	_update_ui()

func _update_ui():
	player = EntityManager.get_player()
	
	if player and player.has_method("get_component"):
		var health = player.get_component("health")
		if health:
			health_bar.value = health.current
			health_bar.max_value = health.max_health
	
	var stats = GameLoop.get_game_stats()
	if stats:
		level_label.text = "Level: %d" % stats.level
		enemy_count_label.text = "Enemies: %d" % stats.enemies
		
		var minutes = int(stats.time) / 60
		var seconds = int(stats.time) % 60
		time_label.text = "Time: %d:%02d" % [minutes, seconds]
		
		xp_bar.value = stats.xp
		xp_bar.max_value = stats.xp_required

func _on_game_started():
	game_over_panel.visible = false

func _on_game_over():
	game_over_panel.visible = true

func _on_player_leveled_up(new_level: int):
	level_label.text = "Level: %d" % new_level

func _on_start_button_pressed():
	GameLoop.start_game()