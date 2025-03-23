extends Node2D

var lab_music: AudioStreamPlayer = null
var chem_sound: AudioStreamPlayer = null

@onready
var mixer_sprite_2d: Sprite2D = $CanvasLayer/Control/ChemicalControl/MixerMaskSprite2D/MixerSprite2D
@onready var alpha_button: Button = $CanvasLayer/Control/ChemicalControl/AlphaButton
@onready var gamma_button: Button = $CanvasLayer/Control/ChemicalControl/GammaButton
@onready var beta_button: Button = $CanvasLayer/Control/ChemicalControl/BetaButton
@onready var power_button: Button = $CanvasLayer/Control/ChemicalControl/PowerButton
@onready var speed_button: Button = $CanvasLayer/Control/ChemicalControl/SpeedButton
@onready var durability_button: Button = $CanvasLayer/Control/ChemicalControl/DurabilityButton
@onready var special_button: Button = $CanvasLayer/Control/ChemicalControl/SpecialButton
@onready var dexterity_button: Button = $CanvasLayer/Control/ChemicalControl/DexterityButton
@onready var guard_button: Button = $CanvasLayer/Control/ChemicalControl/GuardButton
@onready var vial_tooltip_control: Control = $CanvasLayer/Control/ChemicalControl/VialTooltipControl
@onready var juice_buttons: Array[Button] = [
	alpha_button,
	gamma_button,
	beta_button,
	power_button,
	speed_button,
	durability_button,
	special_button,
	dexterity_button,
	guard_button
]

@onready
var tv_animated_sprite_2d: AnimatedSprite2D = $CanvasLayer/Control/TVControl/TVAnimatedSprite2D

@onready var button_sprite_2d_1: Sprite2D = $CanvasLayer/Control/ButtonControl/ButtonSprite2D1
@onready var button_sprite_2d_2: Sprite2D = $CanvasLayer/Control/ButtonControl/ButtonSprite2D2
@onready var start_button: Button = $CanvasLayer/Control/ButtonControl/StartButton
@onready
var start_tooltip_control: Control = $CanvasLayer/Control/ButtonControl/StartButton/StartTooltipControl
@onready
var vial_rich_text_label: RichTextLabel = $CanvasLayer/Control/ChemicalControl/VialTooltipControl/VialRichTextLabel

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2
@onready var animation_player_3: AnimationPlayer = $AnimationPlayer3
@onready var juice_timer: Timer = $JuiceTimer

var mixer_tween: Tween = null
var button_pressed: bool = false
var juice_down: bool = false

var mixer_colors: Dictionary = {
	"durability": "285cc4",
	"speed": "59c135",
	"power": "b4202a",
	"alpha": "b3b9d1",
	"gamma": "793a80",
	"beta": "4a5462",
	"special": "1dc6b8",
	"dexterity": "bc4a9b",
	"guard": "e9c23a",
	"vial": "18b435"
}

var mixer_dict: Dictionary = {
	"durability": {"amount": 0, "price": 1000, "increase": 1},
	"speed": {"amount": 0, "price": 1000, "increase": 1},
	"power": {"amount": 0, "price": 1000, "increase": 1},
	"alpha": {"amount": 0, "price": 1000, "increase": 1},
	"gamma": {"amount": 0, "price": 1000, "increase": 1},
	"beta": {"amount": 0, "price": 1000, "increase": 1},
	"special": {"amount": 0, "price": 1000, "increase": 1},
	"dexterity": {"amount": 0, "price": 1000, "increase": 1},
	"guard": {"amount": 0, "price": 1000, "increase": 1}
}
var mixer_attribute: String = "Attribute"
var mixer_amount: String = "0 ml"
var mixer_money: String = "$0"

var input_ready: bool = false


func _ready() -> void:
	for juice_button in juice_buttons:
		juice_button.button_down.connect(_on_juice_button_button_down)
		juice_button.button_up.connect(_on_juice_button_button_up)
		juice_button.mouse_exited.connect(_on_juice_button_mouse_exited)
	start_tooltip_control.visible = false
	vial_tooltip_control.visible = false
	GameGlobals.lab_screen = true
	UiMain.ui_transitions.toggle_transition(false)
	lab_music = GameGlobals.audio_manager.create_persistent_audio("music_lab")
	animation_player.play("mixer_fill")
	await animation_player.animation_finished
	input_ready = true


