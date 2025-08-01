extends Node

@export var player: CharacterBody2D
var state = 0
var levelBeat = false
var doneArray = [0, 0, 0]

func _ready() -> void:
	set_State(Manager.levelState)
	$Top.modulate.a = 0.0
	$Bottom.modulate.a = 0.0

func fadeInText():
	$Top.modulate.a += .04
	$Bottom.modulate.a += .04
	await get_tree().create_timer(.05).timeout
	if $Top.modulate.a <= 1.0:
		fadeInText()

func fadeOutText():
	$Top.modulate.a -= .04
	$Bottom.modulate.a -= .04
	await get_tree().create_timer(.05).timeout
	if $Top.modulate.a >= 0.0:
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
			$start.position = Vector2.ZERO
			$end.position = Vector2.ZERO

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
		elif player.get("gunPickedUp") == true:
			Manager.levelState = 3
			$block.position = Vector2.ZERO
			set_State(3)


func _on_start_body_entered(body: Node2D) -> void:
	if Manager.levelState == 3:
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
						await get_tree().create_timer(4.75).timeout
						fadeOutText()
						await get_tree().create_timer(.25).timeout
						player.set("finish", false)
						doneArray[0] = 1

				2:
					if doneArray[1] == 0:
						$block.position = Vector2(4851.0, 385.0)
						doneArray[1] = 1
						SignalBus.emit_signal("tutorialCutscens", -3)
						player.set("finish", true)
						await get_tree().create_timer(4).timeout
						player.set("finish", false)
	if Manager.getEnemyAmount() == 0:
		$block.position = Vector2.ZERO
