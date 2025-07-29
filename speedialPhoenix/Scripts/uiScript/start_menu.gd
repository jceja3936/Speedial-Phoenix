extends Control


func _on_start_pressed() -> void:
	Manager.next_scene = "res://scenes/lvlScenes/Lvl1.tscn"
	Manager.current_scene = "1_1"
	Manager.reset()
	Manager.startNextScene()


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_continue_pressed() -> void:
	Manager.next_scene = "res://scenes/UIscenes/lvl_select.tscn"
	Manager.startNextScene()


func _on_button_pressed() -> void:
	Manager.next_scene = "res://scenes/UIscenes/options.tscn"
	Manager.startNextScene()
