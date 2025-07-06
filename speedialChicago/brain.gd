extends Node
@export var player: CharacterBody2D
var endPosition = Vector2.ZERO
var state = 1
var levelBeat = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setState(Manager.levelState)

func setState(newState: int):
	state = newState
	match state:
		1:
			Manager.setEnemyAmount(3)
			endPosition = Vector2(-57.0, 1023)
			$start.position = Vector2(1097.0, 328.0)
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
			print("Bruh")

	if levelBeat == true:
		Manager.setEnemyAmount(0)
		$start.position = Vector2(1097.0, 328.0)

	$end.position = endPosition


func _on_start_body_entered(body: Node2D) -> void:
	print("ASHDAHDHS")
	if Manager.levelState == 3:
		get_tree().quit()

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
					Manager.playerRespawnPos = Vector2(1839.0, 2611.0)
					player.position = Vector2(2121.0, 2606.0)
					Manager.levelState = 2
					setState(2)
				2:
					levelBeat = true
					player.position = Vector2(124.0, 1038.0)
					Manager.levelState = 3
					setState(3)
				3:
					player.position = Vector2(2121.0, 2606.0)
					setState(2)
