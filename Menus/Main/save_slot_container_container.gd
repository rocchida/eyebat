extends VBoxContainer

@export var save_slot_container_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# get all default SaveSlotContainer children
	var save_slot_containers : Array[Node] = get_children()
	# if we want to remove them and add new ones
	# for save_slot in save_slots:
	# 	save_slot.free()

	var all_save_data : Array[SaveData] = SaveManager.get_all_save_data()

	# if the number of save data exceeds the number of save slots, add more save slots
	if all_save_data.size() > save_slot_containers.size():
		for i in range(all_save_data.size() - save_slot_containers.size()):
			var save_slot_button : SaveSlotContainer = save_slot_container_scene.instance()
			add_child(save_slot_button)

	# Set the save data for each save slot loaded. If there are more save slots than save data, set the Save Data to null
	for i in range(save_slot_containers.size()):
		var save_slot_container = save_slot_containers[i] as SaveSlotContainer
		var save_slot_button : SaveSlotButton = save_slot_container.save_slot_button
		var default_save_slot_name : String = "Save Slot " + str(i+1)
		save_slot_button.default_save_slot_name = default_save_slot_name
		if i < all_save_data.size():
			save_slot_button.set_save_data(all_save_data[i])
		else:
			save_slot_button.set_save_data(null)

	# we're just gonna focus on this one first
	save_slot_containers[0].save_slot_button.grab_focus()