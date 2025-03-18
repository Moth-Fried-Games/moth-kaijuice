extends Node2D

@onready var body_area_2d: Area2D = $Areas/BodyArea2D
@onready var attack_area_2d: Area2D = $Areas/AttackArea2D

var base_health: float = 1000
var base_damage: float = 100
var base_move_speed: float = 100
var base_attack_speed: float = 1
var base_guard_rate: float = 0.1
var base_special_cooldown: float = 120

var current_health: float = base_health
var current_damage: float = base_damage
var current_move_speed: float = base_move_speed
var current_attack_speed: float = base_attack_speed
var current_guard_rate: float = base_guard_rate
var current_special_cooldown: float = base_special_cooldown

var game_scene: Node2D = null
var walking: bool = false


func _ready() -> void:
	if not is_in_group("kaiju"):
		add_to_group("kaiju")


func _physics_process(delta: float) -> void:
	if attack_area_2d.has_overlapping_areas():
		for area in attack_area_2d.get_overlapping_areas():
			var attack_target = area.get_parent()
			attack(attack_target)
	else:
		walk()


func walk() -> void:
	if not walking:
		walking = true
	if is_instance_valid(game_scene):
		game_scene.move_spawns()


func attack(attack_target: Node2D) -> void:
	if walking:
		walking = false
