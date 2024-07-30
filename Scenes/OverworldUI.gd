extends Control

@export var monsters : Array[Monster]
var player : Player

# Called when the node enters the scene tree for the first time.
func _ready():
	add_button(monsters)
	player = $"../player"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_button(monsters: Array[Monster]):
	for m in monsters:
		var button := MenuButton.new()
		button.text = m.name
		button.add_theme_font_size_override("font_size", 30)
		button.add_theme_color_override("font_pressed_color", Color.AQUA)
		
		button.pressed.connect(button_action.bind(m))
		$Panel/VBoxContainer.add_child(button)

func button_action(m : Monster):
	player.monster_roster.append(m)
	print(player.monster_roster)

