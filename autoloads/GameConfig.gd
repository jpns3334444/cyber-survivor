extends Node

var game_settings: GameSettings
var player_data: PlayerData
var weapons := {}
var enemies := {}
var waves := []

func _ready():
	load_all_data()

func load_all_data():
	game_settings = load("res://data/GameSettings.tres") as GameSettings
	if not game_settings:
		game_settings = GameSettings.new()
	
	player_data = load("res://data/PlayerData.tres") as PlayerData
	if not player_data:
		player_data = PlayerData.new()
	
	var weapon_list = load("res://data/Weapons.tres")
	if weapon_list and weapon_list is WeaponList:
		for weapon in weapon_list.weapons:
			weapons[weapon.id] = weapon
	else:
		var default_weapon = WeaponResource.new()
		weapons["pistol"] = default_weapon
	
	var enemy_list = load("res://data/Enemies.tres") 
	if enemy_list and enemy_list is EnemyList:
		for enemy in enemy_list.enemies:
			enemies[enemy.id] = enemy
	else:
		var default_enemy = EnemyResource.new()
		enemies["zombie"] = default_enemy
	
	var wave_data = load("res://data/Waves.tres")
	if wave_data and wave_data is WaveData:
		waves = wave_data.waves
	else:
		waves = []

func get_weapon(weapon_id: String) -> WeaponResource:
	if weapon_id in weapons:
		return weapons[weapon_id]
	return WeaponResource.new()

func get_enemy_data(enemy_id: String) -> EnemyResource:
	if enemy_id in enemies:
		return enemies[enemy_id]
	return EnemyResource.new()

func get_wave(wave_index: int) -> Wave:
	if wave_index < waves.size():
		return waves[wave_index]
	var default_wave = Wave.new()
	default_wave.enemy_types = ["zombie"]
	default_wave.spawn_rate = 2.0
	default_wave.max_enemies = 10 + wave_index * 5
	return default_wave
