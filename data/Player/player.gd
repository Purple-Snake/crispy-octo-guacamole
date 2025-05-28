extends CharacterBody3D

@export var walk_speed = 7.0;
@export var fall_acceleration = 75;
@export var jump_impulse = 5;
@export var sprint_speed = 14.0
@export var is_sprinting = false


var health = 100;

signal itemInteract;
signal player_hit;

var bullet = load("res://data/Player/bullet.tscn");
var instance

var gunIsLowered = false;

@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var subViewPortCamera = $SubViewportContainer/SubViewport/subviewportcamera;
@onready var revolver_animation = $Neck/Camera3D/revolver/AnimationPlayer;
@onready var gun_barrel = $Neck/Camera3D/revolver/frame/RayCast3D;
@onready var hitscan = $"Neck/Camera3D/hitscan weapon"
@onready var nearWallRay = $Neck/Camera3D/nearWallRay;
@onready var interactionRay = $Neck/Camera3D/interactionRay;
@onready var hud = $SubViewportContainer/SubViewport/hud;

var target_velocity = Vector3.ZERO

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _unhandled_input(event):
#captures the mouse so that it will stay always in centre
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
	
	is_sprinting = Input.is_action_pressed("sprint")
	var current_speed = sprint_speed if is_sprinting else walk_speed
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)
	
	if input_dir.x > 0:
		neck.rotation.z = lerp_angle(neck.rotation.z, deg_to_rad(-2), 0.05)
	elif input_dir.x < 0: 
		neck.rotation.z = lerp_angle(neck.rotation.z, deg_to_rad(2), 0.05)
	else:
		neck.rotation.z = lerp_angle(neck.rotation.z, deg_to_rad(0), 0.05)
	
	if input_dir.y > 0:
		$Neck/AnimationPlayer.play("bob")
	elif input_dir.y < 0:
		$Neck/AnimationPlayer.play("bob")
	else:
		$Neck/AnimationPlayer.stop()
	
	move_and_slide()
	
	#shooting
	if Input.is_action_pressed("shoot") && Globals.ammoInGun > 0:
		if !revolver_animation.is_playing() && gunIsLowered == false:
			revolver_animation.play("Shooting")
			if hitscan.is_colliding():
				if hitscan.get_collider().is_in_group("enemy"):
					hitscan.get_collider().hit()
			Globals.ammoInGun -= 1
	
	if Input.is_action_pressed("reload") && Globals.ammoInGun != 6:
		if !revolver_animation.is_playing() && gunIsLowered == false:
			revolver_animation.play("reload")
			var diff = 6 - Globals.ammoInGun
			Globals.ammoLeft = Globals.ammoLeft - diff
			Globals.ammoInGun = Globals.ammoInGun + diff
	
#Lower the gun when near a wall
	if gunIsLowered == false && nearWallRay.is_colliding() || is_sprinting:
		revolver_animation.play("gun_lowered");
		gunIsLowered = true;
	elif gunIsLowered == true && !nearWallRay.is_colliding():
		revolver_animation.play("gun_raised");
		gunIsLowered = false;

func _input(event):
	if event.is_action("interact") && interactionRay.is_colliding():
		emit_signal("itemInteract", interactionRay.get_collider())

func hit():
	emit_signal("player_hit")

func _on_cultist_player_hit():
	Globals.playerHealth -= 10;
	hud.get_child(0).visible = true
	await get_tree().create_timer(0.2).timeout
	hud.get_child(0).visible = false
	if Globals.playerHealth <= 0:
		print("you ded")
