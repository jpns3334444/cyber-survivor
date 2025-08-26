extends Node

signal player_died()
signal player_leveled_up(new_level: int)
signal wave_started(wave_number: int)
signal enemy_spawned(enemy: Node2D)
signal enemy_killed(enemy: Node2D)
signal xp_collected(amount: int)
signal game_over()
signal game_started()
signal damage_requested(target: Node2D, amount: float, source: Node2D)

func _ready():
	damage_requested.connect(_on_damage_requested)

func _on_damage_requested(target: Node2D, amount: float, source: Node2D = null):
	CombatSystem.apply_damage(target, amount, source)