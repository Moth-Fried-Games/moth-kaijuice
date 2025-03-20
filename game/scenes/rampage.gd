extends Node2D

var building_resource: Resource = preload("res://game/entities/building.tscn")
var soldier_resource: Resource = preload("res://game/entities/soldier.tscn")
var tank_resource: Resource = preload("res://game/entities/tank.tscn")
var mecha_resource: Resource = preload("res://game/entities/mecha.tscn")

@onready var spawns_node: Node2D = $Spawns
@onready var spawn_marker_2d: Marker2D = $SpawnMarker2D
@onready var building_marker_2d: Marker2D = $BuildingMarker2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var kaiju: Node2D = $Kaiju
@onready var spawn_timer: Timer = $SpawnTimer
@onready var building_timer: Timer = $BuildingTimer
@onready var back_parallax_2d: Parallax2D = $Background/BackParallax2D
@onready var middle_parallax_2d: Parallax2D = $Background/MiddleParallax2D
@onready var front_parallax_2d: Parallax2D = $Background/FrontParallax2D

var max_health: float = 0
var special_charge: float = 0
var alert_level: float = 0


func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	building_timer.timeout.connect(_on_building_timer_timeout)
	kaiju.game_scene = self


func _physics_process(delta: float) -> void:
	pass


func move_forward(move_speed: float) -> void:
	back_parallax_2d.scroll_offset.x -= ((move_speed * 0.25) * get_physics_process_delta_time())
	middle_parallax_2d.scroll_offset.x -= ((move_speed * 0.5) * get_physics_process_delta_time())
	front_parallax_2d.scroll_offset.x -= move_speed * get_physics_process_delta_time()
	for child in spawns_node.get_children():
		if is_instance_valid(child):
			child.global_position.x -= move_speed * get_physics_process_delta_time()


func spawn_building() -> void:
	var building_instance = building_resource.instantiate()
	var current_viewport: Vector2 = get_viewport().size
	building_instance.global_position.x = current_viewport.x + 400
	building_instance.global_position.y = building_marker_2d.global_position.y
	spawns_node.add_child(building_instance)


func spawn_soldier() -> void:
	var soldier_instance = soldier_resource.instantiate()
	var current_viewport: Vector2 = get_viewport().size
	soldier_instance.global_position.x = current_viewport.x + 400
	soldier_instance.global_position.y = (
		spawn_marker_2d.global_position.y + GameGlobals.rng.randi_range(-20, 20)
	)
	soldier_instance.kaiju = kaiju
	spawns_node.add_child(soldier_instance)


func spawn_tank() -> void:
	var tank_instance = tank_resource.instantiate()
	var current_viewport: Vector2 = get_viewport().size
	tank_instance.global_position.x = current_viewport.x + 400
	tank_instance.global_position.y = (
		spawn_marker_2d.global_position.y + GameGlobals.rng.randi_range(-20, 20)
	)
	tank_instance.kaiju = kaiju
	spawns_node.add_child(tank_instance)


func spawn_mecha() -> void:
	var mecha_instance = mecha_resource.instantiate()
	var current_viewport: Vector2 = get_viewport().size
	mecha_instance.global_position.x = current_viewport.x + 400
	mecha_instance.global_position.y = (
		spawn_marker_2d.global_position.y + GameGlobals.rng.randi_range(-20, 20)
	)
	mecha_instance.kaiju = kaiju
	spawns_node.add_child(mecha_instance)


func _on_spawn_timer_timeout() -> void:
	if kaiju.walking:
		if GameGlobals.rng.randf_range(0, 1) > 0.5:
			var spawn_type: float = GameGlobals.rng.randf_range(0, 1)
			if spawn_type >= 0.5:
				spawn_soldier()
			elif spawn_type > 0.1 and spawn_type < 0.5:
				spawn_tank()
			elif spawn_type <= 0.1:
				spawn_mecha()


func _on_building_timer_timeout() -> void:
	if kaiju.walking:
		if GameGlobals.rng.randf_range(0, 1) > 0.5:
			spawn_building()
