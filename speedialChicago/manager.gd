extends AudioStreamPlayer

var item_sounds = {
    "pSound": preload("res://assets/9mm.wav"),
    "sSound": preload("res://assets/Big Boing.wav")
    # Add more as needed or load dynamically
}

func playS2ound(item_name: String):
    var sound = item_sounds.get(item_name)
    if sound:
        var player = AudioStreamPlayer2D.new()
        player.stream = sound
        player.play()