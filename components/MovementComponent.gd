class_name MovementComponent extends Node

var entity: CharacterBody2D
var speed: float = 100.0
var direction: Vector2 = Vector2.ZERO

func initialize(owner_entity: CharacterBody2D, move_speed: float):
	entity = owner_entity
	speed = move_speed

func set_direction(dir: Vector2):
	direction = dir.normalized()

func update(delta: float):
	if not entity:
		return
	
	entity.velocity = direction * speed
	entity.move_and_slide()