extends Control


func _ready() -> void:
    $scoreNum.text = str(Manager.score)
    $timeNum.text = str(Manager.timer).pad_decimals(2)


func _on_exit_pressed() -> void:
    get_tree().quit()
