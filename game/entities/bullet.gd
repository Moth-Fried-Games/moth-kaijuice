extends Node2D

@onready var gpu_particles_2d: GPUParticles2D = $Visuals/GPUParticles2D
@onready var area_2d: Area2D = $Areas/Area2D
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var bullet_speed: float = 200
var direction: Vector2 = Vector2.LEFT
var damage: float = 1
var dead: bool = false
var kill_timer: float = 0


func _physics_process(delta: float) -> void:
	global_position += bullet_speed * direction * delta

	if area_2d.has_overlapping_areas():
		for area in area_2d.get_overlapping_areas():
			var hit_target = area.get_parent().get_parent()
			if hit_target.is_in_group("kaiju"):
				if not dead:
					dead = true
					hit_target.damage(damage)
					queue_free()

	if visible_on_screen_notifier_2d.is_on_screen():
		if kill_timer != 0:
			kill_timer = 0
	else:
		kill_timer += delta

	if kill_timer > 5:
		queue_free()
