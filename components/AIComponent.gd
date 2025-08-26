class_name AIComponent extends Node

var entity: CharacterBody2D
var behavior_type: String = "chase_player"
var xp_value: int = 1
var target: Node2D
var chase_speed: float = 80.0

func initialize(owner: CharacterBody2D, ai_type: String):
	entity = owner
	behavior_type = ai_type

func update(delta: float):
	match behavior_type:
		"chase_player":
			_chase_player_behavior()

func _chase_player_behavior():
	var player = EntityManager.get_player()
	if not player:
		return
	
	var direction = (player.position - entity.position).normalized()
	var movement = entity.get_component("movement")
	if movement and movement.has_method("set_direction"):
		movement.set_direction(direction)