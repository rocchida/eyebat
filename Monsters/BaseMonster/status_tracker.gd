extends Label3D
class_name StatusTracker

@onready var this = $"."

func update_text(statuses : Dictionary):
	var new_text : String = ""
	for key in statuses.keys():
		var stacks : String = str(statuses[key])
		new_text = new_text + key.name + ":" + stacks + " "
	this.text = new_text
	
