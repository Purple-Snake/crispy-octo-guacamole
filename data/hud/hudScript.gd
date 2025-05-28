extends Control

@onready var stolenItemValue = $objective;
@onready var playerHealth = $health;
@onready var ammoCounter = $ammo;

func _process(_delta):
	stolenItemValue.set_text("stolen items " + str(Globals.stolenItemValue));
	playerHealth.set_text("Health " + str(Globals.playerHealth));
	ammoCounter.set_text(str(Globals.ammoInGun) + "/" + str(Globals.ammoLeft));
