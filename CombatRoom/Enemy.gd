extends KinematicBody2D

#INICIALIZACIONES Y VARIABLES

#Stats
var type
var health
var maxHealth
var damage
var speed
var fireRate
var fireSpeed
var maxRange
#Posibles acciones
enum {
	IDLE,
	CHASE,
	ATTACK
}
#Inicializamos para que no sea nunca null
var state = CHASE #Estado con distintas acciones, por defecto que empiecen persiguiendo
var velocity = Vector2.ZERO #Vector dirección + velocidad
var canShoot = true #Si puede volver a disparar
var direction = Vector2.ZERO #La direccion del enemigo
var canChangeDirection = true #Para ver si ha pasado el tiempo para cambiar direccion random
var changeShoot = true #Para ir rotando entre dos disparos del enemigo
var attackEnded = false
#Creamos variables para los nodos
onready var animationPlayer = $AnimationPlayer #Animaciones
onready var animationTree = $AnimationTree #Animaciones segun direccion
onready var animationState = animationTree.get("parameters/playback") #Asignacion de las animaciones
onready var Weapon = preload("res://Weapon.tscn") #Instancia de arma concreta
onready var Rap = preload("res://RAP.tscn") #Instancia de arma concreta
onready var Fuck = preload("res://Fuck.tscn") #Instancia de arma concreta
onready var Yeah = preload("res://Yeah.tscn") #Instancia de arma concreta
onready var Bicho = preload("res://Bicho.tscn") #Instancia de arma concreta
onready var Stats = $Stats #Para obtener las stats
onready var timerFireRate = $AttackRate
onready var timerHitboxRate = $HitboxRate
#onready var healthBar = $ProgressBar
onready var player = get_tree().root.get_child(0).getPlayer() #Obtenemos el GamePlayer para que siempre tengamos su node

#FUNCIONES DE INICIALIZACION Y STATS

#Se entra cuando se crea el player
func _ready():
	initializeStats()
	print_debug(str(type) + "-> Health: " + str(maxHealth) + " / Damage: "  + str(damage) + " / Speed: " + str(speed) + " / FireRate: " + str(fireRate) + " / FireSpeed: " + str(fireSpeed) + " / Range: " + str(maxRange))
	animationTree.active = true #Activamos el movimiento por direccion
#	createHitbox()
	#healthBar.max_value = Stats.maxHealth
#Se entra cada frame que pasa del juego
func _physics_process(_delta):
	#healthBar.value = Stats.health
	pass
#Inicializamos nuestras stats
func initializeStats():
	type = Stats.type
	maxHealth = Stats.maxHealth
	damage = Stats.damage
	speed = Stats.speed
	fireRate = Stats.fireRate
	fireSpeed = Stats.fireSpeed
	maxRange = Stats.maxRange
func getDamage():
	return Stats.damage
#Crea un arma invisible para que si alguien nos toca reciba ese daño
#func createHitbox():
#	var hitbox = Weapon.instance() #Instanciamos un nuevo arma
#	owner.add_child(hitbox) #La asignamos al player
#	hitbox.transform = self.transform
##	hitbox.sprite.frame = 1
#	if self.get_name() == "GamePlayer":
#		hitbox.set_collision_mask_bit(0, true) #Busca solo al jugador
#	else:
#		hitbox.set_collision_mask_bit(3, true) #Busca solo al jugador
##	hitbox.setDirection(Vector2.ZERO) #Indicamos en que direccion debe ir

#FUNCIONES DE MOVIMIENTO

#Se persigue al jugador
func chase(point): #Enviamos el punto en el que esta el jugador y delta
	direction = global_position.direction_to(point.global_position) #Nuestra direccion es hacia el jugador	
	velocity = move_and_slide(direction * speed) #Asignamos velocidad y direccion y nos movemos
	animationTree.set("parameters/Idle/blend_position", direction) #Asignamos la animacion de Quieto
	animationTree.set("parameters/Move/blend_position", direction) #Asignamos la animacion de Moverse
	animationState.travel("Move") #Usamos la animacion Moverse
