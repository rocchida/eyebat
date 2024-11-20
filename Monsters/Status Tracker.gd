extends Label3D
class_name StatusTracker

@onready var this = $"."

func update_text(statuses : Dictionary):
	var str : String = ""
	for key in statuses.keys():
		var stacks : String = str(statuses[key])
		str = str + key.name + ":" + stacks + " "
	this.text = str
	
