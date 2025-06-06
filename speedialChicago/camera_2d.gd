extends Camera2D

@export var player: CharacterBody2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	position = player.get_global_position()
	if Input.is_action_just_pressed("Respawn") and player.get("dead") == null:
		get_tree().change_scene_to_file("res://scenes/level.tscn")


func updateAmmo(amount: int):
	$AmAm.show()
	$AmAm.text = "Ammo: " + str(amount)


func _ready() -> void:
	$AmAm.hide()
	$Respawn.hide()
	for node in get_tree().root.get_children():
		if node.has_meta("placed"):
			node.queue_free()
