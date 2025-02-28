extends Node3D

const speed = 100.0;

@onready var mesh = $MeshInstance3D;
@onready var raycast = $RayCast3D;
@onready var particale = $GPUParticles3D;

func _process(delta):
	position += transform.basis * Vector3(0, 0, -speed) * delta;
	if raycast.is_colliding():
		print("bullet collided")
		mesh.visible = false
		particale.emitting = true
		raycast.enabled = false;
		if raycast.get_collider().is_in_group("enemy"):
			raycast.get_collider().hit();
		await  get_tree().create_timer(1.0).timeout
		queue_free()
	

func on_timer_timeout():
	queue_free()
