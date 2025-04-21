extends Node

@onready var db = SQLite.new()
var table_created = false

func _ready() -> void:
	var path = "res://Datas/game_datas.db"
	db.path = path
	db.open_db()
	_create_tables()

func _create_tables() -> void:
	db.query("""
	CREATE TABLE IF NOT EXISTS adventurers (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT,
		class TEXT,
		strength INTEGER,
		magic INTEGER,
		agility INTEGER,
		traits TEXT,
		available INT
	)
	""")
	db.query("""
	CREATE TABLE IF NOT EXISTS missions (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name TEXT,
		description TEXT,
		difficulty TEXT,
		type TEXT,
		statRequired TEXT,
		rewards TEXT,
		state
	)
	""")
	db.query("""
	CREATE TABLE IF NOT EXISTS profile (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		username TEXT,
		guildName TEXT,
		level INTEGER,
		exp INTEGER,
		money INTEGER
	)
	""")
	db.query("""
	CREATE TABLE IF NOT EXISTS missions_active (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		mission_id INTEGER,
		start_time INTEGER,
		duration INTEGER,
		state INTEGER
	)
	""")
	if not table_created:
		db.query("""
		INSERT INTO profile (username, guildName, level, exp, money)
		VALUES ('Léonard', 'La Taverne des Héros', 1, 0, 100)
		""")
		table_created = true

func _save_adventurer(hero: Adventurer) -> void:
	var traits_str = ",".join(hero.traits.map(func(t): return str(t)))
	var query = "INSERT INTO adventurers (name, class, strength, magic, agility, traits, available) VALUES (?, ?, ?, ?, ?, ?, ?)"
	var values = [hero.nameHero, hero.className, hero.strength, hero.magic, hero.agility, traits_str, 1]
	db.query_with_bindings(query, values)

func _save_mission(mission: Mission) -> void:
	var rewards_str = ""
	for key in mission.rewards.keys():
		rewards_str += str(key) + ":" + str(mission.rewards[key]) + ","
	if rewards_str != "":
		rewards_str = rewards_str.substr(0, rewards_str.length() - 1)  # On enlève la dernière virgule

	var query = "INSERT INTO missions (name, description, difficulty, type, statRequired, rewards) VALUES (?, ?, ?, ?, ?, ?)"
	var values = [
				mission.nameMission,
				mission.description,
				str(mission.difficulty),  # On convertit l'enum en texte
				str(mission.type),  # On convertit l'enum en texte
				mission.requiredStat,
				rewards_str
				]
	db.query_with_bindings(query, values)


func _load_adventurers(where: String = "") -> Array:
	var adventurers = []
	var query = "SELECT id, name, class, strength, magic, agility, traits FROM adventurers %s" % where
	var result = db.query(query)

	if db.query_result:
		for row in db.query_result:
			var id = row["id"]
			var nameHero = row["name"]
			var className = row["class"]
			var strength = int(row["strength"])
			var magic = int(row["magic"])
			var agility = int(row["agility"])
			var traits = row["traits"].split(",") 

			# On crée une instance d'Adventurer ici
			var adventurer = Adventurer.new(
				id,
				nameHero,
				className,
				strength,
				magic,
				agility,
				0,
				0,
				traits,
			)

			adventurers.append(adventurer)
	return adventurers
	
func _update_adventurer(field_name: String, new_value, id: int = 1) -> void:
	var query = "UPDATE adventurers SET %s = ? WHERE id = ?" % field_name
	var values = [int(new_value), id]
	db.query_with_bindings(query, values)
	
func _count_adventurers() -> int:
	var result = db.query("SELECT COUNT(*) as count FROM adventurers")
	if result and db.query_result.size() > 0:
		return int(db.query_result[0]["count"])
	return 0

func _load_missions() -> Array:
	var missions = []
	var result = db.query("SELECT id, name, description, difficulty, type, statRequired, rewards FROM missions")

	if db.query_result:
		for row in db.query_result:
			var id = row["id"]
			var nameMission = row["name"]
			var description = row["description"]
			var difficulty = row["difficulty"]
			var missionType = row["type"]
			var requiredStat = row["statRequired"]
			var rewards_str = row["rewards"]
			var rewards = {}
			
			var reward_pairs = rewards_str.split(",")
			for pair in reward_pairs:
				var key_value = pair.split(":")
				if key_value.size() == 2:
					rewards[key_value[0]] = key_value[1]

			# Création d'une instance de Mission
			var mission = Mission.new(
				id,
				nameMission, 
				description, 
				int(difficulty), 
				int(missionType), 
				rewards, 
				requiredStat)

			missions.append(mission)
	return missions
	
	
func _load_mission(id: int) -> Dictionary:
	var result = db.query_with_bindings("SELECT * FROM missions WHERE id = ?", [id])
	if result:
		return db.query_result[0]
	return {}

func _count_missions() -> int:
	var result = db.query("SELECT COUNT(*) as count FROM missions")
	if result and db.query_result.size() > 0:
		return int(db.query_result[0]["count"])
	return 0
	
func _load_profile(id: int) -> Dictionary:
	var result = db.query_with_bindings("SELECT * FROM profile WHERE id = ?", [id])

	if result:
		return db.query_result[0]
		
	return {}


func _update_profile(field_name: String, new_value, profile_id: int = 1) -> void:
	var query = "UPDATE profile SET %s = ? WHERE id = ?" % field_name
	var values = [new_value, profile_id]
	db.query_with_bindings(query, values)

	
func _save_mission_active(id_mission: int, start_time: int, duration: int) -> void:
	var query = "INSERT INTO missions_active (mission_id, start_time, duration, state) VALUES (?, ?, ?, ?)"
	var values = [id_mission, start_time, duration, Enum.MissionActiveState.START]
	print("Je suis dans la save de mission_active => ", values)
	db.query_with_bindings(query, values)
	
func _load_mission_active(id: int) -> Dictionary:
	if id:
		var query = "SELECT * FROM missions_active WHERE id = %s" % id
		var result = db.query(query)

		if result:
			return db.query_result[0]
	return {}
	
func _load_missions_active() -> Array:
	var result = db.query("SELECT * FROM missions_active")
	
	if result:
		return db.query_result
		
	return []
