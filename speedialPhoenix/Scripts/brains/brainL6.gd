extends Node2D
var player: CharacterBody2D
var endPosition = Vector2.ZERO
var state = 1
var stage = [0, 0, 0]
var levelBeat = false

var francis: PackedScene = load("res://scenes/Characters/player.tscn")
var claire: PackedScene = load("res://scenes/Characters/claire.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.playerReady.connect(getPlayer)
	var character = null
	match Manager.chosenChar:
		0:
			character = francis.instantiate()
		1:
			character = claire.instantiate()

	if character != null:
		character.name = "Player"
		add_child.call_deferred(character)
	
	MenuMusic.pauseMusic()
	GameAudio.levelBeat = false
	Manager.gamePaused = false
	set_State(Manager.levelState)
	
func getPlayer():
	player = get_node("/root/Lvl6/Player")

func set_State(newState: int):
	state = newState
	match state:
		1:
			print("S")

	if levelBeat == true:
		Manager.setEnemyAmount(0)