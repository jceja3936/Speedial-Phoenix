extends Node

var state = 0
var levelBeat = false

func _ready() -> void:
	set_State(Manager.levelState)

func set_State(newState: int):
	state = newState
	match state:
		1:
			Manager.setEnemyAmount(1)
		2:
			Manager.setEnemyAmount(1)
			$start.position = Vector2(5580.0, 389.0)
			$end.position = Vector2(5941.0, 193.0)
			$end.rotation_degrees = 90
			$block.position = Vector2.ZERO

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
					set_State(2)
				2:
					Manager.levelState = 2
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
					$block.position = Vector2(3305.0, 411.0)
				2:
					$block.position = Vector2(5950.0, -81.0)
	if Manager.getEnemyAmount() == 0:
		$block.position = Vector2.ZERO
