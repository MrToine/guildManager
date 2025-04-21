extends Node

class_name Mission

var id: int
var nameMission: String
var description: String
var difficulty: Enum.MissionDifficulty
var type: Enum.MissionType
var rewards: Dictionary
var requiredStat: String

func _init(id: int, nameMission: String, description: String, difficulty: Enum.MissionDifficulty, type: Enum.MissionType, rewards: Dictionary, requiredStat: String):
	self.id = id
	self.nameMission = nameMission
	self.description = description
	self.difficulty = difficulty
	self.type = type
	self.rewards = rewards
	self.requiredStat = requiredStat
