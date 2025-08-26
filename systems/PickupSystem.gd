class_name PickupSystem extends Node

var pickups: Array[Node2D] = []
var collection_range: float = 40.0

func _ready():
	pass

func _process(delta):
	_process_magnetism()
	_check_collections()

func _process_magnetism():
	var player = EntityManager.get_player()
	if not player:
		return
	
	var player_magnet = player.get_component("magnet")
	if player_magnet:
		player_magnet.update(get_process_delta_time())

func _check_collections():
	var player = EntityManager.get_player()
	if not player:
		return
	
	var nearby_pickups = EntityManager.get_pickups_in_range(player.position, collection_range)
	
	for pickup in nearby_pickups:
		if pickup.has_method("_on_body_entered"):
			pickup._on_body_entered(player)

func register_pickup(pickup: Node2D):
	if pickup not in pickups:
		pickups.append(pickup)

func unregister_pickup(pickup: Node2D):
	pickups.erase(pickup)