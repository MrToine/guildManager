extends Button

func _process(delta) -> void:
	var nbHeroes = DbManager._load_adventurers()
	if nbHeroes.size() < 1 :
		self.disabled = true
	else:
		self.disabled = false
