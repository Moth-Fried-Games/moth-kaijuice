extends Node

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var game_settings: GameSettings = GameSettings.new()
var game_data: GameData = GameData.new()

var audio_manager: AudioManager = AudioManager.new()

var loading_screen: bool = false

var bullet_resource: Resource = preload("res://game/entities/bullet.tscn")
var big_bullet_resource: Resource = preload("res://game/entities/big_bullet.tscn")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	randomize()
	rng.randomize()
	add_child(game_settings)
	add_child(game_data)
	add_child(audio_manager)
	game_settings.load_settings()
	game_data.load_data()
	audio_manager.load_audio()
