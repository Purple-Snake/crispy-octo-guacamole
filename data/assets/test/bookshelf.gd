extends Node3D

@onready var animationNode = $AnimationPlayer;

func _process(delta):
	if Globals.buttonIsPressed == true:
		animationNode.play("MoveBookshelf");
