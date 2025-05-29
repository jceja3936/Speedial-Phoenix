extends Camera2D

@export var player: CharacterBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = player.get_global_position()
	if Input.is_action_just_pressed("Respawn") and player.get("dead") == null:
		get_tree().reload_current_scene()


func updateAmmo(amount: int):
	$AmAm.show()
	$AmAm.text = "Ammo: " + str(amount)


func _ready() -> void:
	$AmAm.hide()
	$Respawn.hide()
