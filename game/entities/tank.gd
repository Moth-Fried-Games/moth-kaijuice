extends Node2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var body_area_2d: Area2D = $Areas/BodyArea2D
@onready var bullet_marker_2d: Marker2D = $BulletMarker2D
@onready var bullet_timer: Timer = $BulletTimer

var health: float = 200
var kill_timer: float = 0
var entered_screen: bool = false
var dead: bool = false
var kaiju: Node2D = null


func _ready() -> void:
	if not is_in_group("bigenemy"):
		add_to_group("bigenemy")


func _physics_process(delta: float) -> void:
	if visible_on_screen_notifier_2d.is_on_screen():
		if not entered_screen:
			entered_screen = true
		if kill_timer != 0:
			kill_timer = 0
		if bullet_timer.is_stopped():
			bullet_timer.start(GameGlobals.rng.randf_range(2, 3))
			shoot()
	else:
		if entered_screen:
			kill_timer += delta

	if kill_timer > 5:
		queue_free()


func damage(total_damage: float) -> void:
	health -= total_damage
	if health <= 0:
		if not dead:
			dead = true
			queue_free()


func shoot() -> void:
	var bullet_instance = GameGlobals.big_bullet_resource.instantiate()
	var kaiju_direction = kaiju.global_position
	kaiju_direction.y = kaiju_direction.y - 100 - GameGlobals.rng.randf_range(0, 100)
	bullet_instance.direction = bullet_marker_2d.global_position.direction_to(kaiju_direction)
	bullet_instance.global_position = bullet_marker_2d.global_position
	bullet_instance.damage = 4
	get_parent().add_child(bullet_instance)
