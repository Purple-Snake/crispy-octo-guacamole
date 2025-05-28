extends Node3D


@onready var player = $"../Player";
@onready var itemStaticBody = $StaticBody3D

func _ready():
	player.itemInteract.connect(_on_player_item_interact);
	
func _on_player_item_interact(itemColiderInfo):
	if itemColiderInfo == itemStaticBody:
		Globals.hasKey = true;
		queue_free();
