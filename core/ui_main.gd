extends CanvasLayer

var ui_frame_rate: UIFrameRate = preload("res://core/ui/ui_frame_rate.tscn").instantiate()

var ui_transitions: UITransitions = preload("res://core/ui/ui_transitions.tscn").instantiate()


func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS

	ui_frame_rate.layer = 127
	add_child(ui_frame_rate)

	ui_transitions.layer = 98
	add_child(ui_transitions)
