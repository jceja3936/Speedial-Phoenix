extends Node2D

var player
var enemy

@export var A: Node2D
@export var B: Node2D
@export var C: Node2D
@export var D: Node2D

var navArray = []
var degree = 0
var closestNode

func _ready() -> void:
	player = get_node("/root/Level/Player")
	if A:
		navArray.append(A)
	if B:
		navArray.append(B)
	if C:
		navArray.append(C)
	if D:
		navArray.append(D)
	degree = navArray.size()


func findClosestToMe(obj: Vector2) -> Node2D:
	if self.name != "WalkWay":
		return

	var d2Obj = 20000

	for node in get_node("/root/Level/Walk").get_children():
			if node.position.distance_to(obj) < d2Obj:
				d2Obj = node.position.distance_to(obj)
				closestNode = node
	return closestNode
	
func findNext(endPos: Vector2, visited: Array) -> Node2D:
	var distanceToPlayer = 20000
	for i in range(degree):
		if navArray[i].position.distance_to(endPos) < distanceToPlayer and not visited.has(navArray[i]):
			distanceToPlayer = navArray[i].position.distance_to(endPos)
			closestNode = navArray[i]
	return closestNode
