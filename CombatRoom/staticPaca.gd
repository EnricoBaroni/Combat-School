extends "res://Enemy.gd"

func _ready():
	pass

func _physics_process(delta):
	match state:
		CHASE:
			runToward(player)
			#throwAll()
			if changeShoot: #Un true/false para que vaya rotando entre dos disparos. Podria variar entre mas otra variable con mas posibilidades
				throwX()
			else:
				throwT()
		IDLE:
			idle(delta)
