extends StaticBody2D

@export var linked_clues: Array[Area2D] = []
@export_file("*.tscn") var next_level_scene: String = ""
var correct_code: String = ""

func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	correct_code = str(randi_range(1000, 9999))
	
	if linked_clues.size() == 1 and linked_clues.front() and "clue_text" in linked_clues.front():
		linked_clues.front().clue_text = "Door Code: " + correct_code
	elif linked_clues.size() >= 2:
		if linked_clues.front() and "clue_text" in linked_clues.front():
			linked_clues.front().clue_text = "Code First Half: " + correct_code.substr(0, 2) + "__"
		if linked_clues.back() and "clue_text" in linked_clues.back():
			linked_clues.back().clue_text = "Code Second Half: __" + correct_code.substr(2, 2)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for body in $PadlockZone.get_overlapping_bodies():
			if body.is_in_group("player") and not body.is_ghost:
				Events.open_padlock.emit(self)
				return

func unlock() -> void:
	if next_level_scene != "":
		get_tree().change_scene_to_file(next_level_scene)
	else:
		queue_free()
