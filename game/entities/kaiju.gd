extends Node2D

@onready var body_area_2d: Area2D = $Areas/BodyArea2D
@onready var attack_area_2d: Area2D = $Areas/AttackArea2D
@onready var attack_timer: Timer = $AttackTimer

@onready var polygon_2d_2: Polygon2D = $Visuals/Polygon2D2
@onready var polygon_2d_3: Polygon2D = $Visuals/Polygon2D3

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
	polygon_2d_2.modulate.a = 0
	polygon_2d_3.modulate.a = 0


func _process(delta: float) -> void:
	if polygon_2d_2.modulate.a > 0:
		polygon_2d_2.modulate.a -= 2 * delta
	if polygon_2d_3.modulate.a > 0:
		polygon_2d_3.modulate.a -= 2 * delta


func _physics_process(delta: float) -> void:
	if attack_timer.is_stopped():
		if attack_area_2d.has_overlapping_areas():
			var attack_targets: Array[Node2D] = []
			for area in attack_area_2d.get_overlapping_areas():
				var attack_target = area.get_parent().get_parent()
				attack_targets.append(attack_target)
			attack(attack_targets)
		else:
			walk()


func walk() -> void:
	if not walking:
		walking = true
	if is_instance_valid(game_scene):
		game_scene.move_forward(current_move_speed)


func attack(attack_targets: Array[Node2D]) -> void:
	if walking:
		walking = false
	if attack_timer.is_stopped():
		attack_timer.start(current_attack_speed)
		polygon_2d_2.modulate.a = 1
	for attack_target in attack_targets:
		attack_target.damage(current_damage)


func guard() -> void:
	polygon_2d_3.modulate.a = 1


func damage(total_damage: float) -> void:
	if GameGlobals.rng.randf_range(0, 1) < current_guard_rate:
		guard()
	else:
		current_health -= total_damage