func _process(_delta: float) -> void:
	if not tv_animated_sprite_2d.is_playing():
		if GameGlobals.rng.randf_range(0, 1) > 0.05:
			tv_animated_sprite_2d.play("idle")
		else:
			tv_animated_sprite_2d.play("blink")

	if juice_down:
		if juice_timer.is_stopped():
			if mixer_dict.has(mixer_attribute.to_lower()):
				var total_cost: int = (
					mixer_dict[mixer_attribute.to_lower()]["price"]
					* mixer_dict[mixer_attribute.to_lower()]["increase"]
				)
				if GameGlobals.total_money >= total_cost:
					juice_timer.start()
					if not is_instance_valid(chem_sound):
						chem_sound = GameGlobals.audio_manager.create_persistent_audio(
							"sound_lab_chems"
						)
					mixer_dict[mixer_attribute.to_lower()]["amount"] += 1
					GameGlobals.total_money -= total_cost

					if (
						mixer_dict[mixer_attribute.to_lower()]["amount"]
						>= (mixer_dict[mixer_attribute.to_lower()]["increase"] * 10)
					):
						mixer_dict[mixer_attribute.to_lower()]["increase"] *= 2
					if mixer_sprite_2d.modulate != Color(mixer_colors[mixer_attribute.to_lower()]):
						if not is_instance_valid(mixer_tween):
							mixer_tween = get_tree().create_tween()
							mixer_tween.tween_property(
								mixer_sprite_2d,
								"modulate",
								Color(mixer_colors[mixer_attribute.to_lower()]),
								1
							)
						else:
							mixer_tween.kill()
							mixer_tween = get_tree().create_tween()
							mixer_tween.tween_property(
								mixer_sprite_2d,
								"modulate",
								Color(mixer_colors[mixer_attribute.to_lower()]),
								1
							)
	else:
		if is_instance_valid(chem_sound):
			GameGlobals.audio_manager.fade_audio_out_and_destroy("sound_lab_chems", chem_sound, 1)
			chem_sound = null

	if mixer_dict.has(mixer_attribute.to_lower()):
		mixer_amount = str(mixer_dict[mixer_attribute.to_lower()]["amount"], " ml\n")
		var total_cost: int = (
			mixer_dict[mixer_attribute.to_lower()]["price"]
			* mixer_dict[mixer_attribute.to_lower()]["increase"]
		)
		if total_cost > GameGlobals.total_money:
			mixer_money = str("[color=red]$", GameGlobals.total_money, "\n")
		else:
			mixer_money = str("$", GameGlobals.total_money, "\n")
	vial_rich_text_label.text = str(
		"[center][b]", mixer_attribute, "[/b]\n", mixer_amount, mixer_money
	)


func drink_juice() -> void:
	for juice_attribute in mixer_dict.keys():
		var modifier: float = 0
		if juice_attribute != "alpha" and juice_attribute != "beta" and juice_attribute != "gamma":
			modifier = 20 * (float(mixer_dict[juice_attribute]["amount"]) / 10.0)
		else:
			modifier = (
				GameGlobals.rng.randf_range(-10, 20)
				* (float(mixer_dict[juice_attribute]["amount"]) / 10.0)
			)
		GameGlobals.vial_data[juice_attribute] = (modifier / 100.0)


func _on_start_button_mouse_entered() -> void:
	start_tooltip_control.visible = true


func _on_start_button_mouse_exited() -> void:
	start_tooltip_control.visible = false


func _on_start_button_pressed() -> void:
	if not button_pressed and input_ready:
		button_pressed = true
		animation_player.play("button_press")
		GameGlobals.audio_manager.create_audio("sound_lab_button")
		mixer_tween = get_tree().create_tween()
		mixer_tween.tween_property(mixer_sprite_2d, "modulate", Color(mixer_colors["vial"]), 1)
		await mixer_tween.finished
		animation_player_2.play("mixer_drain")
		animation_player_3.play("vial_fill")
		await animation_player_3.animation_finished
		drink_juice()
		GameGlobals.lab_screen = false
		GameGlobals.audio_manager.fade_audio_out_and_destroy("music_lab", lab_music, 1)
		UiMain.ui_transitions.change_scene(GameGlobals.city_scene)


func _on_juice_button_mouse_exited() -> void:
	vial_tooltip_control.visible = false


func _on_juice_button_button_down() -> void:
	if not button_pressed and input_ready:
		juice_down = true


func _on_juice_button_button_up() -> void:
	if input_ready:
		juice_down = false


func _on_alpha_button_mouse_entered() -> void:
	vial_tooltip_control.visible = true
	mixer_attribute = "Alpha"


func _on_gamma_button_mouse_entered() -> void:
	vial_tooltip_control.visible = true
	mixer_attribute = "Gamma"


func _on_beta_button_mouse_entered() -> void:
	vial_tooltip_control.visible = true
	mixer_attribute = "Beta"


func _on_power_button_mouse_entered() -> void:
	vial_tooltip_control.visible = true
	mixer_attribute = "Power"


func _on_speed_button_mouse_entered() -> void:
	vial_tooltip_control.visible = true
	mixer_attribute = "Speed"


func _on_durability_button_mouse_entered() -> void:
	vial_tooltip_control.visible = true
	mixer_attribute = "Durability"


func _on_special_button_mouse_entered() -> void:
	vial_tooltip_control.visible = true
	mixer_attribute = "Special"


func _on_dexterity_button_mouse_entered() -> void:
	vial_tooltip_control.visible = true
	mixer_attribute = "Dexterity"


func _on_guard_button_mouse_entered() -> void:
	vial_tooltip_control.visible = true
	mixer_attribute = "Guard"
