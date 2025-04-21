extends Node

const Adventurer = preload("res://Scripts/Adventurer/Adventurer.gd")

func generate_adventurer() -> Adventurer:
	var heroName = _generate_adventurer_name()
	var heroClass = _generate_class()
	var heroTraits = _generate_traits()
	var strength = _generate_stat()
	var magic = _generate_stat()
	var agility = _generate_stat()
	var morale = _generate_stat()
	var faith = _generate_stat()
	var price = _generate_price(strength, magic, agility)
	var id = DbManager._count_adventurers() + 1
	
	return Adventurer.new(id, heroName, heroClass, strength, magic, agility, faith, morale, heroTraits, price)

func _generate_stat() -> int:
	return randi() % 10 + 1

func _generate_adventurer_name() -> String:
	var names = ["Mandale le Gros", "Patrac Le Bancal", "Morvax le Poisseux", "Tonton Dague", "Sire Pette", "Kéké Bouclier", "Barba Quiche", "Grau Bidule", "Baron Truc"]
	return names[randi() % names.size()]

func _generate_class() -> String:
	var classes = ["Barbare", "Sorcier", "Rôdeur", "Paladin", "Barde"]
	return classes[randi() % classes.size()]

func _generate_traits() -> Array:
	var traitsPool = ["Malchanceux", "Trouillard", "Vantard", "Généreux", "Myope", "Estomac Fragile"]
	var nbTraits = randi_range(1, 3)
	var traits = []
	for i in nbTraits:
		traits.append(traitsPool[randi() % traitsPool.size()])
	return traits
	
	
func _generate_price(strength: int, magic: int, agility: int) -> int:
	var price = ((strength + magic + agility) / 3) * 25
	return price
