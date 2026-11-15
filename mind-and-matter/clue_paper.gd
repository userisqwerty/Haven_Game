extends Area2D

@export_multiline var clue_text: String = "Code: 1234"
@export var ghost_only: bool = true

var collected: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
		
	if body.is_in_group("player"):
		if ghost_only and not body.is_ghost:
			return
			
		collected = true
		modulate.a = 0.35
		Audio.play_paper()
		Events.clue_found.emit(clue_text)
