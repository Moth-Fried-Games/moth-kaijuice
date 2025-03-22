extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var big_sprite_2d: Sprite2D = $Visuals/Polygon2D/BigSprite2D
@onready var middle_sprite_2d: Sprite2D = $Visuals/Polygon2D/MiddleSprite2D
@onready var small_sprite_2d: Sprite2D = $Visuals/Polygon2D/SmallSprite2D
@onready var dead_sprite_2d: Sprite2D = $Visuals/Polygon2D/DeadSprite2D
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var body_area_2d: Area2D = $Areas/BodyArea2D

var health: float = 400
var kill_timer: float = 0
var entered_screen: bool = false
var dead: bool = false
var size: int = 1
var kaiju: Node2D = null
var cost: float = 1000


func _ready() -> void:
	if not is_in_group("building"):
		add_to_group("building")
		animation_player.play("RESET")
	var building_size: float = GameGlobals.rng.randf_range(0, 1)
	if building_size >= 0.5:
		size = 1
	elif building_size > 0.1 and building_size < 0.5:
		size = 2
	elif building_size <= 0.1:
		size = 3
	match size:
		1:
			middle_sprite_2d.visible = false
			big_sprite_2d.visible = false
			health = 150
			cost = 2500
		2:
			small_sprite_2d.visible = false
			big_sprite_2d.visible = false
			health = 200
			cost = 7500
		3:
			small_sprite_2d.visible = false
			middle_sprite_2d.visible = false
			health = 300
			cost = 10000


func _physics_process(delta: float) -> void:
	if visible_on_screen_notifier_2d.is_on_screen():
		if not entered_screen:
			entered_screen = true
		if kill_timer != 0:
			kill_timer = 0
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
	body_area_2d.queue_free()
	match size:
		1:
			kaiju.charge(1)
			kaiju.loot(cost)
			animation_player.play("small_dead")
		2:
			kaiju.charge(2)
			kaiju.loot(cost)
			animation_player.play("middle_dead")
		3:
			kaiju.charge(3)
			kaiju.loot(cost)
			animation_player.play("big_dead")
