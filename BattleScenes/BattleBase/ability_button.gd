class_name AbilityButton extends MenuButton

var ability : Attack

func set_ability(ability : Attack):
	self.ability = ability
	set_text(ability.name)
	# connect("pressed", ability, "use")
