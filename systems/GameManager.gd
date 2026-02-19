extends Node
## Simple state holder and scene flow controller.
## Autoload: GameManager

var state: String = "boot"
var selected_hero_path: String = ""
var selected_hero_name: String = ""
var selected_hero_id: String = ""
## Speaker on/off; toggled via UI in HeroSelect and Match. When false, music and ambient are muted.
var sound_enabled: bool = true

func _ready() -> void:
	# Autoloads initialize before the main scene is added to the tree.
	# Wait one frame so current_scene is available.
	await get_tree().process_frame
	if get_tree().current_scene and get_tree().current_scene.name == "Boot":
		_goto_hero_select()

func _goto_hero_select() -> void:
	state = "hero_select"
	get_tree().change_scene_to_file("res://scenes/ui/HeroSelect.tscn")

func goto_match() -> void:
	state = "match"
	get_tree().change_scene_to_file("res://scenes/match/Match.tscn")

func goto_hero_select() -> void:
	state = "hero_select"
	get_tree().change_scene_to_file("res://scenes/ui/HeroSelect.tscn")
