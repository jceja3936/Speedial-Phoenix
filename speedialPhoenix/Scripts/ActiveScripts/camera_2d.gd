extends Camera2D

var player: CharacterBody2D
var cameFollow = 0
var camPos = Vector2.ZERO
var cursOffset = Vector2.ZERO

func getPlayer():
	var playerNode = ""
	match Manager.current_scene:
		"0":
			playerNode = "/root/tutorial/Player"
		"1_1":
			playerNode = "/root/Lvl1/Player"
		"2":
			playerNode = "/root/Lvl2/Player"
		"3":
			playerNode = "/root/Lvl3/Player"

	player = get_node(playerNode)

func _ready() -> void:
	if Manager.playerRespawnPos != Vector2.ZERO:
		position = Manager.playerRespawnPos
	SignalBus.playerReady.connect(getPlayer)
	SignalBus.playCutscene.connect(leave)
	SignalBus.tutorialCutscens.connect(tutScene)
	setCam(0)
	for node in get_tree().root.get_children():
		if node.has_meta("placed"):
			node.queue_free()

			
	$Cursors.top_level = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func tutScene(part):
	speed = 1.6
	cameFollow = part
	reset(5)

func reset(time):
	await get_tree().create_timer(time).timeout
	setCam(0)

func leave():
	speed = .8
	cameFollow = -1

func setCam(type: int):
	cameFollow = type
	match type:
		0:
			camPos = Vector2(100, 0)
			cursOffset = Vector2(300, 0)
			speed = 5
		1:
			camPos = Vector2(0, 0)
			cursOffset = Vector2(0, 0)
		2:
			camPos = Vector2(600, 0)
			cursOffset = Vector2(600, 0)
			speed = 15

var angletoLerpBy = 0
var speed = 1


func _physics_process(_delta: float) -> void:
	if player == null:
		return
	var dir = Input.get_vector("rStickleft", "riStickRight", "rStickUp", "rStickDown")
	if dir:
		var center = Vector2(get_viewport().size / 2)
		var target = center + (dir * 600)
		Input.warp_mouse(target)
	var player_pos = player.global_position

	match cameFollow:
		-1:
			position = lerp(position, player_pos + Vector2(0, -3000), 1.0 - exp(- speed * _delta))
			return
		-2:
			position = lerp(position, Vector2(2865.0, 396.0), 1.0 - exp(- speed * _delta))
			return
		-3:
			position = lerp(position, Vector2(4420.0, 396.0), 1.0 - exp(- speed * _delta))
			return
		-4:
			position = lerp(position, Vector2(5944.0, 396.0), 1.0 - exp(- speed * _delta))
			return
		-5:
			position = lerp(position, Vector2(5944.0, -478.0), 1.0 - exp(- speed * _delta))
			return


	var mouse_pos = get_global_mouse_position()

	angletoLerpBy = lerp_angle(angletoLerpBy, get_angle_to(mouse_pos), 1.0 - exp(- speed * _delta))

	match cameFollow:
		2:
			$Cursors.position = player_pos + cursOffset.rotated(get_angle_to(mouse_pos))
			position = lerp(position, $Cursors.position, 1.0 - exp(- speed * _delta))
		_:
			position = lerp(position, (player_pos + camPos.rotated(angletoLerpBy)), 1.0 - exp(-10 * _delta))
			$Cursors.position = player_pos + cursOffset.rotated(get_angle_to(mouse_pos))
