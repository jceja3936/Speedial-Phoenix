extends RigidBody2D

func stopColliding():
	collision_layer = 0
	collision_mask = 5
