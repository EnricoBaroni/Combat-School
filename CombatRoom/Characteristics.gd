tool
extends Node

class_name Characteristics

onready var stats = $Stats

export var starting_stats : Resource

func _ready():
	stats.initialize(starting_stats)
