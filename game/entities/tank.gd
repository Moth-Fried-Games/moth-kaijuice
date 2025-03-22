extends Node2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var body_area_2d: Area2D = $Areas/BodyArea2D
@onready var bullet_marker_2d: Marker2D = $BulletMarker2D
@onready var bullet_timer: Timer = $BulletTimer
@onready var gpu_particles_2d: GPUParticles2D = $Visuals/GPUParticles2D
@onready var sprite_2d: Sprite2D = $Visuals/Sprite2D

var health: float = 200
var kill_timer: float = 0
var entered_screen: bool = false
var dead: bool = false
var kaiju: Node2D = null
var cost: float = 5000

func _ready() -> void:
	if not is_in_group("tank"):
		add_to_group("tank")

func _process(_delta: float) -> void:
	if sprite_2d.modulate != Color.WHITE:
		await get_tree().create_timer(0.05).timeout
		sprite_2d.modulate = Color.WHITE

func _physics_process(delta: float) -> void:
	if visible_on_screen_notifier_2d.is_on_screen():
		if not entered_screen:
			entered_screen = true
		if kill_timer != 0:
			kill_timer = 0
		if bullet_timer.is_stopped() and not dead and not kaiju.shrunk:
			bullet_timer.start(GameGlobals.rng.randf_range(2, 3))
			shoot()
	else:
		if entered_screen:
			kill_timer += delta

	if kill_timer > 5:
		queue_free()


func damage(total_damage: float) -> void:
	health -= total_damage
	health = clampf(health,0,INF)
	if health <= 0:
		die()
	sprite_2d.modulate = Color(2,2,2,1)


func die() -> void:
	if not dead:
		dead = true
		kaiju.charge(2)
		kaiju.loot(cost)
		body_area_2d.queue_free()
		gpu_particles_2d.emitting = true
		sprite_2d.visible = false


func shoot() -> void:
	var bullet_instance = GameGlobals.big_bullet_resource.instantiate()
	var kaiju_direction = kaiju.global_position
	kaiju_direction.y = kaiju_direction.y - 100 - GameGlobals.rng.randf_range(0, 100)
	bullet_instance.direction = bullet_marker_2d.global_position.direction_to(kaiju_direction)
	bullet_instance.global_position = bullet_marker_2d.global_position
	bullet_instance.damage = 4
	get_parent().add_child(bullet_instance)
