class_name AIComponent extends Node

var entity: CharacterBody2D
var behavior_type: String = "chase_player"
var xp_value: int = 1
var target: Node2D
var chase_speed: float = 80.0

func initialize(owner: CharacterBody2D, ai_type: String):
	entity = owner
	behavior_type = ai_type
	print("[AI] Initialized for entity at: ", entity.position)

func update(delta: float):
	if not entity:
		return
		
	match behavior_type:
		"chase_player":
			_chase_player_behavior(delta)

func _chase_player_behavior(delta: float):
	var player = EntityManager.get_player()
	if not player:
		if Engine.get_frames_drawn() % 60 == 0:
			print("[AI] WARNING: No player found!")
		return
	
	# Calculate direction to player
	var to_player = player.position - entity.position
	var distance = to_player.length()
	var direction = to_player.normalized()
	
	# Set direction on movement component
	var movement = entity.get_component("movement")
	if movement and movement.has_method("set_direction"):
		movement.set_direction(direction)
		
		# Debug log
		if Engine.get_frames_drawn() % 60 == 0:
			print("[AI] Entity at ", entity.position, " -> Player at ", player.position)
			print("     Direction: ", direction, " Distance: ", distance)
	else:
		if Engine.get_frames_drawn() % 60 == 0:
			print("[AI] ERROR: No movement component found!")