class_name P 
extends CharacterBody3D

## Camera
@export var mouse_sensitivity: float = 0.1
@onready var camera: Camera3D = $Camera3D

## Mouse settings
var min_pitch: float = -90.0
var max_pitch: float = 90.0
var pitch: float = 0.0

## Movement
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

## Decals and Paint settings
var ice_decal = preload("res://scenes/decals/BlueDecal.tscn")
var green_decal = preload("res://scenes/decals/GreenDecal.tscn")
var pink_decal = preload("res://scenes/decals/PinkDecal.tscn")
var paint_types: Array[String] = ["blue", "green", "pink"]
var current_paint_index: int = 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	## Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta


	## Jumping
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY



	## Movement and Direction
	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


	if Input.is_action_just_pressed("Shoot"):
		_shoot()


## Quit
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


	_paintSwap()
	move_and_slide()


## Decal logic // Rotates and sets decal facing correct way
func spawn_decal(decal_scene: PackedScene, position: Vector3, normal: Vector3):
	var decal_instance = decal_scene.instantiate()
	get_parent().add_child(decal_instance)
	
	decal_instance.position = position + normal * 0.01
	decal_instance.look_at(normal, Vector3.UP)
	if normal != Vector3.DOWN:
		decal_instance.rotate_object_local(Vector3(1, 0, 0), 90)
	else:
		decal_instance.rotate_object_local(Vector3(0, 0, -1))


## Shooting Logic // Checks collision and spawns decals from array
func _shoot():
	var raycast = $Camera3D/RayCast3D
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		var collision_normal = raycast.get_collision_normal()
		match paint_types[current_paint_index]:
			"blue":
				spawn_decal(ice_decal, collision_point, collision_normal)
			"green":
				spawn_decal(green_decal, collision_point, collision_normal)
			"pink":
				spawn_decal(pink_decal, collision_point, collision_normal)

## Paint-type logic
func _paintSwap():
	if Input.is_action_just_pressed("switch_paint_next"):
		current_paint_index = (current_paint_index + 1) % paint_types.size()
		print("Switched to:", paint_types[current_paint_index])

	if Input.is_action_just_pressed("switch_paint_previous"):
		current_paint_index = (current_paint_index - 1) % paint_types.size()
		print("Switched to:", paint_types[current_paint_index])


## Totally not from a tutorial
func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, min_pitch, max_pitch)
		camera.rotation_degrees.x = pitch
