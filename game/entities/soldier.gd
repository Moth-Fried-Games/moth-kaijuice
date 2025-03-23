extends Node2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var body_area_2d: Area2D = $Areas/BodyArea2D
@onready var bullet_marker_2d: Marker2D = $BulletMarker2D
@onready var bullet_timer: Timer = $BulletTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var kill_timer: float = 0
var entered_screen: bool = false
var dead: bool = false
var kaiju: Node2D = null
var cost: float = 1000


func _ready() -> void:
	if not is_in_group("soldier"):
		add_to_group("soldier")
	animation_player.play("RESET")


func _physics_process(delta: float) -> void:
	if visible_on_screen_notifier_2d.is_on_screen():
		if not entered_screen:
			entered_screen = true
		if kill_timer != 0:
			kill_timer = 0
		if entered_screen and bullet_timer.is_stopped() and not dead and not kaiju.shrunk:
			bullet_timer.start(GameGlobals.rng.randf_range(1, 2))
			shoot()
	else:
		if entered_screen:
			kill_timer += delta

	if kill_timer > 5:
		queue_free()

	if is_instance_valid(body_area_2d):
		if body_area_2d.has_overlapping_areas():
			for area in body_area_2d.get_overlapping_areas():
				var hit_target = area.get_parent().get_parent()
				if hit_target.is_in_group("kaiju"):
					die()


func damage(_total_damage: float) -> void:
	die()


func die() -> void:
	if not dead:
		dead = true
		kaiju.charge(1)
		kaiju.loot(cost)
		body_area_2d.queue_free()
		animation_player.play("die")


func shoot() -> void:
	GameGlobals.audio_manager.create_2d_audio_at_location(
		"sound_city_soldier_shoot", global_position
	)
	var bullet_instance = GameGlobals.bullet_resource.instantiate()
	var kaiju_direction = kaiju.global_position
	kaiju_direction.y = kaiju_direction.y - 100 - GameGlobals.rng.randf_range(0, 100)
	bullet_instance.direction = bullet_marker_2d.global_position.direction_to(kaiju_direction)
	bullet_instance.global_position = bullet_marker_2d.global_position
	get_parent().add_child(bullet_instance)
