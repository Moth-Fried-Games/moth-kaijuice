extends Node2D

var building_resource: Resource = preload("res://game/entities/building.tscn")
var soldier_resource: Resource = preload("res://game/entities/soldier.tscn")
var tank_resource: Resource = preload("res://game/entities/tank.tscn")
var mecha_resource: Resource = preload("res://game/entities/mecha.tscn")

@onready
var health_bar_sprite_2d: Sprite2D = $UI/Game/HealthMarginContainer/HealthMaskSprite2D/HealthBarSprite2D
@onready
var special_bar_sprite_2d: Sprite2D = $UI/Game/SpecialMarginContainer/Polygon2D/SpecialBarSprite2D
@onready
var beam_animated_sprite_2d: AnimatedSprite2D = $UI/Game/BeamMarginContainer/BeamAnimatedSprite2D
@onready var alert_led_sprite_2d_1: Sprite2D = $UI/Game/AlertMarginContainer/AlertLEDSprite2D1
@onready var alert_led_sprite_2d_2: Sprite2D = $UI/Game/AlertMarginContainer/AlertLEDSprite2D2
@onready var alert_led_sprite_2d_3: Sprite2D = $UI/Game/AlertMarginContainer/AlertLEDSprite2D3
@onready var alert_led_sprite_2d_4: Sprite2D = $UI/Game/AlertMarginContainer/AlertLEDSprite2D4
@onready var alert_led_sprite_2d_5: Sprite2D = $UI/Game/AlertMarginContainer/AlertLEDSprite2D5
@onready var blink_timer: Timer = $BlinkTimer

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
@onready var building_area_2d: Area2D = $BuildingMarker2D/BuildingArea2D
@onready var spawn_area_2d: Area2D = $SpawnMarker2D/SpawnArea2D

var damage_pay: float = 0
var max_health: float = 0
var special_charge: float = 0
var alert_level: float = 0
var alert_base: float = 800
var alert_min: float = 0
var alert_max: float = 0
var building_spawn: bool = false
var enemy_spawn: bool = false


func _ready() -> void:
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	building_timer.timeout.connect(_on_building_timer_timeout)
	kaiju.game_scene = self
	max_health = kaiju.current_health


func _process(_delta: float) -> void:
	update_health()
	update_special()
	update_alert()


func update_health() -> void:
	var health_percentage: float = kaiju.current_health / max_health
	var health_bar_y: float = 34 * (1 - health_percentage)
	health_bar_sprite_2d.position.y = health_bar_y


func update_special() -> void:
	var special_percentage: float = special_charge / kaiju.current_special_cooldown
	var special_rotation: float = (180 * special_percentage) - 90
	special_bar_sprite_2d.rotation_degrees = special_rotation
	if special_percentage >= 1:
		beam_animated_sprite_2d.visible = true
	else:
		beam_animated_sprite_2d.visible = false


func update_alert() -> void:
	if alert_level < alert_base:
		if alert_max != alert_base:
			alert_min = 0
			alert_max = alert_base
		blink_alert(alert_led_sprite_2d_5)
		alert_led_sprite_2d_4.visible = false
		alert_led_sprite_2d_3.visible = false
		alert_led_sprite_2d_2.visible = false
		alert_led_sprite_2d_1.visible = false
	elif alert_level >= alert_base and alert_level < alert_base * 2:
		if alert_max != alert_base * 2:
			alert_min = alert_base
			alert_max = alert_base * 2
		alert_led_sprite_2d_5.visible = true
		blink_alert(alert_led_sprite_2d_4)
		alert_led_sprite_2d_3.visible = false
		alert_led_sprite_2d_2.visible = false
		alert_led_sprite_2d_1.visible = false
	elif alert_level >= alert_base * 2 and alert_level < alert_base * 4:
		if alert_max != alert_base * 4:
			alert_min = alert_base * 2
			alert_max = alert_base * 4
		alert_led_sprite_2d_5.visible = true
		alert_led_sprite_2d_4.visible = true
		blink_alert(alert_led_sprite_2d_3)
		alert_led_sprite_2d_2.visible = false
		alert_led_sprite_2d_1.visible = false
	elif alert_level >= alert_base * 4 and alert_level < alert_base * 8:
		if alert_max != alert_base * 8:
			alert_min = alert_base * 4
			alert_max = alert_base * 8
		alert_led_sprite_2d_5.visible = true
		alert_led_sprite_2d_4.visible = true
		alert_led_sprite_2d_3.visible = true
		blink_alert(alert_led_sprite_2d_2)
		alert_led_sprite_2d_1.visible = false
	elif alert_level >= alert_base * 8 and alert_level < alert_base * 16:
		if alert_max != alert_base * 16:
			alert_min = alert_base * 8
			alert_max = alert_base * 16
		alert_led_sprite_2d_5.visible = true
		alert_led_sprite_2d_4.visible = true
		alert_led_sprite_2d_3.visible = true
		alert_led_sprite_2d_2.visible = true
		blink_alert(alert_led_sprite_2d_1)
	elif alert_level >= alert_base:
		alert_led_sprite_2d_5.visible = true
		alert_led_sprite_2d_4.visible = true
		alert_led_sprite_2d_3.visible = true
		alert_led_sprite_2d_2.visible = true
		alert_led_sprite_2d_1.visible = true


