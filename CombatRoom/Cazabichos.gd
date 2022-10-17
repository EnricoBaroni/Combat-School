extends "res://Enemy.gd"

func _physics_process(delta):
	match state:
		CHASE: #En este caso solo queremos que persiga
			throwInsects(player)
		IDLE:
			idle(delta)
