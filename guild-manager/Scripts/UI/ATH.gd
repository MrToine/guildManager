extends Control

@onready var guildName = $Title/NinePatchRect/Label
@onready var money = $HBoxContainer/Money

var profile

func _ready() -> void:
	profile = DbManager._load_profile(1)

func _process(delta) -> void:
	guildName.text = profile.guildName
	money.text = str(profile.money)
	
