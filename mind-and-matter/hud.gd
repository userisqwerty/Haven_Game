extends CanvasLayer

@export var level_time_seconds: float = 90.0

@onready var timer_label: Label = $TimerLabel
@onready var notebook_panel: Panel = $NotebookPanel
@onready var notes_label: Label = $NotebookPanel/NotesLabel
@onready var padlock_panel: Panel = $PadlockPanel
@onready var code_input: LineEdit = $PadlockPanel/CodeInput

var time_left: float
var active_door: Node = null

func _ready() -> void:
	time_left = level_time_seconds
	Events.clue_found.connect(_on_clue_found)
	Events.open_padlock.connect(_on_open_padlock)
	
	$NotebookButton.pressed.connect(_toggle_notebook)
	$PadlockPanel/SubmitButton.pressed.connect(_on_submit_code)
	$PadlockPanel/CloseButton.pressed.connect(_close_padlock)

func _process(delta: float) -> void:
	time_left -= delta
	timer_label.text = "Time: " + str(ceili(time_left))
	
	if time_left <= 0.0:
		get_tree().reload_current_scene()

func _on_clue_found(text: String) -> void:
	notes_label.text += "• " + text + "\n"

func _toggle_notebook() -> void:
	notebook_panel.visible = not notebook_panel.visible

func _on_open_padlock(door_node: Node) -> void:
	active_door = door_node
	code_input.text = ""
	padlock_panel.visible = true
	code_input.grab_focus()
	_set_player_frozen(true)

func _close_padlock() -> void:
	padlock_panel.visible = false
	active_door = null
	_set_player_frozen(false)

func _on_submit_code() -> void:
	if active_door and code_input.text.strip_edges() == active_door.correct_code:
		Audio.play_unlock()
		active_door.unlock()
		_close_padlock()
	else:
		Audio.play_error()
		code_input.text = ""
		code_input.placeholder_text = "WRONG CODE!"

func _set_player_frozen(frozen: bool) -> void:
	if not is_inside_tree():
		return
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_locked_in_ui = frozen
