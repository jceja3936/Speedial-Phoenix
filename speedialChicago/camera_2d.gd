extends Camera2D

var player: CharacterBody2D
var cameFollow = 0

func _ready() -> void:
	for node in get_tree().root.get_children():
		if node.has_meta("placed"):
			node.queue_free()
		print(node.name)
	print("DONEDONEDONEDONEDONE")

	var playerNode = ""
	match Manager.current_scene:
		"1_1":
			playerNode = "/root/Lvl1/Player"
		"1_2":
			playerNode = "/root/1_2/Player"
		"1_3":
			playerNode = "/root/lvl1END/Player"

	player = get_node(playerNode)
			
	$Cursors.top_level = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	$AmAm.hide()
	$Respawn.hide()


func setCam(type: int):
	cameFollow = type

func _process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var player_pos = player.global_position

	match cameFollow:
		0:
			position = lerp(position, (player_pos + Vector2(100, 0).rotated(get_angle_to(mouse_pos))), .2)
			$Cursors.position = player_pos
			$Cursors.offset = Vector2(800, 0).rotated(get_angle_to(mouse_pos))
		1:
			position = lerp(position, player_pos, .4)
			$Cursors.position = mouse_pos
			$Cursors.offset = Vector2.ZERO
		2:
			position = lerp(position, (player_pos + Vector2(750, 0).rotated(get_angle_to(mouse_pos))), .1)
			$Cursors.position = player_pos
			$Cursors.offset = Vector2(1600, 0).rotated(get_angle_to(mouse_pos))


	if Input.is_action_just_pressed("Respawn") and player.get("dead") == true:
		get_tree().change_scene_to_file(Manager.next_scene)


func updateAmmo(amount: int):
	$AmAm.show()
	$AmAm.top_level = true
	$AmAm.text = "Ammo: " + str(amount)
