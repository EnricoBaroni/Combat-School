extends "res://Enemy.gd"

func _ready():
	pass

func _physics_process(delta):
	match state:
		CHASE: #En este caso queremos que ataque mientras persigue asi que metemos ambos aqui
			chase(player)
			throw(player)
		IDLE:
			idle(delta)
