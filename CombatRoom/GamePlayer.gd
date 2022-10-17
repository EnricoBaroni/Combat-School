extends "res://Enemy.gd"
#Variables para exportar y elegir desde menu
#Posibles acciones del player
enum {
	MOVEPLAYER,
	ATTACKPLAYER
}
#Inicializamos para que no sea nunca null
var velocityPlayer = Vector2.ZERO
var canShootPlayer = true
#Creamos variables para los nodos del player
onready var animationPlayerP = $AnimationPlayer
onready var animationTreeP = $AnimationTree
onready var animationStateP = animationTree.get("parameters/playback")
#onready var healthBar = $ProgressBar
#Se entra cuando se crea el player
func _ready():
	animationTree.active = true
	#healthBar.max_value = Stats.maxHealth

#Se entra cada frame que pasa del juego
func _physics_process(delta):
	var input_vector = Vector2.ZERO #Inicializamos para que no sea null
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left") #Obtenemos input izq dcha
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up") #Obtenemos input arriba abajo
	input_vector = input_vector.normalized() #Normalizamos vector
	move(input_vector) #Llamamos a la funcion para moverse
	var attack_vector = Vector2.ZERO #Inicializamos para que no sea null
	attack_vector.x = Input.get_action_strength("attackRight") - Input.get_action_strength("attackLeft") #Obtenemos input izq dcha
	attack_vector.y = Input.get_action_strength("attackDown") - Input.get_action_strength("attackUp") #Obtenemos input arriba abajo
	attack_vector = attack_vector.normalized() #Normalizamos vector
	get_input(attack_vector) #Llamamos a la funcion para moverse
	
#	$Label.text = "Health: " + str(Stats.health)
#	healthBar.value = Stats.health

#Funcion para mover al personaje
func move(input_vector):
	if input_vector != Vector2.ZERO: #Si hemos obtenido algun input de movimiento
		animationTreeP.set("parameters/Idle/blend_position", input_vector) #Asignamos la animacion de Quieto
		animationTreeP.set("parameters/Move/blend_position", input_vector) #Asignamos la animacion de Moverse
		animationStateP.travel("Move") #Usamos la animacion Moverse
		velocityPlayer = input_vector * speed #Asignamos velocidad y direccion
	else:
		animationStateP.travel("Idle") #Usamos animacion Quieto
		velocityPlayer = Vector2.ZERO #Velocidad 0
	velocityPlayer = move_and_slide(velocityPlayer) #Nos movemos segun toque (Direccion o Quieto)
#Funcion para obtener los inputs
func get_input(attack_vector):
	if attack_vector != Vector2.ZERO and canShootPlayer: #Si hemos obtenido algun input de ataque, y no esta en cooldown (firerate)
		shoot(attack_vector) #Disparamos
		timerFireRate.start(fireRate) #Reiniciamos contador de firerate
		canShootPlayer = false #No permitimos volver a disparar 
#Funcion de disparo
func shoot(attack_vector):
	var weapon = Weapon.instance() #Instanciamos un nuevo arma
	owner.add_child(weapon) #La asignamos al player
	weapon.transform = $AttackPosition.global_transform #Hacemos que inicie en su posicion de disparo
	weapon.sprite.frame = 2 #Elegimos el sprite del proyectil
	weapon.set_collision_mask_bit(4, true) #Busca solo al enemigo
	weapon.setDirection(attack_vector * fireSpeed) #Indicamos en que direccion debe ir
#Funcion para el firerate
func _on_AttackRate_timeout():
	canShootPlayer = true #Permitimos que vuelva a disparar cuando acaba el tiempo asignado
