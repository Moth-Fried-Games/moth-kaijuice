extends Node2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var kill_timer: float = 0
var entered_screen: bool = false
var dead: bool = false

func _ready() -> void:
	if not is_in_group("building"):
		add_to_group("building")

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
