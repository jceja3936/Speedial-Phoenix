extends AudioStreamPlayer
var isPlaying = false
var musicSound = 0.0
var levelBeat = false
var canPlay = true


func setMusicSound():
    volume_db = musicSound
    if musicSound == -20.0:
        canPlay = false
    else:
        canPlay = true

func playMusic():
    if canPlay and !isPlaying:
        play()
        isPlaying = true
    elif isPlaying:
        resumeMusic()
func pauseMusic():
    stream_paused = true
    isPlaying = false

func resumeMusic():
    if !levelBeat and canPlay:
        stream_paused = false
        isPlaying = true