func blink_alert(alert_led: Node2D) -> void:
	if blink_timer.is_stopped():
		alert_led.visible = not alert_led.visible
		var blink_interval: float = 1 - ((alert_level - alert_min) / (alert_max - alert_min))
		blink_timer.start(0.2 + (blink_interval * 0.8))


func _physics_process(_delta: float) -> void:
	if spawn_marker_2d.global_position.x != (get_viewport().size.x + 200):
		spawn_marker_2d.global_position.x = (get_viewport().size.x + 200)
	if building_marker_2d.global_position.x != (get_viewport().size.x + 200):
		building_marker_2d.global_position.x = (get_viewport().size.x + 200)
	if building_area_2d.has_overlapping_areas():
		if building_spawn:
			building_spawn = false
	else:
		if not building_spawn:
			building_spawn = true
		if building_timer.is_stopped():
			building_timer.start()
	if spawn_area_2d.has_overlapping_areas():
		if enemy_spawn:
			enemy_spawn = false
	else:
		if not enemy_spawn:
			enemy_spawn = true
		if spawn_timer.is_stopped():
			spawn_timer.start()


func move_forward(move_speed: float) -> void:
	back_parallax_2d.scroll_offset.x -= ((move_speed * 0.25) * get_physics_process_delta_time())
	middle_parallax_2d.scroll_offset.x -= ((move_speed * 0.5) * get_physics_process_delta_time())
	front_parallax_2d.scroll_offset.x -= move_speed * get_physics_process_delta_time()
	for child in spawns_node.get_children():
		if is_instance_valid(child):
			child.global_position.x -= move_speed * get_physics_process_delta_time()


func spawn_building() -> void:
	var building_instance = building_resource.instantiate()
	building_instance.global_position.x = building_marker_2d.global_position.x
	building_instance.global_position.y = building_marker_2d.global_position.y
	building_instance.kaiju = kaiju
	spawns_node.add_child(building_instance)


func spawn_soldier() -> void:
	var soldier_instance = soldier_resource.instantiate()
	soldier_instance.global_position.x = building_marker_2d.global_position.x
	soldier_instance.global_position.y = (
		spawn_marker_2d.global_position.y + GameGlobals.rng.randi_range(-10, 30)
	)
	soldier_instance.kaiju = kaiju
	spawns_node.add_child(soldier_instance)


func spawn_tank() -> void:
	var tank_instance = tank_resource.instantiate()
	tank_instance.global_position.x = building_marker_2d.global_position.x
	tank_instance.global_position.y = (
		spawn_marker_2d.global_position.y + GameGlobals.rng.randi_range(-10, 30)
	)
	tank_instance.kaiju = kaiju
	spawns_node.add_child(tank_instance)


func spawn_mecha() -> void:
	var mecha_instance = mecha_resource.instantiate()
	mecha_instance.global_position.x = building_marker_2d.global_position.x
	mecha_instance.global_position.y = (
		spawn_marker_2d.global_position.y + GameGlobals.rng.randi_range(-10, 30)
	)
	mecha_instance.kaiju = kaiju
	spawns_node.add_child(mecha_instance)


func _on_spawn_timer_timeout() -> void:
	if kaiju.walking:
		if GameGlobals.rng.randf_range(0, 1) >= 0.33:
			var spawn_type: float = GameGlobals.rng.randf_range(0, 1)
			if spawn_type >= 0.5:
				spawn_soldier()
			elif spawn_type > 0.1 and spawn_type < 0.5:
				if enemy_spawn:
					spawn_tank()
			elif spawn_type <= 0.1:
				if enemy_spawn:
					spawn_mecha()


func _on_building_timer_timeout() -> void:
	if kaiju.walking and building_spawn:
		if GameGlobals.rng.randf_range(0, 1) >= 0.33:
			spawn_building()
