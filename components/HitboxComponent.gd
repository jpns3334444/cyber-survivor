class_name HitboxComponent extends Area2D

var entity: Node2D
var damage: float = 10.0
var team: String = "neutral"

signal hit_detected(target: Node2D)

func initialize(owner: Node2D, hitbox_damage: float = 10.0, collision_team: String = "neutral"):
	entity = owner
	damage = hitbox_damage
	team = collision_team
	
	collision_layer = _get_layer_for_team(team)
	collision_mask = _get_mask_for_team(team)
	
	body_entered.connect(_on_body_entered)

func _get_layer_for_team(team_name: String) -> int:
	match team_name:
		"player":
			return 1
		"enemy":
			return 2
		"projectile":
			return 4
		_:
			return 8

func _get_mask_for_team(team_name: String) -> int:
	match team_name:
		"player":
			return 2 # Hit enemies
		"enemy":
			return 1 # Hit player
		"projectile":
			return 2 # Hit enemies
		_:
			return 0

func _on_body_entered(body: Node2D):
	if body == entity:
		return
	
	hit_detected.emit(body)
	
	if team == "projectile":
		EventBus.damage_requested.emit(body, damage, entity)