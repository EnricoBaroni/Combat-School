extends Node

class_name Stats

signal health_changed(new_health)
signal health_depleted()

export var type : String
export var health : int
export var maxHealth : int setget set_maxHealth
export var damage : float
export var speed : float
export var fireRate : float
export var fireSpeed : float
export var maxRange : float

func set_maxHealth(value):
	maxHealth = max(0, value) #Hace que siempre se asigne un minimo de 0

func set_health(value):
	maxHealth = max(0, value)

func take_damage(hit):
	print_debug("TOMA OSTIA de " + str(hit))
	health -= hit
	health = max(0, health)
	emit_signal("health_changed", health)
	if health == 0:
		emit_signal("health_depleted")
	return health

func heal(amount):
	health += amount
	health = max(health, maxHealth)
	emit_signal("health_changed", amount)