#Funcion para moverse hacia el jugador (No directo, tiene 180º de libertad, o los que queramos, ahora mismo 45º hacia cada lado)
func runToward(point):
	if canChangeDirection:
		direction = global_position.direction_to(point.global_position) #Nuestra direccion es hacia el jugador
		direction = direction.rotated(rand_range(-PI/2, PI/2)) #Grados de libertad para la direccion. PI/2 = 90, asi que segun ampliemos ira mas o menos directo
		canChangeDirection = false
		$changeDirection.start(2)
	velocity = move_and_slide(direction * speed) #Asignamos velocidad y direccion y nos movemos
	animationTree.set("parameters/Idle/blend_position", direction) #Asignamos la animacion de Quieto
	animationTree.set("parameters/Move/blend_position", direction) #Asignamos la animacion de Moverse
	animationState.travel("Move") #Usamos la animacion Moverse
#Se huye del jugador
func runFrom(point): #Enviamos el punto en el que esta el jugador y delta
	direction = global_position.direction_to(point.global_position) #Nuestra direccion es hacia el jugador
	velocity = move_and_slide(-direction * speed) #Asignamos velocidad y direccion (con - porque va a ser en direccion contraria) y nos movemos
	animationTree.set("parameters/Idle/blend_position", direction) #Asignamos la animacion de Quieto
	animationTree.set("parameters/Move/blend_position", direction) #Asignamos la animacion de Moverse
	animationState.travel("Move") #Usamos la animacion Moverse
