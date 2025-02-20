extends Control
class_name UI
signal ability_clicked(ability : Attack)

var buttons : Array[AbilityButton]
var battle_scene : BattleScene
@onready var attack_desc_text : Label = $ColorMenu/ScrollContainer/Label
@onready var monster_desc_text : Label = $ColorMenu/CurrentMonsterStats/Label
@onready var hovered_monster_desc_text : Label = $ColorMenu/HoveredMonsterStats/Label
@onready var initiative_board : HBoxContainer = $InitiativeBoard/HBoxContainer
@onready var action_text : RichTextLabel = $ColorMenu/RichTextLabel
@onready var initiative_text : RichTextLabel = $Initiative

func _ready():
	# get all the ability buttons
	var ability_button_container = $ColorMenu/HBoxContainer as HBoxContainer
	for i in range(ability_button_container.get_child_count()):
		buttons.append(ability_button_container.get_child(i) as AbilityButton)

	battle_scene = get_parent()
	if(battle_scene == null or battle_scene is not BattleScene):
		Global.debug_log("UI","BattleScene must be the parent of UI")

	# connect signals on monsters which affect the UI nodes
	for monster in battle_scene.player_monsters:
		connect_monster_signals(monster)
	for monster in battle_scene.enemy_monsters:
		connect_monster_signals(monster)

	# connect signals on the battle which affact the UI nodes
	battle_scene.activated_ability_completed.connect(_on_selected_ability_completed)

## Connect UI changes to monster signals
func connect_monster_signals(monster : Monster):
	monster.sprite_hovered.connect(set_hovered_monster_stats)

## Adds line of text to the action_text RichTextLabel AKA the battle log
func debug(text : String):
	action_text.append_text(text + '\n')
	action_text.scroll_to_line(action_text.get_line_count())
	
func set_initiative_text(current_turn : int, initiative : Array[Monster], enemies : Array[Monster]):
	initiative_text.clear()
	var i : int = current_turn
	while i < initiative.size():
		var m : Monster = initiative[i]
		if !m.is_deadzo():
			add_name_to_initiative(m, enemies)

		i += 1
	i = 0
	while i < current_turn:
		var m : Monster = initiative[i]
		if !m.is_deadzo():
			add_name_to_initiative(m, enemies)
		i += 1

func add_name_to_initiative(m : Monster, enemies : Array[Monster]):
	if enemies.has(m):
		initiative_text.push_outline_color(Color.DARK_RED)
	else:
		initiative_text.push_outline_color(Color.DARK_GREEN)
	initiative_text.add_text( m.name + " >")

func set_ability_buttons(abilities : Array[Attack]):
	for i in range(buttons.size()):
		if abilities[i] != null:
			buttons[i].set_ability(abilities[i])

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
	else : monster_desc_text.set_text(monster.name + "\nHP: " + str(monster.health) + "/" + str(monster.max_health)  + "     ATK: " + str(monster.atk)
	+ "\nMANA: " + str(monster.mana) + "       MAGIC: " + str(monster.magic) + "RES: " + str(monster.res) + "\nSPD: " + str(monster.spd) + "DEF: " + str(monster.def))

func set_hovered_monster_stats(monster : Monster):
	if (monster == null): hovered_monster_desc_text.set_text("")
	else : hovered_monster_desc_text.set_text(monster.name + "\nHP: " + str(monster.health) + "/" + str(monster.max_health)  + "     ATK: " + str(monster.atk)
	+ "\nMANA: " + str(monster.mana) + "       MAGIC: " + str(monster.magic) + "RES: " + str(monster.res) + "\nSPD: " + str(monster.spd) + "DEF: " + str(monster.def)
	+ "\nThreats: " + str(monster.get_brain().target_threat_dict))

func set_initiative_board(initiative: Array[Monster]):
	for m in initiative:
		initiative_board.add_child(m.get_portrait())

func _on_ability_button_1_pressed(ability : Attack):
	ability_clicked.emit(ability)

func _on_ability_button_2_pressed(ability : Attack):
	ability_clicked.emit(ability)

func _on_ability_button_3_pressed(ability : Attack):
	ability_clicked.emit(ability)

func _on_ability_button_4_pressed(ability : Attack):
	ability_clicked.emit(ability)

## called whenever the battle scene class finishes using a selected ability.
func _on_selected_ability_completed(source : Monster, targets : Array[Monster], ability : Attack):
	# deselect the currently selected AbilityButton
	for btn in buttons:
		btn.set_pressed_no_signal(false)