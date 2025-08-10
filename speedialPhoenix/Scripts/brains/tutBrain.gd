extends Node

@export var player: CharacterBody2D
@export var top: Label
@export var bottom: Label
var state = 0
var levelBeat = false
var doneArray = [0, 0, 0, 0]
var fadeInTime = 4.5

var francis: PackedScene = load("res://scenes/player.tscn")
var claire: PackedScene = load("res://scenes/claire.tscn")

func _ready() -> void:
	MenuMusic.pauseMusic()
	SignalBus.playerReady.connect(getPlayer)
	var character = null
	match Manager.chosenChar:
		0:
			character = francis.instantiate()
		1:
			character = claire.instantiate()

	if character != null:
		character.name = "Player"
		get_parent().add_child.call_deferred(character)
	
			
	GameAudio.isPlaying = true
	GameAudio.pauseMusic()
	$textContainer.position = Vector2(2869.0, 55.0)
	set_State(Manager.levelState)
	top.modulate.a = 0.0
	bottom.modulate.a = 0.0

func getPlayer():
	player = get_node("/root/tutorial/Player")

func _physics_process(_delta: float) -> void:
	if state == 4:
		GameAudio.pauseMusic()
		GameAudio.levelBeat = true
		$arrow.show()
		$arrow.position = player.global_position + Vector2(0, 100)
		$arrow.look_at($end.global_position)


func fadeInText():
	top.modulate.a += .04
	bottom.modulate.a += .04
	await get_tree().create_timer(.05).timeout
	if top.modulate.a <= 1.0:
		fadeInText()

func fadeOutText():
	top.modulate.a -= .04
	bottom.modulate.a -= .04
	await get_tree().create_timer(.05).timeout
	if top.modulate.a >= 0.0:
		fadeOutText()


func set_State(newState: int):
	state = newState
	match state:
		1:
			Manager.setEnemyAmount(1)
			$start.position = Vector2(2500.0, 380.0)
			$end.position = Vector2(3118.0, 380.0)
		2:
			Manager.setEnemyAmount(1)
			$start.position = Vector2(4035.0, 380.0)
			$end.position = Vector2(4670.0, 380.0)

		3:
			$start.position = Vector2(5044.0, 394.0)
			$end.position = Vector2(5959.0, 155.0)
			$end.rotation_degrees = 90
		4:
			$start.position = Vector2(5954.0, 68.0)
			$start.rotation_degrees = 90
			$end.position = Vector2(5938.0, -867.0)
		_:
			print("Bruh, Brain setState is received ", state)

	if levelBeat == true:
		Manager.setEnemyAmount(0)


func _on_end_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if Manager.getEnemyAmount() == 0:
			match state:
				1:
					Manager.levelState = 2
					$block.position = Vector2.ZERO
					set_State(2)
				3:
					Manager.levelState = 4
					$block.position = Vector2.ZERO
					set_State(4)
				4:
					SignalBus.emit_signal("playCutscene")
					SignalBus.emit_signal("saveWB")
					SignalBus.emit_signal("saveScore")
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
					await get_tree().create_timer(2).timeout
					Manager.next_scene = "res://scenes/UIscenes/end_screen.tscn"

					Manager.startNextScene()
		elif player.get("gunPickedUp") == true and state == 2:
			Manager.levelState = 3
			$block.position = Vector2.ZERO
			set_State(3)


func _on_start_body_entered(body: Node2D) -> void:
	if Manager.levelState == 5:
		SignalBus.emit_signal("playCutscene")
		SignalBus.emit_signal("saveScore")
		SignalBus.emit_signal("saveWB")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		await get_tree().create_timer(2).timeout
		Manager.next_scene = "res://scenes/UIscenes/end_screen.tscn"

		Manager.startNextScene()

	if body.name == "Player":
		match state:
				1:
					if doneArray[0] == 0:
						$block.position = Vector2(3305.0, 411.0)
						SignalBus.emit_signal("tutorialCutscens", -2)
						player.set("finish", true)
						fadeInText()
						await get_tree().create_timer(fadeInTime).timeout
						fadeOutText()
						await get_tree().create_timer(.5).timeout
						player.set("finish", false)
						doneArray[0] = 1


				2:
					if doneArray[1] == 0:
						$textContainer.position = Vector2(4421.0, 55.0)
						top.text = "This is a Weapon"
						bottom.text = "F to pick up/drop"
						$block.position = Vector2(4851.0, 385.0)
						doneArray[1] = 1
						SignalBus.emit_signal("tutorialCutscens", -3)
						player.set("finish", true)
						fadeInText()
						await get_tree().create_timer(fadeInTime).timeout
						fadeOutText()
						await get_tree().create_timer(.5).timeout
						player.set("finish", false)
				3:
					if doneArray[2] == 0:
						$textContainer.position = Vector2(5956.0, 55.0)
						top.text = "You Know
						What to Do"
						bottom.text = ""
						$block.position = Vector2(5958.0, -81.0)
						doneArray[2] = 1
						SignalBus.emit_signal("tutorialCutscens", -4)
						player.set("finish", true)
						fadeInText()
						await get_tree().create_timer(fadeInTime).timeout
						fadeOutText()
						await get_tree().create_timer(.5).timeout
						player.set("finish", false)
				4:
					if doneArray[3] == 0:
						top.modulate.a = -0.4
						bottom.modulate.a = -0.4
						$textContainer.position = Vector2(5956.0, -783.0)
						top.text = "This is a Hammer"
						bottom.text = "Use it on a Wall"
						$block.position = Vector2.ZERO
						doneArray[3] = 1
						SignalBus.emit_signal("tutorialCutscens", -5)
						player.set("finish", true)
						fadeInText()
						await get_tree().create_timer(fadeInTime).timeout
						fadeOutText()
						await get_tree().create_timer(.5).timeout
						player.set("finish", false)
	if Manager.getEnemyAmount() == 0:
		$block.position = Vector2.ZERO
