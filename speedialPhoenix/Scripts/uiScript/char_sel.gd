extends Control

var francisTween = .8
var clareTween = .8

var francisFocus = false
var clareFocus = true

func _ready():
	$francis.grab_focus()
	$Claire.disabled = false
	$francis.disabled = false
	if Manager.chosenChapter == "res://scenes/UIscenes/chap1.tscn" and Manager.francisLevels[2] == "0":
		$Claire.disabled = true
	if Manager.chosenChapter == "res://scenes/UIscenes/chap2.tscn" and Manager.clareLevels[2] == "0":
		$francis.disabled = true
	
func _physics_process(_delta: float) -> void:
	francisTweener(francisFocus)
	clareTweener(clareFocus)
	$francis/Sprite2D.material.set_shader_parameter("myOpaq", francisTween)
	$Claire/Sprite2D2.material.set_shader_parameter("myOpaq", clareTween)


func clareTweener(up: bool):
	match up:
		true:
			if clareTween < .8:
				clareTween += .05
		false:
			if clareTween > 0.0:
				clareTween -= .05
	await get_tree().create_timer(.05).timeout

func francisTweener(up: bool):
	match up:
		true:
			if francisTween < .8:
				francisTween += .05
		false:
			if francisTween > 0.0:
				francisTween -= .05
	await get_tree().create_timer(.05).timeout
	
		
func _on_claire_pressed() -> void:
	Manager.chosenChar = 1
	Manager.startNextScene()

func _on_francis_pressed() -> void:
	Manager.chosenChar = 0
	Manager.startNextScene()


func _on_back_pressed() -> void:
	print(Manager.chosenChapter)
	Manager.next_scene = Manager.chosenChapter
	Manager.startNextScene()


func _on_claire_focus_exited() -> void:
	clareFocus = true


func _on_claire_focus_entered() -> void:
	clareFocus = false


func _on_francis_focus_exited() -> void:
	francisFocus = true


func _on_francis_focus_entered() -> void:
	francisFocus = false
