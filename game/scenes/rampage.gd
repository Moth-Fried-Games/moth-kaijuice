extends Node2D

var building_resource: Resource = preload("res://game/entities/building.tscn")
var soldier_resource: Resource = preload("res://game/entities/soldier.tscn")

@onready var spawns_node: Node2D = $Spawns
@onready var spawn_marker_2d: Marker2D = $SpawnMarker2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var kaiju: Node2D = $Kaiju
@onready var spawn_timer: Timer = $SpawnTimer


func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	kaiju.game_scene = self


func _physics_process(delta: float) -> void:
	pass


func move_spawns() -> void:
	for child in spawns_node.get_children():
		if is_instance_valid(child):
			child.global_position.x -= kaiju.current_move_speed * get_physics_process_delta_time()


func spawn_building() -> void:
	var building_instance = building_resource.instantiate()
	var current_viewport: Vector2 = get_viewport().size
	building_instance.global_position.x = current_viewport.x + 400
	building_instance.global_position.y = spawn_marker_2d.global_position.y
	spawns_node.add_child(building_instance)


func spawn_soldier() -> void:
	var soldier_instance = soldier_resource.instantiate()
	var current_viewport: Vector2 = get_viewport().size
	soldier_instance.global_position.x = current_viewport.x + 400
	soldier_instance.global_position.y = spawn_marker_2d.global_position.y
	spawns_node.add_child(soldier_instance)


func _on_spawn_timer_timeout() -> void:
	if kaiju.walking:
		if GameGlobals.rng.randf_range(0, 1) > 0.5:
			match GameGlobals.rng.randi_range(0, 1):
				0:
					spawn_building()
				1:
					spawn_soldier()
