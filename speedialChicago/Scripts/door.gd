extends RigidBody2D


func stopColliding():
    collision_layer = 0
    collision_mask = 0
    await get_tree().create_timer(1).timeout
    collision_layer = 1
    collision_mask = 1
