extends Control


func _ready() -> void:
    $scoreNum.text = str(Manager.score)
    $timeNum.text = "???"


func _on_exit_pressed() -> void:
    get_tree().quit()
