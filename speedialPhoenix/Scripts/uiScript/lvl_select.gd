extends Control

func _ready():
	Manager.reset()
	$GridContainer/lel1.grab_focus()

func _on_back_pressed() -> void:
	Manager.next_scene = "res://scenes/UIscenes/start_menu.tscn"
	Manager.startNextScene()


func _on_l_3_pressed() -> void:
	Manager.next_scene = "res://scenes/lvlScenes/Lvl3.tscn"
	Manager.current_scene = "3"
	showCharSel()
	

func _on_l_2_pressed() -> void:
	Manager.next_scene = "res://scenes/lvlScenes/Lvl2.tscn"
	Manager.current_scene = "2"
	showCharSel()


func _on_lel_1_pressed() -> void:
	Manager.next_scene = "res://scenes/lvlScenes/Lvl1.tscn"
	Manager.current_scene = "1_1"
	Manager.playerRespawnPos = Vector2(418.0, 145.0)
	showCharSel()


func _on_tut_pressed() -> void:
	Manager.next_scene = "res://scenes/lvlScenes/tutorial.tscn"
	Manager.current_scene = "0"
	showCharSel()

func showCharSel():
	$charSel.show()
	modulate.a = 0.5

func hideShowCharSel():
	print("TO DO LOL")