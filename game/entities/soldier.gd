extends Node2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var body_area_2d: Area2D = $Areas/BodyArea2D

var kill_timer: float = 0
var entered_screen: bool = false
var dead: bool = false


func _ready() -> void:
	if not is_in_group("smallenemy"):
		add_to_group("smallenemy")


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

	if body_area_2d.has_overlapping_areas():
		for area in body_area_2d.get_overlapping_areas():
			if area.get_parent().is_in_group("kaiju"):
				if not dead:
					dead = true
