extends Camera2D

var player: CharacterBody2D
var cameFollow = 0

func _ready() -> void:
	setCam(0)
	for node in get_tree().root.get_children():
		if node.has_meta("placed"):
			node.queue_free()

	var playerNode = ""
	match Manager.current_scene:
		"1_1":
			playerNode = "/root/Lvl1/Player"

	player = get_node(playerNode)
	position = player.global_position
			
	$Cursors.top_level = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

var camPos = Vector2.ZERO
var cursOffset = Vector2.ZERO

func setCam(type: int):
	cameFollow = type
	match type:
		0:
			camPos = Vector2(100, 0)
			cursOffset = Vector2(300, 0)
			speed = 5
		1:
			camPos = Vector2(0, 0)
			cursOffset = Vector2(800, 0)
		2:
			camPos = Vector2(600, 0)
			cursOffset = Vector2(600, 0)
			speed = 50

var angletoLerpBy = 0
var speed = 1

func _physics_process(_delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var player_pos = player.global_position

	angletoLerpBy = lerp_angle(angletoLerpBy, get_angle_to(mouse_pos), 1.0 - exp(- speed * _delta))

	match cameFollow:
		2:
			$Cursors.position = player_pos + cursOffset.rotated(get_angle_to(mouse_pos))
			position = lerp(position, $Cursors.position, 1.0 - exp(- speed * _delta))
		_:
			position = lerp(position, (player_pos + camPos.rotated(angletoLerpBy)), 1.0 - exp(-10 * _delta))
			$Cursors.position = player_pos + cursOffset.rotated(get_angle_to(mouse_pos))
