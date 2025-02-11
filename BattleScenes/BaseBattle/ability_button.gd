class_name AbilityButton extends Button

var ability : Attack

## Signal for getting the ability from the button.
signal ability_pressed(ability : Attack)

func _ready():
	pressed.connect(on_pressed)

func set_ability(ability : Attack):
	self.ability = ability
	set_text(ability.name)

## Hack to bind the ability to the pressed signal >.>
func on_pressed():
	ability_pressed.emit(ability)
