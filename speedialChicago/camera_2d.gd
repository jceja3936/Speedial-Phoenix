extends Camera2D

@export var player: CharacterBody2D
var cameFollow = true

# Called every frame. 'delta' is the elapsed time since the previous frame.

func setCam(yes: bool):
	cameFollow = yes

func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var player_pos = player.get_global_position()

	if cameFollow:
		position = lerp(position, (player_pos + Vector2(100, 0).rotated(get_angle_to(mouse_pos))), .2)
		$Cursors.position = player_pos
		$Cursors.offset = Vector2(800, 0).rotated(get_angle_to(mouse_pos))
	else:
		position = lerp(position, player_pos, .4)
		$Cursors.position = mouse_pos
		$Cursors.offset = Vector2.ZERO


	if Input.is_action_just_pressed("Respawn") and player.get("dead") == true:
		get_tree().change_scene_to_file("res://scenes/Lvl1.tscn")


func updateAmmo(amount: int):
	$AmAm.show()
	$AmAm.top_level = true
	$AmAm.text = "Ammo: " + str(amount)


func _ready() -> void:
	$Cursors.top_level = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	$AmAm.hide()
	$Respawn.hide()
	for node in get_tree().root.get_children():
		if node.has_meta("placed"):
			node.queue_free()
