extends Control

@onready var stolenItemValue = $objective;
@onready var playerHealth = $health;
@onready var ammoCounter = $ammo;
@onready var crosshair = $Container/G344

func _process(_delta):
	stolenItemValue.set_text("stolen items " + str(Globals.stolenItemValue));
	playerHealth.set_text("Health " + str(Globals.playerHealth));
	ammoCounter.set_text(str(Globals.ammoInGun) + "/" + str(Globals.ammoLeft));


func _ready():
	crosshair.position.x = get_viewport().size.x / 2
	crosshair.position.y = get_viewport().size.y / 2
