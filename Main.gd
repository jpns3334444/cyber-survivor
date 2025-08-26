extends Node2D

var player: CharacterBody2D
var hud: Control
var spawn_system: SpawnSystem
var projectile_system: ProjectileSystem
var pickup_system: PickupSystem

func _ready():
	setup_scene()
	
	EventBus.game_started.connect(_on_game_started)
	EventBus.game_over.connect(_on_game_over)

func setup_scene():
	hud = Control.new()
	hud.set_script(preload("res://ui/HUD.gd"))
	add_child(hud)
	
	spawn_system = SpawnSystem.new()
	add_child(spawn_system)
	
	projectile_system = ProjectileSystem.new()
	add_child(projectile_system)
	
	pickup_system = PickupSystem.new()
	add_child(pickup_system)
	
	_create_player()

func _create_player():
	player = CharacterBody2D.new()
	player.name = "Player"
	player.set_script(preload("res://entities/Player.gd"))
	player.position = get_viewport().get_visible_rect().size / 2
	add_child(player)

func _on_game_started():
	if player:
		player.position = get_viewport().get_visible_rect().size / 2
		var health = player.get_component("health")
		if health:
			health.current = health.max_health

func _on_game_over():
	EntityManager.clear_all()

func _process(delta):
	queue_redraw()

func _draw():
	var enemies = EntityManager.get_enemies()
	for enemy in enemies:
		if enemy.visible and enemy.has_method("_draw"):
			pass

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()