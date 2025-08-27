class_name MovementComponent extends Node

var entity: CharacterBody2D
var speed: float = 100.0
var direction: Vector2 = Vector2.ZERO

func initialize(owner_entity: CharacterBody2D, move_speed: float):
	entity = owner_entity
	speed = move_speed
	print("[Movement] Initialized with speed: ", speed)

func set_direction(dir: Vector2):
	direction = dir.normalized()

func update(delta: float):
	if not entity:
		print("[Movement] No entity!")
		return
	
	# Set the velocity on the CharacterBody2D
	entity.velocity = direction * speed
	
	# Actually move the entity!
	entity.move_and_slide()
	
	# Debug log occasionally
	if Engine.get_frames_drawn() % 120 == 0 and direction != Vector2.ZERO:
		print("[Movement] Moving entity at ", entity.position, " with velocity ", entity.velocity)