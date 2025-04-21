extends Node

var userid = 1
var selected_mission = null
var experience

func _ready() -> void:
	var profile = DbManager._load_profile(userid)
	experience = profile.exp

func _input(event: InputEvent) -> void: 
	if event.is_action_pressed("gain_money"):
		DbManager._update_profile("money", 300, userid)

func _load_scene(sceneName: String) -> void:
	get_tree().change_scene_to_file(sceneName)
