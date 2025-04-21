extends Node

var AdventurerFactory = preload("res://Scripts/Adventurer/AdventurerFactory.gd")
var MissionFactory = preload("res://Scripts/Missions/MissionFactory.gd")

@onready var missionsContainer = $MissionsPanel/ScrollContainer/VBoxContainer
@onready var missionPrefab = preload("res://Scenes/Prefabs/mission.tscn")

@onready var adventurersContainer = $AdventurersPanel/ScrollContainer/VBoxContainer
@onready var adventurerPrefab = preload("res://Scenes/Prefabs/adventurer.tscn")

var adventurers = []
var _timer_labels = []

func _ready() -> void:
	randomize()
	DbManager._ready()
	_load_adventurers()
	_load_missions()

func _process(delta: float) -> void:
	for label in _timer_labels:
		var start_time = label.get_meta("start_time")
		var duration = label.get_meta("duration")

		var remaining = _get_remaining_time(start_time, duration)

		if remaining <= 0:
			label.text = "Mission terminée !"
			label.remove_meta("start_time")
			label.remove_meta("duration")
			_timer_labels.erase(label)
			_mission_finished(int(label.get_meta("mission_active_id")))
		else:
			var minutes = int(remaining / 60)
			var seconds = int(remaining % 60)
			label.text = "⏳" + str(minutes) + "minutes \n" + str(seconds) + "secondes"



func _format_rewards(rewards: Dictionary) -> String:
	var parts = []
	for key in rewards.keys():
		parts.append(str(key).capitalize() + ": " + str(rewards[key]))
	return ", ".join(parts)

func _load_adventurers() -> void:
	var adventurers = DbManager._load_adventurers()
	for item in adventurers:
		var instance = adventurerPrefab.instantiate()
		instance.get_node("NinePatchRect/HeroName").text = item.nameHero
		instance.get_node("NinePatchRect/Classe").text = "[" + item.className + "]"
		instance.get_node("NinePatchRect/Traits").text = ", ".join(item.traits.map(func(t): return str(t)))
		instance.get_node("NinePatchRect/Strength").text = "FOR : " + str(item.strength)
		instance.get_node("NinePatchRect/Magic").text = "MAG : " + str(item.magic)
		instance.get_node("NinePatchRect/Agility").text = "AGI : " + str(item.agility)
		adventurersContainer.add_child(instance)

func _load_missions() -> void:
	var missions = DbManager._load_missions()
	for item in missions:
		var instance = missionPrefab.instantiate()
		instance.get_node("NinePatchRect/MissionTitle").text = item.nameMission
		instance.get_node("NinePatchRect/Difficulty").text = Enum.MissionDifficulty.keys()[item.difficulty]
		instance.get_node("NinePatchRect/StatsRequired").text = item.requiredStat
		instance.get_node("NinePatchRect/Rewards").text = _format_rewards(item.rewards)
		var accept_button = instance.get_node("NinePatchRect/Accept")
		var mission_active = _get_active_mission(item)

		if mission_active.is_empty():
		# Mission non active
			accept_button.text = "Envoyer"
			accept_button.visible = true
			accept_button.pressed.connect(_on_accept_pressed_button.bind(item))
		else:
			# Mission active
			accept_button.visible = false
			var timer_label = instance.get_node("NinePatchRect/Timer")
			timer_label.visible = true
			timer_label.set_meta("start_time", int(mission_active.start_time))
			timer_label.set_meta("duration", int(mission_active.duration))
			timer_label.set_meta("mission_active_id", mission_active.id)
			_timer_labels.append(timer_label)


		missionsContainer.add_child(instance)
		
func _get_remaining_time(start_time: int, duration: int) -> int:
	var now = Time.get_unix_time_from_system()
	var end_time = start_time + duration
	return max(end_time - now, 0)

func _get_active_mission(current_mission) -> Dictionary:
	var missions_active = DbManager._load_missions_active()
	for mission in missions_active:
		if current_mission.id == mission.mission_id:
			return mission
	return {}  # Rien trouvé

func _on_add_adventurer_pressed() -> void:
	Generals._load_scene("res://Scenes/choice_adventurer.tscn")


func _on_add_mission_pressed() -> void:
	Generals._load_scene("res://Scenes/choice_mission.tscn")
	
	
func _on_accept_pressed_button(mission) -> void:
	Generals.selected_mission = mission
	Generals._load_scene("res://Scenes/launch_mission.tscn")
	
func _on_result_button_pressed(mission) -> void:
	pass
	
func _mission_finished(id_mission: int) -> void:
	var mission = DbManager._load_mission(id_mission)
	print(mission)
	pass
	var button_results = missionsContainer.get_node("NinePatchRect")
	print(button_results)
	print("mission : ", id_mission)
