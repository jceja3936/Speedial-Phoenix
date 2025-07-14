extends Control


func _on_start_pressed() -> void:
	Manager.reset()
	Manager.startNextScene()


func _on_exit_pressed() -> void:
	get_tree().quit()
