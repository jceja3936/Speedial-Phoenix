extends Control


func _on_back_pressed() -> void:
	Manager.next_scene = "res://scenes/UIscenes/start_menu.tscn"
	Manager.startNextScene()


func _on_l_3_pressed() -> void:
	print("Bruh")


func _on_l_2_pressed() -> void:
	Manager.next_scene = "res://scenes/lvlScenes/Lvl2.tscn"
	Manager.current_scene = "2"
	Manager.reset()
	Manager.startNextScene()

func _on_lel_1_pressed() -> void:
	print("Bruh??")
	Manager.next_scene = "res://scenes/lvlScenes/Lvl1.tscn"
	Manager.current_scene = "1_1"
	Manager.reset()
	Manager.startNextScene()
