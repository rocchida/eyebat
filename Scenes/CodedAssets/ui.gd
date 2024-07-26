extends Control
signal button_clicked(int)

var buttons : Array
var btn : Button
@onready var attack_desc_text : Label = $ColorMenu/ScrollContainer/Label
@onready var monster_desc_text : Label = $ColorMenu/CurrentMonsterStats/Label
@onready var hovered_monster_desc_text : Label = $ColorMenu/HoveredMonsterStats/Label
@onready var initiative_board : HBoxContainer = $InitiativeBoard/HBoxContainer

func _ready():
	buttons.append($ColorMenu/HBoxContainer/MenuButton)
	buttons.append($ColorMenu/HBoxContainer/MenuButton2)
	buttons.append($ColorMenu/HBoxContainer/MenuButton3)
	buttons.append($ColorMenu/HBoxContainer/MenuButton4)

func set_buttons(attacks : Array[String]):
	for i in range(buttons.size()):
		if attacks[i] != null:
			buttons[i].set_text(attacks[i])

func hide_buttons():
	for btn : Button in buttons:
		if btn.is_visible_in_tree(): 
			btn.hide()

func show_buttons():
	for btn in buttons:
		if !btn.is_visible_in_tree(): 
			btn.show()

func set_attack_description(attack : Attack, monster : Monster):
	if (attack == null): attack_desc_text.set_text("")
	else: attack_desc_text.set_text(attack.get_attack_name() + "\nDamage: " + str(attack.get_damage_formula(monster)))

func set_current_monster_stats(monster : Monster):
	if (monster == null): monster_desc_text.set_text("")
	else : monster_desc_text.set_text(monster.name + "\nHP: " + str(monster.health) + "/" + str(monster.max_health)  + "     STR: " + str(monster.str)
	+ "\nMANA: " + str(monster.mana) + "       INT: " + str(monster.intl) + "\nSPD: " + str(monster.dex))

func set_hovered_monster_stats(monster : Monster):
	if (monster == null): hovered_monster_desc_text.set_text("")
	else : hovered_monster_desc_text.set_text(monster.name + "\nHP: " + str(monster.health) + "/" + str(monster.max_health)  + "     STR: " + str(monster.str)
	+ "\nMANA: " + str(monster.mana) + "       INT: " + str(monster.intl) + "\nSPD: " + str(monster.dex))

func set_initiative_board(initiative: Array[Monster]):
	for m in initiative:
		initiative_board.add_child(m.get_portrait())

func _on_menu_button_pressed():
	button_clicked.emit(0)


func _on_menu_button_2_pressed():
	button_clicked.emit(1)


func _on_menu_button_3_pressed():
	button_clicked.emit(2)


func _on_menu_button_4_pressed():
	button_clicked.emit(3)
