extends Area3D

var damage := 1;

signal bodyPartHit(damage)

func hit():
	emit_signal("bodyPartHit", damage)
