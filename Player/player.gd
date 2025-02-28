extends CharacterBody3D

@export var walk_speed = 5.0;
@export var fall_acceleration = 75;
@export var jump_impulse = 5;

var bullet = load("res://Player/bullet.tscn");
var instance

var gunIsLowered = false;

@onready var neck := $Neck;
@onready var camera := $Neck/Camera3D;
@onready var subViewPortCamera = $SubViewportContainer/SubViewport/subviewportcamera;
@onready var revolver_animation = $Neck/Camera3D/revolver/AnimationPlayer;
@onready var gun_barrel = $Neck/Camera3D/revolver/frame/RayCast3D;
@onready var nearWallRay = $Neck/Camera3D/nearWallRay;

var target_velocity = Vector3.ZERO

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * 0.01)
			camera.rotate_x(-event.relative.y * 0.01)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-30), deg_to_rad(60))
	
func _process(_delta):
	subViewPortCamera.set_global_transform(camera.get_global_transform())

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_impulse

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)
	
	move_and_slide()
	
	#shooting
	if Input.is_action_pressed("shoot"):
		if !revolver_animation.is_playing() && gunIsLowered == false:
			revolver_animation.play("Shooting")
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)
			
	#if gun_barrel.is_colliding():
		#revolver_animation.play("gun_lowered");
		#gunIsLowered = true;
	#elif gunIsLowered == true:
		#revolver_animation.play("gun_raised");
		#gunIsLowered = false;
		
#Lower the gun when near a wall
	if gunIsLowered == false && nearWallRay.is_colliding():
		revolver_animation.play("gun_lowered");
		gunIsLowered = true;
	elif gunIsLowered == true && !nearWallRay.is_colliding():
		revolver_animation.play("gun_raised");
		gunIsLowered = false;

