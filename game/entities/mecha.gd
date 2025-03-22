extends Node2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var body_area_2d: Area2D = $Areas/BodyArea2D
@onready var bullet_marker_2d: Marker2D = $BulletMarker2D
@onready var bullet_timer: Timer = $BulletTimer
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_area_2d: Area2D = $Areas/AttackArea2D
@onready var polygon_2d_2: Polygon2D = $Visuals/Polygon2D2

var health: float = 400
var kill_timer: float = 0
var entered_screen: bool = false
var dead: bool = false
var kaiju: Node2D = null
var melee_damage: float = 10
var cost: float = 150000


func _ready() -> void:
	if not is_in_group("mecha"):
		add_to_group("mecha")
	polygon_2d_2.modulate.a = 0


func _process(delta: float) -> void:
	if polygon_2d_2.modulate.a > 0:
		polygon_2d_2.modulate.a -= 2 * delta


func _physics_process(delta: float) -> void:
	if visible_on_screen_notifier_2d.is_on_screen():
		if not entered_screen:
			entered_screen = true
		if kill_timer != 0:
			kill_timer = 0
		if attack_timer.is_stopped() and not dead and not kaiju.shrunk:
			if attack_area_2d.has_overlapping_areas():
				var attack_targets: Array[Node2D] = []
				for area in attack_area_2d.get_overlapping_areas():
					var attack_target = area.get_parent().get_parent()
					attack_targets.append(attack_target)
				attack(attack_targets)
			else:
				if bullet_timer.is_stopped() and not dead and not kaiju.shrunk:
					bullet_timer.start(5)
					shoot()
	else:
		if entered_screen:
			kill_timer += delta

	if kill_timer > 5:
		queue_free()


func damage(total_damage: float) -> void:
	health -= total_damage
	health = clampf(health, 0, INF)
	if health <= 0:
		if not dead:
			dead = true
			die()


func die() -> void:
	kaiju.charge(3)
	kaiju.loot(cost)
	queue_free()


func shoot() -> void:
	var bullet_instance = GameGlobals.big_bullet_resource.instantiate()
	var kaiju_direction = kaiju.global_position
	kaiju_direction.y = kaiju_direction.y - 100 - GameGlobals.rng.randf_range(0, 100)
	bullet_instance.direction = bullet_marker_2d.global_position.direction_to(kaiju_direction)
	bullet_instance.global_position = bullet_marker_2d.global_position
	bullet_instance.damage = 4
	get_parent().add_child(bullet_instance)


func attack(attack_targets: Array[Node2D]) -> void:
	if attack_timer.is_stopped():
		attack_timer.start()
		polygon_2d_2.modulate.a = 1
	for attack_target in attack_targets:
		attack_target.damage(melee_damage)