#Nos quedamos quietos
func idle(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Idle") #Usamos la animacion Quieto

#FUNCIONES DE ATAQUES

#Hacer ataque melee
func attackMelee(point):
	direction = global_position.direction_to(point.global_position) #Nuestra direccion es hacia el jugador
	if canShoot:
		animationTree.set("parameters/Attack/blend_position", direction) #Asignamos la animacion de Ataque
		animationState.travel("Attack") #Usamos la animacion Ataque
		canShoot = false #Para controlar el firerate (Tiempo entre ostias melee)
		attackEnded = false #Para controlar que no empiece otra ostia hasta acabar la animacion de la primera
		timerFireRate.start(fireRate)
#Lanzar proyectil
func throw(point):
	direction = global_position.direction_to(point.global_position) #Nuestra direccion es hacia el jugador
	#direction = Vector2(point.position.x - global_position.x, point.position.y - global_position.y).normalized()
	if canShoot:
		#Instancia proyectil
		var weapon = Weapon.instance() #Instanciamos un nuevo arma
		get_parent().add_child(weapon) #La asignamos al player
		weapon.transform.origin = $AttackPosition.global_position #Indicamos posicion inicial que es la del AttackPosition
		weapon.sprite.frame = 1 #Asignamos el frame que queremos usar del sprite
		weapon.set_collision_mask_bit(3, true) #Busca solo al jugador
		weapon.setDirection(direction * fireSpeed) #Indicamos en que direccion debe ir
		#Iniciamos timer firerate para que no pueda volver a disparar hasta que acabe
		timerFireRate.start(fireRate)
		canShoot = false
		#Animacion Ataque que habra que crear y asignar en el animationtree
	animationTree.set("parameters/Attack/blend_position", direction) #Asignamos la animacion de Quieto
	animationState.travel("Attack") #Usamos la animacion Quieto
#Lanzar proyectiles en + (Pongo t porque es lo que mas se asemeja y no da errores)
func throwT():
	if canShoot:
		for n in 4:
			#Instancia proyectil
			var weapon = Fuck.instance() #Instanciamos un nuevo arma
			get_parent().add_child(weapon) #La asignamos al player
			weapon.transform.origin = $AttackPosition.global_position #Indicamos posicion inicial que es la del AttackPosition
			weapon.set_collision_mask_bit(3, true) #Busca solo al jugador
			if n == 0:
				weapon.setDirection(Vector2.RIGHT * fireSpeed) #Derecha
			elif n == 1:
				weapon.setDirection(Vector2.LEFT * fireSpeed) #Izquierda
			elif n == 2:
				weapon.setDirection(Vector2.UP * fireSpeed) #Arriba
			elif n == 3:
				weapon.setDirection(Vector2.DOWN * fireSpeed) #Abajo
		#Iniciamos timer firerate
		timerFireRate.start(fireRate)
		canShoot = false
		changeShoot = true
#Lanzar proyectiles en X
func throwX():
	if canShoot:
		for n in 4:
			#Instancia proyectil
			var weapon = Rap.instance() #Instanciamos un nuevo arma
			get_parent().add_child(weapon) #La asignamos al player
			weapon.transform.origin = $AttackPosition.global_position #Indicamos posicion inicial que es la del AttackPosition
			weapon.set_collision_mask_bit(3, true) #Busca solo al jugador
			if n == 0:
				weapon.setDirection(Vector2(1,1) * fireSpeed) #Derecha Abajo
			elif n == 1:
				weapon.setDirection(Vector2(-1,1) * fireSpeed) #Izquierda Abajo
			elif n == 2:
				weapon.setDirection(Vector2(-1,-1) * fireSpeed) #Izquierda Arriba
			elif n == 3:
				weapon.setDirection(Vector2(1,-1) * fireSpeed) #Derecha Arriba
		#Iniciamos timer firerate
		timerFireRate.start(fireRate)
		canShoot = false
		changeShoot = false
#Lanzar proyectiles en todas direcciones
func throwAll():
	if canShoot:
		for n in 8:
			#Instancia proyectil
			var weapon = Yeah.instance() #Instanciamos un nuevo arma
			get_parent().add_child(weapon) #La asignamos al player
			weapon.transform.origin = $AttackPosition.global_position #Indicamos posicion inicial que es la del AttackPosition
			weapon.set_collision_mask_bit(3, true) #Busca solo al jugador
			if n == 0:
				weapon.setDirection(Vector2.RIGHT * fireSpeed) #Derecha
			elif n == 1:
				weapon.setDirection(Vector2.LEFT * fireSpeed) #Izquierda
			elif n == 2:
				weapon.setDirection(Vector2.UP * fireSpeed) #Arriba
			elif n == 3:
				weapon.setDirection(Vector2.DOWN * fireSpeed) #Abajo
			elif n == 4:
				weapon.setDirection(Vector2(1,1) * fireSpeed) #Derecha Abajo
			elif n == 5:
				weapon.setDirection(Vector2(-1,1) * fireSpeed) #Izquierda Abajo
			elif n == 6:
				weapon.setDirection(Vector2(-1,-1) * fireSpeed) #Izquierda Arriba
			elif n == 7:
				weapon.setDirection(Vector2(1,-1) * fireSpeed) #Derecha Arriba
		#Iniciamos timer firerate
		timerFireRate.start(fireRate)
		canShoot = false
		changeShoot = false
#Invocar bichos
func throwInsects(point):
	direction = global_position.direction_to(point.global_position) #Nuestra direccion es hacia el jugador
	#direction = Vector2(point.position.x - global_position.x, point.position.y - global_position.y).normalized()
	if canShoot:
		#Instancia proyectil
		var weapon = Bicho.instance() #Instanciamos un nuevo arma
		get_parent().add_child(weapon) #La asignamos al player
		weapon.transform.origin = $AttackPosition.global_position #Indicamos posicion inicial que es la del AttackPosition
		weapon.set_collision_mask_bit(3, true) #Busca solo al jugador
		weapon.setDirection(direction * fireSpeed) #Indicamos en que direccion debe ir
		#Iniciamos timer firerate para que no pueda volver a disparar hasta que acabe
		timerFireRate.start(fireRate)
		canShoot = false
		#Animacion Ataque que habra que crear y asignar en el animationtree
	animationTree.set("parameters/Idle/blend_position", direction) #Asignamos la animacion de Quieto
	animationState.travel("Idle") #Usamos la animacion Quieto

#FUNCIONES PARA LAS SEÑALES DE TIMERS, AREAS...

#Funcion para el firerate
func _on_AttackRate_timeout():
	canShoot = true #Permitimos que vuelva a disparar cuando acaba el tiempo asignado
	attackEnded = true
	state = CHASE
#Funcion para detectar si algo entra en nuestro hurtbox
func _on_Hurtbox_area_entered(area):
	if Stats.take_damage(area.getDamage()) == 0: #Esta funcion devuelve la vida que tenemos osea que si es 0 toca eliminarse
		if self.name == "GamePlayer": #Que pasa cuando nuestra vida llega a 0, hacemos desaparecer y pausa pa que no pete
			self.visible = false
			get_tree().paused = true
		else:
			self.queue_free()
	area.queue_free() #Eliminamos el proyectil que nos ha impactado
	timerHitboxRate.start()

#func _on_HitboxRate_timeout():
#	createHitbox()

func _on_changeDirection_timeout():
	canChangeDirection = true
