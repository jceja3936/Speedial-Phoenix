extends Node
@export var player: CharacterBody2D
var endPosition = Vector2.ZERO
var state = 1
var levelBeat = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_State(Manager.levelState)

func set_State(newState: int):
	state = newState
	match state:
		1:
			Manager.setEnemyAmount(3)
			endPosition = Vector2(-57.0, 1023)
			$start.position = Vector2(1097.0, 355.0)
		2:
			$start/CollisionShape2D.disabled = true
			Manager.setEnemyAmount(4)
			endPosition = Vector2(2214.0, 2677.0)
			$start.position = Vector2(1678.0, 2821.0)
			$start/CollisionShape2D.disabled = false
		3:
			endPosition = Vector2(-57.0, 1023)
			$start.position = Vector2(1097.0, 328.0)
		_:
			print("Bruh, Brain setState is received ", state)

	if levelBeat == true:
		Manager.setEnemyAmount(0)
		$start.position = Vector2(1097.0, 328.0)

	$end.position = endPosition


func _on_start_body_entered(body: Node2D) -> void:
	if Manager.levelState == 3:
		SignalBus.emit_signal("saveScore")
		Manager.next_scene = "res://scenes/UIscenes/end_screen.tscn"
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Manager.startNextScene()

	if body.name == "Player":
		match state:
				1:
					$blocker.position = Vector2(1107.0, 207.0)
				2:
					$blocker.position = Vector2(2079, 2598.0)
	if Manager.getEnemyAmount() == 0:
		$blocker.position = Vector2.ZERO
					

func _on_end_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if Manager.getEnemyAmount() == 0:
			match state:
				1:
					player.makeHunSave()
					SignalBus.emit_signal("saveScore")
					Manager.playerRespawnPos = Vector2(1839.0, 2611.0)
					player.position = Vector2(2121.0, 2606.0)
					Manager.levelState = 2
					set_State(2)
				2:
					levelBeat = true
					player.position = Vector2(124.0, 1038.0)
					Manager.levelState = 3
					set_State(3)
				3:
					player.position = Vector2(2121.0, 2606.0)
					set_State(2)
