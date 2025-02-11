# This component is really only used for loading the main menu, 
# because it won't apply any save states or data due to SceneSwitcher.SceneLoadMode.RESET
extends Node

## Filepath to the scene to switch to
@export_file("*.tscn") var scene_to_load

func _ready() -> void:
    var parent_button : BaseButton = get_parent()

    parent_button.pressed.connect(func() -> void:
        if scene_to_load:
            SceneSwitcher.load_next_scene(scene_to_load, SceneSwitcher.SceneLoadMode.RESET)
        else:
            print("No scene set in the scene switcher on " + parent_button.get_name() + ".")
    )
