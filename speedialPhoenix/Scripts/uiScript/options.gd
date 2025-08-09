extends Control

func _ready():
	$slide.mouse_filter = Control.MOUSE_FILTER_STOP
	$exit.grab_focus()

func _on_sound_drag_ended(_value_changed: bool) -> void:
	Manager.sfx = $main/Sounds/sound.value
    
func _on_music_drag_ended(_value_changed: bool) -> void:
	GameAudio.musicSound = $main/Music/music.value
	GameAudio.setMusicSound()
    
func _on_exit_pressed() -> void:
	Manager.next_scene = "res://scenes/UIscenes/start_menu.tscn"
	Manager.startNextScene()


func _on_slide_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$Controlls.text = "Controls:
		Movement                  Left Stick
		Camera                      Right Stick
		Pick Up/Drop             L1
		Fire                             R2
		Finish                          X
		Look Far                     L2"
	else:
		$Controlls.text = "Controls:
		Movement                  WASD
		Camera                      Mouse
		Pick Up/Drop             F
		Fire                             LMB
		Finish                          Space
		Look Far                     RMB (Hold)
		"
