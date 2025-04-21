extends Node

@export var nbAdventurer: int = 4
@export var nbMissions: int = 5

var AdventurerFactory = preload("res://Scripts/Adventurer/AdventurerFactory.gd")
var MissionFactory = preload("res://Scripts/Missions/MissionFactory.gd")

@onready var missionsContainer = $Panel/ScrollContainer/VBoxContainer
@onready var missionPrefab = preload("res://Scenes/Prefabs/mission.tscn")

@onready var adventurersContainer = $Panel/ScrollContainer/VBoxContainer
@onready var adventurerPrefab = preload("res://Scenes/Prefabs/adventurer.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print(get_tree().current_scene.name)
	if get_tree().current_scene.name == "choice_adventurer":
		_generate_adventurer()
	else:
		_generate_missions()

func _generate_adventurer() -> void:
	for i in randi_range(0, nbAdventurer):
		var fact = AdventurerFactory.new()
		var adventurer = fact.generate_adventurer()
		var instance = adventurerPrefab.instantiate()
		instance.get_node("NinePatchRect/HeroName").text = adventurer.nameHero
		instance.get_node("NinePatchRect/Classe").text = "[" + adventurer.className + "]"
		instance.get_node("NinePatchRect/Traits").text = ", ".join(adventurer.traits.map(func(t): return str(t)))
		instance.get_node("NinePatchRect/Strength").text = "FOR : " + str(adventurer.strength)
		instance.get_node("NinePatchRect/Magic").text = "MAG : " + str(adventurer.magic)
		instance.get_node("NinePatchRect/Agility").text = "AGI : " + str(adventurer.agility)
		var accept_button = instance.get_node("NinePatchRect/Accept")
		accept_button.visible = true
		accept_button.text = str(adventurer.price)
		accept_button.pressed.connect(_on_accept_pressed_button.bind(Enum.TypeData.ADVENTURER, adventurer, instance))
	
		adventurersContainer.add_child(instance)

func _generate_missions() -> void:
	var nbMissions = randf_range(0, nbMissions)
	var missions = MissionFactory.new().generate_missions(nbMissions)
	for mission in missions:
		var instance = missionPrefab.instantiate()
		instance.get_node("NinePatchRect/MissionTitle").text = mission.nameMission
		instance.get_node("NinePatchRect/Difficulty").text = Enum.MissionDifficulty.keys()[mission.difficulty]
		instance.get_node("NinePatchRect/StatsRequired").text = mission.requiredStat
		instance.get_node("NinePatchRect/Rewards").text = _format_rewards(mission.rewards)
		var accept_button = instance.get_node("NinePatchRect/Accept")
		accept_button.text = "Choisir"
		accept_button.visible = true
		accept_button.pressed.connect(_on_accept_pressed_button.bind(Enum.TypeData.MISSION, mission, instance))

		missionsContainer.add_child(instance)


func _format_rewards(rewards: Dictionary) -> String:
	var parts = []
	for key in rewards.keys():
		parts.append(str(key).capitalize() + ": " + str(rewards[key]))
	return ", ".join(parts)	

func _on_back_button_pressed() -> void:
	Generals._load_scene("res://Scenes/Game.tscn")
	
	
func _on_accept_pressed_button(type, object, instance) -> void:
	var valid = false
	if object is Adventurer:
		var profile = DbManager._load_profile(Generals.userid)
		if profile.money >= object.price:
			DbManager._save_adventurer(object)
			DbManager._update_profile("money", profile.money - object.price, Generals.userid)
			valid = true
		else:
			print("Pas assez de pepette :/")
	elif object is Mission:
		DbManager._save_mission(object)
		valid = true
	
	if valid:
		instance.queue_free()
