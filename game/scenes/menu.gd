extends CanvasLayer

var menu_music: AudioStreamPlayer = null

@onready var tab_container: TabContainer = $Control/TabContainer

# Main Menu
@onready var start_button: Button = $Control/TabContainer/Main/VBoxContainer/StartButton
@onready var how_button: Button = $Control/TabContainer/Main/VBoxContainer/HowButton
@onready var settings_button: Button = $Control/TabContainer/Main/VBoxContainer/SettingsButton
@onready var credits_button: Button = $Control/TabContainer/Main/VBoxContainer/CreditsButton
@onready var quit_button: Button = $Control/TabContainer/Main/VBoxContainer/QuitButton

# How to Play
@onready var howto_return_button: Button = $Control/TabContainer/HowTo/VBoxContainer/ReturnButton

# Settings
@onready
var settings_return_button: Button = $Control/TabContainer/Settings/VBoxContainer/ReturnButton
@onready
var master_h_slider: HSlider = $Control/TabContainer/Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/MasterHSlider
@onready
var master_label: Label = $Control/TabContainer/Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/MasterLabel
@onready
var music_h_slider: HSlider = $Control/TabContainer/Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/MusicHSlider
@onready
var music_label: Label = $Control/TabContainer/Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/MusicLabel
@onready
var sound_h_slider: HSlider = $Control/TabContainer/Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer4/SoundHSlider
@onready
var sound_label: Label = $Control/TabContainer/Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer4/SoundLabel
@onready
var display_option_button: OptionButton = $Control/TabContainer/Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer2/DisplayOptionButton
@onready
var v_sync_option_button: OptionButton = $Control/TabContainer/Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer2/VSyncOptionButton
@onready
var frame_cap_option_button: OptionButton = $Control/TabContainer/Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer2/FrameCapOptionButton
@onready
var frame_label_option_button: OptionButton = $Control/TabContainer/Settings/VBoxContainer/PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer2/FrameLabelOptionButton

# Credits
@onready var credits_return_button: Button = $Control/TabContainer/Credits/VBoxContainer/ReturnButton
@onready
var credits_rich_text_label: RichTextLabel = $Control/TabContainer/Credits/VBoxContainer/PanelContainer/VBoxContainer/RichTextLabel

var input_ready: bool = false


func _ready() -> void:
	load_settings()
	start_button.pressed.connect(change_to_game)
	quit_button.pressed.connect(quit_game)
	how_button.pressed.connect(howto_menu)
	settings_button.pressed.connect(settings_menu)
	credits_button.pressed.connect(credits_menu)
	howto_return_button.pressed.connect(main_menu)
	settings_return_button.pressed.connect(main_menu)
	master_h_slider.value_changed.connect(_on_master_value_changed)
	music_h_slider.value_changed.connect(_on_music_value_changed)
	sound_h_slider.value_changed.connect(_on_sound_value_changed)
	display_option_button.item_selected.connect(_on_display_item_selected)
	v_sync_option_button.item_selected.connect(_on_vsync_item_selected)
	frame_cap_option_button.item_selected.connect(_on_framecap_item_selected)
	frame_label_option_button.item_selected.connect(_on_framelabel_item_selected)
	credits_return_button.pressed.connect(main_menu)
	credits_rich_text_label.meta_clicked.connect(credits_click_link)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	GameGlobals.title_screen = true
	UiMain.ui_transitions.toggle_transition(false)
	menu_music = GameGlobals.audio_manager.create_persistent_audio("music_menu")
	tab_container.current_tab = 0


func _input(_event: InputEvent) -> void:
	if Input.is_anything_pressed() and tab_container.current_tab == 0:
		input_ready = true
		main_menu()


func main_menu() -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	tab_container.current_tab = 1


func howto_menu() -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	tab_container.current_tab = 2


func settings_menu() -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	tab_container.current_tab = 3


func credits_menu() -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	tab_container.current_tab = 4


func credits_click_link(meta: Variant) -> void:
	if input_ready:
		GameGlobals.audio_manager.create_audio("sound_menu_click")
		OS.shell_open(meta)


func change_to_game() -> void:
	if input_ready:
		input_ready = false
		GameGlobals.audio_manager.create_audio("sound_menu_click")
		GameGlobals.title_screen = true
		if is_instance_valid(menu_music):
			GameGlobals.audio_manager.fade_audio_out_and_destroy("music_menu", menu_music, 1)
		UiMain.ui_transitions.change_scene_with_loading(GameGlobals.lab_scene)


func quit_game() -> void:
	get_tree().quit()


func load_settings() -> void:
	master_h_slider.value = (GameGlobals.game_settings.master_volume * 100)
	master_label.text = str("%d" % [GameGlobals.game_settings.master_volume * 100])
	music_h_slider.value = (GameGlobals.game_settings.music_volume * 100)
	music_label.text = str("%d" % [GameGlobals.game_settings.music_volume * 100])
	sound_h_slider.value = (GameGlobals.game_settings.sound_volume * 100)
	sound_label.text = str("%d" % [GameGlobals.game_settings.sound_volume * 100])
	match GameGlobals.game_settings.display_mode:
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			display_option_button.selected = 0
		DisplayServer.WINDOW_MODE_WINDOWED:
			display_option_button.selected = 1
	match GameGlobals.game_settings.vsync_mode:
		DisplayServer.VSYNC_DISABLED:
			v_sync_option_button.selected = 0
		DisplayServer.VSYNC_ENABLED:
			v_sync_option_button.selected = 1
		DisplayServer.VSYNC_ADAPTIVE:
			v_sync_option_button.selected = 2
		DisplayServer.VSYNC_MAILBOX:
			v_sync_option_button.selected = 3
	match GameGlobals.game_settings.frame_rate_cap:
		0:
			frame_cap_option_button.selected = 0
		1:
			frame_cap_option_button.selected = 1
		2:
			frame_cap_option_button.selected = 2
		3:
			frame_cap_option_button.selected = 3
	if GameGlobals.game_settings.show_fps:
		frame_label_option_button.selected = 1
	else:
		frame_label_option_button.selected = 0


func _on_master_value_changed(value: float) -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	master_label.text = str("%d" % [value])
	GameGlobals.game_settings.update_master_volume(value / 100)


func _on_music_value_changed(value: float) -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	music_label.text = str("%d" % [value])
	GameGlobals.game_settings.update_music_volume(value / 100)


func _on_sound_value_changed(value: float) -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	sound_label.text = str("%d" % [value])
	GameGlobals.game_settings.update_sound_volume(value / 100)


func _on_display_item_selected(index: int) -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	match index:
		0:
			GameGlobals.game_settings.update_display_mode(
				DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
			)
		1:
			GameGlobals.game_settings.update_display_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_vsync_item_selected(index: int) -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	GameGlobals.game_settings.update_vsync_mode(index)


func _on_framecap_item_selected(index: int) -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	GameGlobals.game_settings.update_frame_rate_cap(index)


func _on_framelabel_item_selected(index: int) -> void:
	GameGlobals.audio_manager.create_audio("sound_menu_click")
	GameGlobals.game_settings.update_show_fps(index)
