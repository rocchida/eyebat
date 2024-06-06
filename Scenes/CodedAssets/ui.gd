extends Control
signal button_clicked(int)

var buttons : Array
@onready var attack_desc_text : Label = $ColorMenu/ScrollContainer/Label
@onready var monster_desc_text : Label = $ColorMenu/CurrentMonsterStats/Label
@onready var hovered_monster_desc_text : Label = $ColorMenu/HoveredMonsterStats/Label

func _ready():
	buttons.append($ColorMenu/HBoxContainer/MenuButton)
	buttons.append($ColorMenu/HBoxContainer/MenuButton2)
	buttons.append($ColorMenu/HBoxContainer/MenuButton3)
	buttons.append($ColorMenu/HBoxContainer/MenuButton4)

func set_buttons(attacks : Array[String]):
	for i in range(buttons.size()):
		if attacks[i] != null:
			buttons[i].set_text(attacks[i])

func set_attack_description(attack : Attack, monster : Monster):
	if (attack == null): attack_desc_text.set_text("")
	else: attack_desc_text.set_text(attack.get_attack_name() + "\nDamage: " + str(attack.get_damage(monster)))

func set_current_monster_stats(monster : Monster):
	if (monster == null): monster_desc_text.set_text("")
	else : monster_desc_text.set_text(monster.name + "\nHP: " + str(monster.health) + "/" + str(monster.max_health)  + "     STR: " + str(monster.strength)
	+ "\nMANA: " + str(monster.mana) + "       INT: " + str(monster.intelligence) + "\nSPD: " + str(monster.speed))

func set_hovered_monster_stats(monster : Monster):
	if (monster == null): hovered_monster_desc_text.set_text("")
	else : hovered_monster_desc_text.set_text(monster.name + "\nHP: " + str(monster.health) + "/" + str(monster.max_health)  + "     STR: " + str(monster.strength)
	+ "\nMANA: " + str(monster.mana) + "       INT: " + str(monster.intelligence) + "\nSPD: " + str(monster.speed))


func _on_menu_button_pressed():
	button_clicked.emit(0)


func _on_menu_button_2_pressed():
	button_clicked.emit(1)


func _on_menu_button_3_pressed():
	button_clicked.emit(2)


func _on_menu_button_4_pressed():
	button_clicked.emit(3)
