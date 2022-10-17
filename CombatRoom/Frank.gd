extends "res://Enemy.gd"

func _ready():
	pass

func _physics_process(delta):
	match state:
		CHASE: #En este caso solo queremos que persiga
			chase(player)
		IDLE:
			idle(delta)
