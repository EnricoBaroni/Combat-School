extends "res://Enemy.gd"

func _ready():
	pass

func _physics_process(delta):
	match state:
		CHASE:
			chase(player)
			if global_position.distance_to(player.global_position) <= 90: #Cuando el jugador se acerca lo suficiente, ostia que va
				state = ATTACK
		ATTACK:
			attackMelee(player)
			if global_position.distance_to(player.global_position) > 90 and attackEnded: #Controlamos que aunque el tio entre y salga de radio de alcance, complete la ostia antes de empezar a perseguir
				state = CHASE
		IDLE:
			idle(delta)
