extends Control

var charSelect: PackedScene = preload("res://scenes/UIscenes/char_sel.tscn")

var focuses = [0, 0, 0]
var tweeners = [.8, .8, 0.8]

func _ready():
	Manager.reset()

	if Manager.francisLevels[0] == "0":
		$GridContainer/l2.disabled = true
	if Manager.francisLevels[1] == "0":
		$GridContainer/l3.disabled = true


	$GridContainer/lel1.grab_focus()

func _physics_process(_delta: float) -> void:
	l1Tweener(focuses[0])
	l2Tweener(focuses[1])
	l3Tweener(focuses[2])
	$GridContainer/lel1/Node2D.material.set_shader_parameter("myOpaq", tweeners[0])
	$GridContainer/l2/Node2D.material.set_shader_parameter("myOpaq", tweeners[1])
	$GridContainer/l3/Node2D.material.set_shader_parameter("myOpaq", tweeners[2])

func l1Tweener(up: int):
	match up:
		0:
			if tweeners[0] < .8:
				tweeners[0] += .05
		1:
			if tweeners[0] > 0.0:
				tweeners[0] -= .05
	await get_tree().create_timer(.05).timeout

func l2Tweener(up: int):
	match up:
		0:
			if tweeners[1] < .8:
				tweeners[1] += .05
		1:
			if tweeners[1] > 0.0:
				tweeners[1] -= .05
	await get_tree().create_timer(.05).timeout

func l3Tweener(up: int):
	match up:
		0:
			if tweeners[2] < .8:
				tweeners[2] += .05
		1:
			if tweeners[2] > 0.0:
				tweeners[2] -= .05
	await get_tree().create_timer(.05).timeout

func _on_back_pressed() -> void:
	Manager.next_scene = "res://scenes/UIscenes/ChapSel.tscn"
	Manager.startNextScene()


func _on_l_3_pressed() -> void:
	Manager.next_scene = "res://scenes/lvlScenes/Lvl3.tscn"
	Manager.current_scene = "3"
	Manager.playerRespawnPos = Vector2(714.0, 136.0)
	showCharSel()
	

func _on_l_2_pressed() -> void:
	Manager.next_scene = "res://scenes/lvlScenes/Lvl2.tscn"
	Manager.current_scene = "2"
	Manager.playerRespawnPos = Vector2(271.0, 756.0)
	showCharSel()


func _on_lel_1_pressed() -> void:
	Manager.next_scene = "res://scenes/lvlScenes/Lvl1.tscn"
	Manager.current_scene = "1"
	Manager.playerRespawnPos = Vector2(418.0, 145.0)
	showCharSel()


func _on_tut_pressed() -> void:
	Manager.next_scene = "res://scenes/lvlScenes/tutorial.tscn"
	Manager.current_scene = "tutorial"
	Manager.playerRespawnPos = Vector2(1409.0, 383.0)
	Manager.chosenChar = 0
	Manager.startNextScene()

func showCharSel():
	get_tree().change_scene_to_packed(charSelect)

func _on_lel_1_focus_entered() -> void:
	focuses = [1, 0, 0]

func _on_l_2_focus_entered() -> void:
	focuses = [0, 1, 0]


func _on_l_3_focus_entered() -> void:
	focuses = [0, 0, 1]


func _on_lel_1_focus_exited() -> void:
	focuses = [0, 0, 0]

func _on_l_2_focus_exited() -> void:
	focuses = [0, 0, 0]


func _on_l_3_focus_exited() -> void:
	focuses = [0, 0, 0]
