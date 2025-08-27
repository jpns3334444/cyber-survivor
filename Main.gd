extends Node2D

var player: CharacterBody2D
var hud: Control
var wave_spawner: WaveSpawner
var world_layer: Node2D
var ui_layer: CanvasLayer

func _ready():
	print("[Main] Setting up game scene...")
	setup_scene()
	setup_signals()
	
	# Start the game automatically after a brief delay
	await get_tree().create_timer(0.5).timeout
	GameLoop.start_game()

func setup_signals():
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_over.connect(_on_game_over)

func setup_scene():
	# Create world layer for all game entities
	world_layer = Node2D.new()
	world_layer.name = "WorldLayer"
	add_child(world_layer)
	
	# Set the world container for PoolManager
	PoolManager.world_container = world_layer
	
	# Create UI layer for HUD (on top of everything)
	ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	add_child(ui_layer)
	
	# Create HUD
	hud = Control.new()
	hud.name = "HUD"
	hud.set_script(preload("res://ui/HUD.gd"))
	ui_layer.add_child(hud)
	
	# Create wave spawner
	wave_spawner = WaveSpawner.new()
	wave_spawner.name = "WaveSpawner"
	add_child(wave_spawner)
	
	# Create player
	_create_player()
	
	print("[Main] Scene setup complete")

func _create_player():
	print("[Main] Creating player...")
	
	# Clear any existing player reference first
	if player and is_instance_valid(player):
		player.queue_free()
		player = null
	
	# Create new player
	player = CharacterBody2D.new()
	player.name = "Player"
	player.set_script(preload("res://entities/Player.gd"))
	player.position = get_viewport().get_visible_rect().size / 2
	world_layer.add_child(player)
	
	print("[Main] Player created at: ", player.position)
	
	# Verify player is registered
	await get_tree().create_timer(0.1).timeout
	var registered = EntityManager.get_player()
	if registered:
		print("[Main] Player successfully registered with EntityManager")
	else:
		print("[Main] WARNING: Player registration failed!")

func _on_game_started():
	print("[Main] Game started event received")
	if player and is_instance_valid(player):
		player.position = get_viewport().get_visible_rect().size / 2
		var health = player.get_component("health")
		if health:
			health.current = health.max_health
	else:
		# Recreate player if it doesn't exist
		_create_player()

func _on_game_over():
	print("[Main] Game over event received")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		elif event.keycode == KEY_R:  # Quick restart
			GameLoop.restart_game()

func _draw():
	# Draw a border around the play area for debugging
	if OS.is_debug_build():
		var viewport_size = get_viewport().get_visible_rect().size
		draw_rect(Rect2(Vector2.ZERO, viewport_size), Color(0.2, 0.2, 0.2, 1.0), false, 2.0)