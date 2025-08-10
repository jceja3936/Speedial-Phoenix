extends Control


func _on_claire_pressed() -> void:
	Manager.chosenChar = 1
	Manager.startNextScene()

func _on_francis_pressed() -> void:
	Manager.chosenChar = 0
	Manager.startNextScene()
