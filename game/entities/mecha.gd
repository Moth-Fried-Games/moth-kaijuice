extends Node2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var body_area_2d: Area2D = $Areas/BodyArea2D
@onready var bullet_marker_2d: Marker2D = $BulletMarker2D
@onready var bullet_timer: Timer = $BulletTimer
@onready var attack_area_2d: Area2D = $Areas/AttackArea2D
@onready var animated_sprite_2d: AnimatedSprite2D = $Visuals/AnimatedSprite2D
@onready var line_2d: Line2D = $Visuals/Line2D
@onready var gpu_particles_2d: GPUParticles2D = $Visuals/GPUParticles2D

var health: float = 200
var kill_timer: float = 0
var entered_screen: bool = false
var dead: bool = false
var kaiju: Node2D = null
var range_damage: float = 10
var melee_damage: float = 4
var cost: float = 150000


func _ready() -> void:
	if not is_in_group("mecha"):
		add_to_group("mecha")
	health += GameGlobals.rng.randf_range(-(health / 2), health / 2)
	range_damage += GameGlobals.rng.randf_range(-(range_damage / 2), range_damage / 2)
	melee_damage += GameGlobals.rng.randf_range(-(melee_damage / 2), melee_damage / 2)


func _process(_delta: float) -> void:
	if animated_sprite_2d.modulate != Color.WHITE:
		await get_tree().create_timer(0.05).timeout
		animated_sprite_2d.modulate = Color.WHITE


func _physics_process(delta: float) -> void:
	if visible_on_screen_notifier_2d.is_on_screen():
		if not entered_screen:
			entered_screen = true
		if kill_timer != 0:
			kill_timer = 0
		if entered_screen and not dead and not kaiju.shrunk:
			if attack_area_2d.has_overlapping_areas():
				if animated_sprite_2d.animation == "idle" or not animated_sprite_2d.is_playing():
					var attack_targets: Array[Node2D] = []
					for area in attack_area_2d.get_overlapping_areas():
						var attack_target = area.get_parent().get_parent()
						attack_targets.append(attack_target)
					await attack(attack_targets)
			else:
				if bullet_timer.is_stopped() and not dead and not kaiju.shrunk:
					bullet_timer.start(6)
					await shoot()
	else:
		if entered_screen:
			kill_timer += delta

	if kill_timer > 5:
		queue_free()


func damage(total_damage: float) -> void:
	health -= total_damage
	health = clampf(health, 0, INF)
	GameGlobals.audio_manager.create_2d_audio_at_location(
		"sound_city_mecha_damage", global_position
	)
	if health <= 0:
		die()
	animated_sprite_2d.modulate = Color(2, 2, 2, 1)


func die() -> void:
	if not dead:
		dead = true
		GameGlobals.audio_manager.create_2d_audio_at_location(
			"sound_city_mecha_death", global_position
		)
		kaiju.charge(3)
		kaiju.loot(cost)
		attack_area_2d.queue_free()
		body_area_2d.queue_free()
		gpu_particles_2d.emitting = true
		animated_sprite_2d.visible = false


func shoot() -> void:
	GameGlobals.audio_manager.create_2d_audio_at_location(
		"sound_city_mecha_charge", global_position
	)
	animated_sprite_2d.play("shoot_start")
	await animated_sprite_2d.animation_finished
	GameGlobals.audio_manager.create_2d_audio_at_location("sound_city_mecha_shoot", global_position)
	var kaiju_direction = kaiju.global_position
	kaiju_direction.y = kaiju_direction.y - 100 - GameGlobals.rng.randf_range(0, 100)
	line_2d.global_position = Vector2.ZERO
	line_2d.clear_points()
	line_2d.add_point(line_2d.to_local(global_position + Vector2(3, -214)))
	line_2d.add_point(line_2d.to_local(kaiju_direction))
	await get_tree().create_timer(0.1).timeout
	line_2d.clear_points()
	kaiju.damage(range_damage)
	animated_sprite_2d.play("shoot_end")
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("idle")


func attack(attack_targets: Array[Node2D]) -> void:
	animated_sprite_2d.play("melee")
	await animated_sprite_2d.animation_finished
	for attack_target in attack_targets:
		attack_target.damage(melee_damage)
