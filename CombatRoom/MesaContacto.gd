extends Area2D

onready var Frank = preload("res://Frank.tscn") #Instancia de enemigo concreto
onready var Maton = preload("res://Maton.tscn") #Instancia de enemigo concreto
onready var StaticPaca = load("res://staticPaca.tscn") #Instancia de enemigo concreto

func _on_MesaContacto_body_entered(body):
	var frank = Frank.instance()
	frank.transform.origin = Vector2(15, 80)
	get_tree().root.get_child(0).add_child(frank)

#var next_level_resource = load("res://path/to/scene.tscn)
#var next_level = next_level_resource.instance()
#root.add_child(next_level)
