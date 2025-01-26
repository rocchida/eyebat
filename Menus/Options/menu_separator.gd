extends HBoxContainer

# used to programmatically generate seperators in the options menu keybindings tab

@onready var label: Label = $Label

var separator_text: String = "Section":
	set(value):
		separator_text = value
		label.text = separator_text
