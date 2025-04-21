extends Node

@onready var missionsContainer = $Panel/VBoxContainer/MissionContainer
@onready var missionPrefab = preload("res://Scenes/Prefabs/mission.tscn")

@onready var adventurersContainer = $Panel/VBoxContainer/ScrollContainer/VBoxContainer
@onready var adventurerPrefab = preload("res://Scenes/Prefabs/adventurer.tscn")

@onready var adventurersCounter = $Panel/VBoxContainer/ScrollContainer/VBoxContainer/Heroes/count
@onready var buttonValidation = $Panel/VBoxContainer/ButtonValidation

var current_mission = Generals.selected_mission
var adventurers_selected = []
var button_connections := {}
var nbAdventurersAuthorized = 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_load_mission()
	_load_adventurers()
	
	
func _process(delta: float) -> void:
	adventurersCounter.text = str(adventurers_selected.size())
	if adventurers_selected.size() > 0:
		buttonValidation.visible = true
	else:
		buttonValidation.visible = false

func _format_rewards(rewards: Dictionary) -> String:
	var parts = []
	for key in rewards.keys():
		parts.append(str(key).capitalize() + ": " + str(rewards[key]))
	return ", ".join(parts)

func _load_mission() -> void:
	var instance = missionPrefab.instantiate()
	instance.get_node("NinePatchRect/MissionTitle").text = current_mission.nameMission
	instance.get_node("NinePatchRect/Difficulty").text = Enum.MissionDifficulty.keys()[current_mission.difficulty]
	instance.get_node("NinePatchRect/StatsRequired").text = current_mission.requiredStat
	instance.get_node("NinePatchRect/Rewards").text = _format_rewards(current_mission.rewards)
	var accept_button = instance.get_node("NinePatchRect/Accept")
	accept_button.visible = false
	missionsContainer.add_child(instance)


func _load_adventurers() -> void:
	var adventurers = DbManager._load_adventurers("WHERE available = 1")
	for item in adventurers:
		var instance = adventurerPrefab.instantiate()
		instance.get_node("NinePatchRect/HeroName").text = item.nameHero
		instance.get_node("NinePatchRect/Classe").text = "[" + item.className + "]"
		instance.get_node("NinePatchRect/Traits").text = ", ".join(item.traits.map(func(t): return str(t)))
		instance.get_node("NinePatchRect/Strength").text = "FOR : " + str(item.strength)
		instance.get_node("NinePatchRect/Magic").text = "MAG : " + str(item.magic)
		instance.get_node("NinePatchRect/Agility").text = "AGI : " + str(item.agility)
		
		var accept_button = instance.get_node("NinePatchRect/Accept")
		accept_button.visible = true
		accept_button.text = "Sélectionner"
	
		var callable = Callable(self, "_on_select_pressed_button").bind(item, instance)
		if not accept_button.pressed.is_connected(callable):
			accept_button.pressed.connect(callable)
			button_connections[accept_button] = callable

		adventurersContainer.add_child(instance)
	
func _on_select_pressed_button(adventurer: Object, instance: Node) -> void:
	if adventurer not in adventurers_selected:
		adventurers_selected.append(adventurer)
		instance.get_node("NinePatchRect/Panel").visible = true
		var ninepatch = instance.get_node("NinePatchRect")
		ninepatch.modulate = Color(0.7, 0.7, 0.7, 1.0)
		var accept_button = instance.get_node("NinePatchRect/Accept")
		accept_button.text = "Annuler Select."
		if accept_button in button_connections:
			accept_button.pressed.disconnect(button_connections[accept_button])
		var callable = Callable(self, "_on_deselect_pressed_button").bind(adventurer, instance)
		if not accept_button.pressed.is_connected(callable):
			accept_button.pressed.connect(callable)

		button_connections[accept_button] = callable
		_update_select_buttons_visibility()

	print(adventurers_selected)

func _on_deselect_pressed_button(adventurer: Object, instance: Node) -> void:
	if adventurer in adventurers_selected:
		adventurers_selected.erase(adventurer)
		instance.get_node("NinePatchRect/Panel").visible = false
		var ninepatch = instance.get_node("NinePatchRect")
		ninepatch.modulate = Color(1, 1, 1, 1.0)
		var accept_button = instance.get_node("NinePatchRect/Accept")
		accept_button.text = "Sélectionner"
		if accept_button in button_connections:
			accept_button.pressed.disconnect(button_connections[accept_button])
			
		var callable = Callable(self, "_on_select_pressed_button").bind(adventurer, instance)
		if not accept_button.pressed.is_connected(callable):
			accept_button.pressed.connect(callable)

		button_connections[accept_button] = callable
		_update_select_buttons_visibility()

	print(adventurers_selected)

func _update_select_buttons_visibility() -> void:
	for child in adventurersContainer.get_children():
		if not child.has_node("NinePatchRect/Accept"):
			continue # on skip si le noeud n’existe pas

		var accept_button = child.get_node("NinePatchRect/Accept")

		# Si l'aventurier est déjà sélectionné, on ne touche pas à son bouton
		if accept_button.text == "Annuler Select.":
			continue

		# Sinon, on rend visible/invisible selon le nombre sélectionné
		accept_button.visible = adventurers_selected.size() < nbAdventurersAuthorized

func _on_back_button_pressed() -> void:
	Generals._load_scene("res://Scenes/Game.tscn")


func _on_button_validation_pressed() -> void:
	print(_get_duration(adventurers_selected))
	for adventurer in adventurers_selected:
		DbManager._update_adventurer("available", 0, adventurer.id)
		DbManager._save_mission_active(int(current_mission.id), Time.get_unix_time_from_system(), _get_duration(adventurers_selected))
	Generals._load_scene("res://Scenes/Game.tscn")
	
func _get_duration(adventurers: Array) -> int:
	var secs = 0
	for adventurer in adventurers:
		secs += (adventurer.strength + adventurer.magic + adventurer.agility) * 2
		
	print("avant calcule ", secs)
	
	print("difficulté : ", int(Enum.MissionDifficulty.keys()[current_mission.difficulty]))
	
	if int(current_mission.difficulty > 0):
		secs = secs * int(current_mission.difficulty) + Generals.experience / adventurers.size()
	else:
		secs = secs + Generals.experience / adventurers.size()
	print("Après calcule ", secs)
	
	return secs
