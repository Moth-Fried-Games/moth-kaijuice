extends Node2D

@onready var body_area_2d: Area2D = $Areas/BodyArea2D
@onready var attack_area_2d: Area2D = $Areas/AttackArea2D
@onready var animated_sprite_2d: AnimatedSprite2D = $Visuals/AnimatedSprite2D
@onready var guard_animated_sprite_2d: AnimatedSprite2D = $Visuals/GuardAnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var beam_animation_player: AnimationPlayer = $BeamAnimationPlayer

var base_health: float = 500
var base_damage: float = 50
var base_move_speed: float = 100
var base_attack_speed: float = 1
var base_guard_rate: float = 0.1
var base_special_cooldown: float = 100

var current_health: float = base_health
var current_damage: float = base_damage
var current_move_speed: float = base_move_speed
var current_attack_speed: float = base_attack_speed
var current_guard_rate: float = base_guard_rate
var current_special_cooldown: float = base_special_cooldown

var game_scene: Node2D = null
var walking: bool = false
var punching: bool = false
var kicking: bool = false
var grown: bool = false
var shrunk: bool = false
var shooting: bool = false
var discharging: bool = false
var walk_step: bool = false


func _ready() -> void:
	if not is_in_group("kaiju"):
		add_to_group("kaiju")
	guard_animated_sprite_2d.modulate.a = 0
	animated_sprite_2d.play("idle")
	current_health = (
		base_health
		+ (base_health * GameGlobals.vial_data["durability"])
		+ (base_health * GameGlobals.vial_data["beta"])
	)
	current_damage = (
		base_damage
		+ (base_damage * GameGlobals.vial_data["power"])
		+ (base_damage * GameGlobals.vial_data["alpha"])
	)
	current_move_speed = (
		base_move_speed
		+ (base_move_speed * GameGlobals.vial_data["speed"])
		+ (base_move_speed * GameGlobals.vial_data["gamma"])
	)
	current_attack_speed = (
		base_attack_speed
		+ (base_attack_speed * GameGlobals.vial_data["dexterity"])
		+ (base_attack_speed * GameGlobals.vial_data["gamma"])
	)
	current_guard_rate = (
		base_guard_rate
		+ (base_guard_rate * GameGlobals.vial_data["guard"])
		+ (base_guard_rate * GameGlobals.vial_data["beta"])
	)
	current_special_cooldown = (
		base_special_cooldown
		- (base_special_cooldown * GameGlobals.vial_data["special"])
		- (base_special_cooldown * GameGlobals.vial_data["alpha"])
	)
	current_special_cooldown = clampf(current_special_cooldown, 0, INF)


func _process(delta: float) -> void:
	if guard_animated_sprite_2d.modulate.a > 0:
		guard_animated_sprite_2d.modulate.a -= 2 * delta
	walk_sounds()


func walk_sounds() -> void:
	var step: bool = false
	if animated_sprite_2d.animation == "walk":
		if not walk_step:
			if animated_sprite_2d.frame == 3:
				step = true
				walk_step = true
		else:
			if animated_sprite_2d.frame == 0:
				step = true
				walk_step = false
		if step:
			GameGlobals.audio_manager.create_2d_audio_at_location(
				"sound_city_walk", global_position
			)


func _physics_process(_delta: float) -> void:
	if (
		grown
		and not shrunk
		and not shooting
		and not discharging
		and not animation_player.is_playing()
		and not game_scene.nuke_step > 1
	):
		if is_instance_valid(attack_area_2d):
			if attack_area_2d.has_overlapping_areas():
				if animated_sprite_2d.animation == "walk" or not animated_sprite_2d.is_playing():
					var attack_targets: Array[Node2D] = []
					for area in attack_area_2d.get_overlapping_areas():
						var attack_target = area.get_parent().get_parent()
						if attack_target.is_in_group("tank"):
							kicking = true
						attack_targets.append(attack_target)
					await attack(attack_targets)
			else:
				walk()

	if grown and shooting:
		shooting = false
		await beam()

	if not grown:
		grown = true
		await grow()


func grow() -> void:
	animation_player.play("start")
	await animation_player.animation_finished
	animation_player.play("grow")
	GameGlobals.audio_manager.create_2d_audio_at_location("sound_city_grow", global_position)
	await animation_player.animation_finished


func beam() -> void:
	if walking:
		walking = false
	discharging = true
	animated_sprite_2d.speed_scale = 1
	GameGlobals.audio_manager.create_2d_audio_at_location("sound_city_special", global_position)
	animated_sprite_2d.play("beam_start")
	await animated_sprite_2d.animation_finished
	game_scene.beam()
	animated_sprite_2d.play("beam_loop")
	beam_animation_player.play("grow")
	await beam_animation_player.animation_finished
	await get_tree().create_timer(1).timeout
	beam_animation_player.play("shrink")
	await beam_animation_player.animation_finished
	animated_sprite_2d.play("beam_end")
	await animated_sprite_2d.animation_finished
	animated_sprite_2d.play("idle")
	discharging = false


func walk() -> void:
	if not walking:
		walking = true
		animated_sprite_2d.play("walk")
		animated_sprite_2d.speed_scale = (current_move_speed / base_move_speed)
	if is_instance_valid(game_scene):
		game_scene.move_forward(current_move_speed)


func attack(attack_targets: Array[Node2D]) -> void:
	if walking:
		walking = false
	if kicking:
		kicking = false
		animated_sprite_2d.play("kick")
		animated_sprite_2d.speed_scale = current_attack_speed
	else:
		if punching:
			punching = !punching
			animated_sprite_2d.play("punch_left")
			animated_sprite_2d.speed_scale = current_attack_speed
		else:
			punching = !punching
			animated_sprite_2d.play("punch_right")
			animated_sprite_2d.speed_scale = current_attack_speed
	await animated_sprite_2d.animation_finished
	for attack_target in attack_targets:
		attack_target.damage(current_damage)


func guard() -> void:
	guard_animated_sprite_2d.modulate.a = 1
	GameGlobals.audio_manager.create_2d_audio_at_location("sound_city_guard", global_position)


func damage(total_damage: float) -> void:
	if GameGlobals.rng.randf_range(0, 1) < current_guard_rate:
		guard()
	elif shooting or discharging:
		guard()
	else:
		current_health -= total_damage
		current_health = clampf(current_health, 0, INF)
		if total_damage >= 1.5:
			GameGlobals.audio_manager.create_2d_audio_at_location(
				"sound_city_roar", global_position
			)
		if current_health <= 0:
			if not shrunk:
				shrunk = true
				body_area_2d.queue_free()
				attack_area_2d.queue_free()
				animated_sprite_2d.play("idle")
				animation_player.play("shrink")
				GameGlobals.audio_manager.create_2d_audio_at_location(
					"sound_city_shrink", global_position
				)
				await animation_player.animation_finished
				game_scene.back_to_lab()


func charge(value: float) -> void:
	game_scene.special_charge += value
	game_scene.special_charge = clampf(game_scene.special_charge, 0, current_special_cooldown)


func loot(value: float) -> void:
	game_scene.damage_pay += value
	game_scene.alert_level += (value / 1000)
