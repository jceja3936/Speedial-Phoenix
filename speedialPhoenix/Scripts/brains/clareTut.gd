extends Node2D

@export var player: CharacterBody2D
@export var top: Label
@export var bottom: Label
var state = 0
var levelBeat = false
var doneArray = [0, 0, 0, 0]
var fadeInTime = 4.5

var francis: PackedScene = load("res://scenes/Characters/player.tscn")
var claire: PackedScene = load("res://scenes/Characters/claire.tscn")

func getPlayer():
	player = get_node("/root/Lvl-2/Player")

func _ready() -> void:
	Manager.gamePaused = false
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
		add_child.call_deferred(character)