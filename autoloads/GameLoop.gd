extends Node

enum State {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

var current_state := State.MENU
var game_time := 0.0
var wave_number := 0
var player_level := 1
var player_xp := 0
var xp_required := 5
var spawning_enabled := true
var next_spawn_time := 0.0
var spawn_interval := 2.0
var spawn_timer := 0.0

func _ready():
	EventBus.game_started.connect(_on_game_started)
	EventBus.player_died.connect(_on_player_died)
	CombatSystem.xp_gained.connect(_on_xp_gained)
	
	set_process_input(true)
	
	# Add debug timer for auto-output every 3 seconds
	var debug_timer = Timer.new()
	debug_timer.wait_time = 3.0
	debug_timer.timeout.connect(_auto_debug)
	debug_timer.autostart = true
	add_child(debug_timer)
	
	print("GameLoop initialized - starting game...")
	# Auto-start the game
	call_deferred("start_game")

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:  # Toggle spawn
				spawning_enabled = !spawning_enabled
				print("Spawning: ", spawning_enabled)
			KEY_2:  # Force spawn enemies INSIDE viewport
				print("Spawning 5 enemies INSIDE viewport for testing...")
				for i in 5:
					var enemy = PoolManager.get_enemy("zombie")
					if enemy:
						# Spawn well inside the viewport for testing
						var test_pos = Vector2(
							randf_range(100, 1180),  # Well within 1280 width
							randf_range(100, 620)     # Well within 720 height
						)
						enemy.activate(test_pos)
						print("Enemy spawned at VISIBLE position: ", test_pos)
			KEY_3:  # Kill all enemies
				EntityManager.clear_all()
				print("Killed all enemies")
			KEY_4:  # Add XP
				_on_xp_gained(10)
				print("Added 10 XP")
			KEY_5:  # Print stats
				print("\n=== GAME STATS ===")
				print("FPS: ", Engine.get_frames_per_second())
				print("Pool Usage:")
				var stats = PoolManager.get_pool_stats()
				for key in stats:
					print("  %s: %s" % [key, stats[key]])
				print("Active Entities:")
				print("  Enemies: ", EntityManager.get_entity_count())
				var player = EntityManager.get_player()
				if player and player.has_method("get_component"):
					var health = player.get_component("health")
					if health:
						print("  Player Health: ", health.current)
				print("Game Time: ", game_time)
				print("Player Level: ", player_level)
				print("Player XP: ", player_xp, "/", xp_required)
				print("Spawning Enabled: ", spawning_enabled)
				print("Current State: ", State.keys()[current_state])
				print("================\n")

func _process(delta):
	if current_state == State.PLAYING:
		game_time += delta
		
		# Better spawn timing
		if spawning_enabled:
			spawn_timer += delta
			if spawn_timer >= spawn_interval:
				spawn_timer = 0.0
				if EntityManager.get_entity_count() < GameConfig.game_settings.max_enemies:
					_spawn_enemies(3)
					print("[Spawn] Spawned 3 enemies at time: ", snappedf(game_time, 0.1))

func start_game():
	if current_state == State.MENU:
		current_state = State.PLAYING
		game_time = 0.0
		wave_number = 0
		player_level = 1
		player_xp = 0
		xp_required = GameConfig.game_settings.base_xp_requirements[0]
		EntityManager.clear_all()
		EventBus.game_started.emit()

func _on_game_started():
	current_state = State.PLAYING
	print("Game started!")

func _on_player_died():
	current_state = State.GAME_OVER
	EventBus.game_over.emit()
	print("Game Over!")

func _on_xp_gained(amount: int):
	player_xp += amount
	
	while player_xp >= xp_required:
		player_xp -= xp_required
		player_level += 1
		
		var level_index = min(player_level - 1, GameConfig.game_settings.base_xp_requirements.size() - 1)
		xp_required = GameConfig.game_settings.base_xp_requirements[level_index]
		
		EventBus.player_leveled_up.emit(player_level)
		print("Level up! Now level ", player_level)

func _spawn_enemies(count: int):
	for i in count:
		var enemy = PoolManager.get_enemy("zombie")
		if enemy:
			var spawn_pos = _get_spawn_position()
			enemy.activate(spawn_pos)

func _get_spawn_position() -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	
	# FOR TESTING: Spawn INSIDE the viewport so we can see them!
	# Comment this out later and uncomment the margin spawning below
	return Vector2(
		randf_range(50, viewport_size.x - 50),
		randf_range(50, viewport_size.y - 50)
	)
	
	# ORIGINAL CODE (commented out for testing):
	#var margin = 50.0
	#var side = randi() % 4
	#
	#match side:
	#	0: # Top
	#		return Vector2(randf() * viewport_size.x, -margin)
	#	1: # Right
	#		return Vector2(viewport_size.x + margin, randf() * viewport_size.y)
	#	2: # Bottom
	#		return Vector2(randf() * viewport_size.x, viewport_size.y + margin)
	#	_: # Left
	#		return Vector2(-margin, randf() * viewport_size.y)

func _auto_debug():
	print("[AUTO] State: ", State.keys()[current_state], " | Enemies: ", EntityManager.get_entity_count(), " | Time: ", snappedf(game_time, 0.1), "s | Spawning: ", spawning_enabled)

func restart_game():
	print("[GameLoop] Restarting game...")
	
	# Clear all existing entities
	EntityManager.clear_all()
	
	# Reset game state
	current_state = State.MENU
	game_time = 0.0
	wave_number = 0
	player_level = 1
	player_xp = 0
	xp_required = GameConfig.game_settings.base_xp_requirements[0]
	spawning_enabled = true
	
	# Recreate the player
	var main = get_tree().current_scene
	if main:
		# Remove old player if it exists
		var old_player = main.get_node_or_null("Player")
		if old_player:
			old_player.queue_free()
			await old_player.tree_exited
		
		# Create new player
		var new_player = CharacterBody2D.new()
		new_player.name = "Player"
		new_player.set_script(preload("res://entities/Player.gd"))
		new_player.position = get_viewport().get_visible_rect().size / 2
		main.add_child(new_player)
		
		# Small delay to ensure everything is initialized
		await get_tree().create_timer(0.1).timeout
	
	# Now start the game
	current_state = State.PLAYING
	EventBus.game_started.emit()
	print("[GameLoop] Game restarted successfully!")

func get_game_stats() -> Dictionary:
	return {
		"time": game_time,
		"level": player_level,
		"xp": player_xp,
		"xp_required": xp_required,
		"enemies": EntityManager.get_entity_count(),
		"wave": wave_number
	}