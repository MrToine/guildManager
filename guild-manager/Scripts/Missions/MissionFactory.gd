extends Node

const Mission = preload("res://Scripts/Missions/Mission.gd")

var mission_templates = [
	{
		"name": "Nettoyer les latrines de Gobelins",
		"description": "Une mission pas très glorieuse, mais bien payée.",
		"type": Enum.MissionType.COLLECT,
		"required_stat": "faith"
	},
	{
		"name": "Livrer des herbes à Mamie",
		"description": "Attention aux mauvaises herbes !",
		"type": Enum.MissionType.ESCORT,
		"required_stat": "agility"
	},
	{
		"name": "Explorer la grotte qui pue",
		"description": "Il paraît que personne n’en est jamais revenu.",
		"type": Enum.MissionType.EXPLORE,
		"required_stat": "strength"
	},
	{
		"name": "Escorter un pigeon blessé",
		"description": "Le pigeon est très susceptible, ne le perdez pas.",
		"type": Enum.MissionType.ESCORT,
		"required_stat": "charisma"
	},
	{
		"name": "Terrasser la limace géante",
		"description": "Elle bave... beaucoup.",
		"type": Enum.MissionType.ELIMINATE,
		"required_stat": "strength"
	},
	{
		"name": "Terrasser la Fourmi picoreuse",
		"description": "Elle porte... beaucoup.",
		"type": Enum.MissionType.ELIMINATE,
		"required_stat": "strength"
	},
	{
		"name": "Terrasser l'escargot bavot",
		"description": "Elle bave... beaucoup.",
		"type": Enum.MissionType.ELIMINATE,
		"required_stat": "strength"
	}
]

func generate_missions(nb: int) -> Array:
	var shuffled_templates = mission_templates.duplicate()
	shuffled_templates.shuffle()

	var missions = []
	var count = min(nb, shuffled_templates.size())

	for i in range(count):
		var id = (DbManager._count_missions() + i) + 1
		var t = shuffled_templates[i]
		var difficulty = Enum.MissionDifficulty.values()[randi() % Enum.MissionDifficulty.values().size()]
		var rewards = {
			"gold": 50 + randi() % 100 * difficulty,
			"reputation": randi() % 10 * difficulty
		}

		var mission = Mission.new(
			id,
			t.name,
			t.description,
			difficulty,
			t.type,
			rewards,
			t.required_stat
		)
		missions.append(mission)
	return missions
