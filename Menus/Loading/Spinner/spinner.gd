extends TextureProgressBar

var _tween : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	#_tween = get_tree().create_tween().set_loops()
	_tween = get_tree().create_tween().bind_node(self)
	_tween.tween_property(self, "radial_initial_angle", 360.0, 1.5).as_relative()

