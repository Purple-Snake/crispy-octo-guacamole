extends CharacterBody3D

enum State { PATROL, CHASE }
var state = State.PATROL

var player = null

@export var speed = 4.0
@export var attackRange = 2.5
@export var health = 3
@export var detectionRange = 15.0
@export var detectionAngle = 60.0 # degrees

@export var patrolPoints: Array[Vector3] = []
@export var playerPath : NodePath

@onready var navAgent = $NavigationAgent3D
@onready var visionRaycast = $visionRaycast
@onready var visionArea = $visionArea
@onready var animationTree = $AnimationTree
@onready var attackTimer = $attackTimer

var can_attack = true

var currentPatrolIndex = 0

signal player_hit

func _ready():
	player = get_node(playerPath)
	if patrolPoints.size() > 0:
		navAgent.set_target_position(patrolPoints[0])
	$visionTimer.start()

func _process(_delta):
	match state:
		State.PATROL:
			handle_patrol()
		State.CHASE:
			handle_chase()
			if !can_see_player():
				state = State.PATROL
				navAgent.set_target_position(patrolPoints[currentPatrolIndex])
	
#play attack player animation if the function target_is_in_range() is true
	#animationTree.set("parameters/conditions/attack", target_is_in_range())
	#animationTree.set("parameters/conditions/run", !target_is_in_range())
	if target_is_in_range() and can_attack:
		animationTree.set("parameters/conditions/attack", true)
		animationTree.set("parameters/conditions/run", false)
	else:
		animationTree.set("parameters/conditions/attack", false)
		animationTree.set("parameters/conditions/run", true)
	
	move_and_slide()

func handle_patrol():
	if navAgent.is_navigation_finished():
		currentPatrolIndex = (currentPatrolIndex + 1) % patrolPoints.size()
		navAgent.set_target_position(patrolPoints[currentPatrolIndex])

	var next_pos = navAgent.get_next_path_position()
	var delta = next_pos - global_transform.origin

	if delta.length() > 0.01:
		var direction = delta.normalized()
		velocity = direction * speed

		var look_target = Vector3(next_pos.x, global_position.y, next_pos.z)
		if not global_transform.origin.is_equal_approx(look_target):
			look_at(look_target, Vector3.UP)
	else:
		velocity = Vector3.ZERO



func handle_chase():
	navAgent.set_target_position(player.global_transform.origin)
	var next_pos = navAgent.get_next_path_position()
	var direction = (next_pos - global_transform.origin).normalized()
	velocity = direction * speed
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)

func can_see_player() -> bool:
	var to_player = player.global_position - global_position
	if to_player.length() > detectionRange:
		return false

	var forward = -transform.basis.z.normalized()
	var angle = rad_to_deg(forward.angle_to(to_player.normalized()))
	if angle > detectionAngle / 2.0:
		return false

	# Raycast check
	visionRaycast.look_at(player.global_position, Vector3.UP)
	visionRaycast.force_raycast_update()

	if visionRaycast.is_colliding():
		var collider = visionRaycast.get_collider()
		if collider == player:
			return true

	return false

# This is called periodically by a Timer to check for player presence in the vision area
func _on_vision_timer_timeout():
	var overlaps = visionArea.get_overlapping_bodies()
	for overlap in overlaps:
		if overlap == player:
			if can_see_player():
				state = State.CHASE
				break


#Check if player is in range
func target_is_in_range():
	return global_position.distance_to(player.global_position) < attackRange

func hit_finished():
	if target_is_in_range():
		emit_signal("player_hit")
	can_attack = false
	attackTimer.start()

func _on_attack_timer_timeout():
	can_attack = true


func _on_area_3d_body_part_hit(damage):
	health -= damage
	print(health)
	if health <= 0:
		animationTree.set("parameters/conditions/death", true)
		await get_tree().create_timer(4.0).timeout
		queue_free()
