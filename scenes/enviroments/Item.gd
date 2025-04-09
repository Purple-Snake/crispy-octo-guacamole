extends Node3D

@export var itemValue = 10;

@onready var player = $"../Player";
@onready var itemStaticBody = $MeshInstance3D/StaticBody3D;

signal itemTaken;
func _ready():
	player.itemInteract.connect(_on_player_item_interact);
	
	
func _on_player_item_interact(itemColiderInfo):
	if itemColiderInfo == itemStaticBody:
		Globals.stolenItemValue += itemValue;
		queue_free();
