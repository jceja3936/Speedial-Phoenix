extends Control

var positionCurve: Curve = preload("res://assets/ChapSelCurve.tres")
var whereAt = 200.0
var x = 0.0
var levelPos = 0.0
var canMove = true
var selected = false

func _ready():
	$Main/Chap1.grab_focus()
	xGlide()

func wait():
	if selected:
		return
	await get_tree().create_timer(.25).timeout
	canMove = true
	set_process_input(true)

func _physics_process(_delta):
	$Main.position.x = positionCurve.sample(x)
	if (Input.is_action_just_pressed("Right") or Input.is_action_just_pressed("Up") or Input.is_action_just_pressed("ui_right")) and canMove:
		if levelPos < 1.0:
			canMove = false
			levelPos += 1.0
			set_process_input(false)
			wait()
	elif (Input.is_action_just_pressed("Left") or Input.is_action_just_pressed("Down") or Input.is_action_just_pressed("ui_left")) and canMove:
		if levelPos > -1.0:
			canMove = false
			levelPos -= 1.0
			set_process_input(false)
			wait()

	if (Input.is_action_just_pressed("Respawn") or Input.is_action_just_pressed("ui_accept")) and !selected:
		match levelPos:
			-1.0:
				selected = true
				Manager.next_scene = "res://scenes/UIscenes/start_menu.tscn"
				Manager.startNextScene()
			0.0:
				Manager.chosenChapter = "res://scenes/UIscenes/chap1.tscn"
				selected = true
				Manager.next_scene = "res://scenes/UIscenes/chap1.tscn"
				Manager.startNextScene()
			1.0:
				selected = true
				Manager.chosenChapter = "res://scenes/UIscenes/chap2.tscn"
				Manager.next_scene = "res://scenes/UIscenes/chap2.tscn"
				Manager.startNextScene()
	
func xGlide():
	if selected:
		return
	if levelPos > -1.0:
		x = lerp(x, levelPos, .05)
		await get_tree().create_timer(.01).timeout
	elif levelPos == -1.0:
		x = lerp(x, 0.0, .05)
		await get_tree().create_timer(.01).timeout
	xGlide()
