extends Control


func _on_sound_drag_ended(_value_changed: bool) -> void:
    Manager.sfx = $main/Sounds/sound.value
    
func _on_music_drag_ended(_value_changed: bool) -> void:
    Manager.musicSound = $main/Music/music.value
    
func _on_exit_pressed() -> void:
    Manager.next_scene = "res://scenes/UIscenes/start_menu.tscn"
    Manager.startNextScene()
