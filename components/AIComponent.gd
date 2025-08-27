class_name AIComponent extends Node

var entity: CharacterBody2D
var behavior_type: String = "chase_player"
var xp_value: int = 1
var target: Node2D
var chase_speed: float = 80.0
var no_player_warning_timer: float = 0.0

func initialize(owner: CharacterBody2D, ai_type: String):
	entity = owner
	behavior_type = ai_type

func update(delta: float):
	if not entity:
		return
		
	match behavior_type:
		"chase_player":
			_chase_player_behavior(delta)

func _chase_player_behavior(delta: float):
	var player = EntityManager.get_player()
	if not player:
		# Only warn occasionally, not every frame
		no_player_warning_timer += delta
		if no_player_warning_timer >= 1.0:
			no_player_warning_timer = 0.0
			print("[AI] No player found in EntityManager")
		return
	
	# Reset warning timer when player is found
	no_player_warning_timer = 0.0
	
	# Calculate direction to player
	var to_player = player.position - entity.position
	var distance = to_player.length()
	
	if distance > 0.1:  # Avoid division by zero
		var direction = to_player.normalized()
		
		# Set direction on movement component
		var movement = entity.get_component("movement")
		if movement and movement.has_method("set_direction"):
			movement.set_direction(direction)