extends Node3D


@onready var player = $"../Player";
@onready var itemStaticBody = $MeshInstance3D/StaticBody3D;
@onready var safeAnimationPlayer = $AnimationPlayer;
func _ready():
	player.itemInteract.connect(_on_player_item_interact);
	
	
func _on_player_item_interact(itemColiderInfo):
	if itemColiderInfo == itemStaticBody && Globals.hasKey:
		safeAnimationPlayer.play("SafeOpeining")
	else:
		print("you need a key")
