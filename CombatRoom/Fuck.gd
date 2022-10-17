extends Area2D

onready var direction = Vector2.ZERO

func _ready():
	$AnimationPlayer.play("Play")

func _physics_process(delta):
	global_position += direction * delta

#Set de la direccion con velocidad
func setDirection(directionVectorSet):
	direction = directionVectorSet
#Para obtener el daño de el arma
func getDamage():
	return $Stats.damage

#Se elimina si sale de la pantalla
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
