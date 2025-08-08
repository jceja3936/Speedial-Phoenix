extends Control

func _ready() -> void:
    SignalBus.paused.connect(paused)
    SignalBus.unPaused.connect(unPaused)
    hide()

func paused():
    show()
    $VBoxContainer/Resume.grab_focus()
    MenuMusic.playMusic()

func unPaused():
    hide()
    $ambience.stream_paused = true
    MenuMusic.pauseMusic()

func _on_resume_pressed() -> void:
    hide()
    await get_tree().create_timer(.2).timeout
    SignalBus.emit_signal("unPaused")


func _on_exit_pressed() -> void:
    Manager.next_scene = "res://scenes/UIscenes/start_menu.tscn"
    Manager.startNextScene()


func _on_retry_pressed() -> void:
    Manager.reset()
    Manager.startNextScene()
