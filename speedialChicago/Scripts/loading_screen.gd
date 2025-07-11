extends Control

var stopIt = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ResourceLoader.load_threaded_request(Manager.next_scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var progress = []
	ResourceLoader.load_threaded_get_status(Manager.next_scene, progress)
	if !stopIt:
		$ParallaxBackground/percent.text = str(progress[0] * 100) + "%"

	if progress[0] == 1:
		stopIt = true
		$ParallaxBackground/percent.text = "100%"
		var packed_scene = ResourceLoader.load_threaded_get(Manager.next_scene)
		startingNext(packed_scene)

func startingNext(theScene):
	get_tree().change_scene_to_packed(theScene)
	queue_free()
