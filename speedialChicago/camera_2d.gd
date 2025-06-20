extends Camera2D

@export var player: CharacterBody2D
var cameFollow = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if cameFollow:
		position = lerp(player.global_position, get_global_mouse_position(), .5);

	if Input.is_action_just_pressed("Respawn") and player.get("dead") == null:
		get_tree().change_scene_to_file("res://scenes/level.tscn")

	if Input.is_action_just_pressed("esc") and cameFollow:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		cameFollow = false
	elif Input.is_action_just_pressed("esc") and !cameFollow:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
		cameFollow = true


func updateAmmo(amount: int):
	$AmAm.show()
	$AmAm.text = "Ammo: " + str(amount)


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	$AmAm.hide()
	$Respawn.hide()
	for node in get_tree().root.get_children():
		if node.has_meta("placed"):
			node.queue_free()
