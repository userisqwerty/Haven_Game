extends CharacterBody2D

@export var speed: float = 150.0
@export var body_return_radius: float = 40.0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var lantern: PointLight2D = $PointLight2D

var is_ghost: bool = false
var is_locked_in_ui: bool = false
var is_pulling_phone: bool = false
var saved_human_position: Vector2
var left_behind_body: CanvasItem = null
var last_dir: String = "down"

func _ready() -> void:
	lantern.color = Color(1.0, 0.85, 0.65)

func _physics_process(_delta: float) -> void:
	if is_locked_in_ui or is_pulling_phone:
		velocity = Vector2.ZERO
		if not is_pulling_phone:
			anim_sprite.play("idle_" + last_dir)
		return
		
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()
	
	_update_animation(direction)

func _update_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		anim_sprite.play("idle_" + last_dir)
		return
		
	if abs(direction.x) > abs(direction.y):
		last_dir = "side"
		anim_sprite.flip_h = direction.x < 0
	else:
		anim_sprite.flip_h = false
		if direction.y < 0:
			last_dir = "up"
		else:
			last_dir = "down"
			
	anim_sprite.play("walk_" + last_dir)

func _unhandled_input(event: InputEvent) -> void:
	if is_locked_in_ui or is_pulling_phone:
		return
		
	if event.is_action_pressed("soul_swap"):
		if not is_ghost:
			start_phone_swap()
		elif global_position.distance_to(saved_human_position) <= body_return_radius:
			start_phone_swap()

func start_phone_swap() -> void:
	is_pulling_phone = true
	anim_sprite.flip_h = false
	Audio.play_phone()
	
	if not is_ghost:
		anim_sprite.play("phone")
		await anim_sprite.animation_finished
		toggle_ghost_mode()
	else:
		toggle_ghost_mode()
		anim_sprite.play_backwards("phone")
		await anim_sprite.animation_finished
		
	is_pulling_phone = false

func toggle_ghost_mode() -> void:
	is_ghost = not is_ghost
	
	if is_ghost:
		saved_human_position = global_position
		left_behind_body = anim_sprite.duplicate()
		left_behind_body.animation = "phone"
		left_behind_body.frame = left_behind_body.sprite_frames.get_frame_count("phone") - 1
		left_behind_body.pause()
		get_parent().add_child(left_behind_body)
		left_behind_body.global_position = saved_human_position
		left_behind_body.global_scale = anim_sprite.global_scale
		set_collision_mask_value(2, false)
		modulate.a = 0.5
		lantern.color = Color(0.3, 0.8, 1.0)
	else:
		global_position = saved_human_position
		if left_behind_body:
			left_behind_body.queue_free()
		set_collision_mask_value(2, true)
		modulate.a = 1.0
		lantern.color = Color(1.0, 0.85, 0.65)
