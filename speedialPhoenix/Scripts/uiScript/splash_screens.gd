extends Control

var inTime: float = .5
var fadeInTime: float = .5
var pTime: float = .75
var foTime: float = .5
var outTime: float = .5

func _ready():
    $mine.hide()
    loadGodot()

func loadGodot():
    $godot.modulate.a = 0.0
    var tween = self.create_tween()
    tween.tween_interval(inTime)
    tween.tween_property($godot, "modulate:a", 1.0, fadeInTime)
    tween.tween_interval(pTime)
    tween.tween_property($godot, "modulate:a", 0.0, foTime)
    tween.tween_interval(outTime)
    await tween.finished
    loadMine()


func loadMine():
    $mine.modulate.a = 0.0
    $mine.show()
    var tween2 = self.create_tween()
    tween2.tween_interval(inTime)
    tween2.tween_property($mine, "modulate:a", 1.0, fadeInTime)
    tween2.tween_interval(pTime)
    tween2.tween_property($mine, "modulate:a", 0.0, foTime)
    tween2.tween_interval(outTime)
    await tween2.finished
    Manager.next_scene = "res://scenes/UIscenes/start_menu.tscn"
    Manager.startNextScene()