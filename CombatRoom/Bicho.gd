extends Area2D

onready var direction = Vector2.ZERO
onready var player = get_tree().root.get_child(0).getPlayer() #Obtenemos el GamePlayer para que siempre tengamos su node
onready var speed = $Stats.fireSpeed

func _ready():
	$AnimationPlayer.play("Play")
	getSpeed()

func _physics_process(delta):
	direction = global_position.direction_to(player.global_position) #Nuestra direccion es hacia el jugador
	global_position += direction * speed * delta

#Set de la direccion con velocidad
func setDirection(directionVectorSet):
	direction = directionVectorSet
#Para obtener el daño de el arma
func getDamage():
	return $Stats.damage
func getSpeed():
	speed = speed * rand_range(1,3)
	return speed
