extends AudioStreamPlayer

var isPlaying = false
var levelBeat = false

func playMusic():
    play()
    isPlaying = true


func pauseMusic():
    stream_paused = true
    isPlaying = false

func resumeMusic():
    if !levelBeat:
        stream_paused = false
        isPlaying = true