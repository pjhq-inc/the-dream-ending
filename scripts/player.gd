class_name Player
extends CharacterBody3D

@export_category("Player Movement")
@export var sprint_speed = 25
@export var walk_speed = 15
@export var normal_jump_velocity = 2.5
@export var running_jump_velocity = 4.5

@export_category("Misc")
@export var raycast: RayCast3D
@export var hit_area: Area3D


const BOB_FREQ = 1
const BOB_AMP = 0.08
var t_bob = 0

const BASE_FOV = 75
const RUN_FOV = 100
const FOV_CHANGE = 0.5

var speed = 5.0
var jump_velocity = 4.5

@onready var head = $Head
@onready var camera = $Head/Camera3D

var default_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var gravity = default_gravity
var running = false
var mouse_sens = 0.1

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clampf(head.rotation.x, -1.4, 1.4)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("sprint"):
		speed = sprint_speed
		jump_velocity = running_jump_velocity
		running = true
	if Input.is_action_just_released("sprint"):
		speed = walk_speed
		jump_velocity = normal_jump_velocity
		running = false
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = jump_velocity

	

	var input_dir = Input.get_vector("left", "right", "forward", "backwards")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	#t_bob += delta * velocity.length() * float(is_on_floor())
	#camera.transform.origin = headbob(t_bob)
	var vel_clamped = clamp(velocity.length(), 0.5, sprint_speed * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * vel_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	if input_dir.x:
		camera.rotation.z = deg_to_rad(clamp(lerp_angle(camera.rotation.z, -input_dir.x * 5, delta * 8), -5, 5))
	else:
		camera.rotation.z = deg_to_rad(lerpf(camera.rotation.z, 0.0, delta * 8))
		
	move_and_slide()

func headbob(time):
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
