extends Area2D

onready var direction = Vector2.ZERO
onready var sprite = $Sprite
var canChange = true
var changeSprite = false
#signal damageSignal(value)

func _physics_process(delta):
	global_position += direction * delta
	#rotation += 0.1
#	if canChange:
#		sprite.frame = changeColor()
#	if changeSprite:
#		changeSprite()
#		changeSprite = false

#Set de la direccion con velocidad
func setDirection(directionVectorSet):
	direction = directionVectorSet
#Se elimina si sale de la pantalla
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
#Pa cambiar el color de la pocion (En este caso porque son distintos por frame)
func changeColor():
	canChange = false
	$ChangeColor.start()
	return randi() % 3
#Pa cambiar el sprite
func changeSprite():
	sprite.texture = load("res://World/tileFloor.png")
#Para obtener el daño de el arma
func getDamage():
	return $Stats.damage
#Pa cambiar el color segun un timer
func _on_ChangeColor_timeout():
	canChange = true
#	changeSprite()
