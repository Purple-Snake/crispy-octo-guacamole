extends CharacterBody3D

var player = null;

@export_category("vars")
@export var speed = 4.0;
@export var attackRange = 2.5;
@export var health = 3;

@export_category("other stuff")
@export var playerPath : NodePath;

@onready var navAgent = $NavigationAgent3D;

func _ready():
	player = get_node(playerPath);
	

func _process(_delta):
	velocity = Vector3.ZERO;
	
	#navigation towards the player
	navAgent.set_target_position(player.global_transform.origin);
	var next_nav_point = navAgent.get_next_path_position();
	velocity = (next_nav_point - global_transform.origin).normalized() * speed;
	
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	move_and_slide();


func _on_hitbox_body_part_hit(damage):
	health -= damage;
	print(health);
	if health <= 0:
		queue_free();
