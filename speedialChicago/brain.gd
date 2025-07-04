extends Node
@export var player: CharacterBody2D
var warpPosition = Vector2.ZERO
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
			warpPosition = Vector2(-57.0, 1023)
		2:
			Manager.setEnemyAmount(4)
			warpPosition = Vector2(2214.0, 2677.0)
		_:
			print("Bruh")

	if levelBeat == true:
		Manager.setEnemyAmount(0)

	$Area2D/CollisionShape2D.position = warpPosition

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if Manager.getEnemyAmount() == 0:
			match state:
				1:
					player.makeHunSave()
					Manager.playerRespawnPos = Vector2(2121.0, 2606.0)
					player.position = Vector2(2121.0, 2606.0)
					Manager.levelState = 2
					setState(2)
				2:
					levelBeat = true
					player.position = Vector2(124.0, 1038.0)
					Manager.playerRespawnPos = Vector2(124.0, 1038.0)
					Manager.levelState = 3
					setState(1)
