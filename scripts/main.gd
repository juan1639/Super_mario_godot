extends Node2D

@onready var goomba_scene = preload("res://scenes/goomba.tscn")
@onready var goomba_spawns = $GoombaSpawns

func _ready():
	print("Spawns-Goombas encontrados: ", goomba_spawns.get_child_count())
	
	for spawn_point in goomba_spawns.get_children():
		print("Instanciando Goomba en ", spawn_point.global_position)
		var goomba = goomba_scene.instantiate()
		goomba.global_position = spawn_point.global_position
		add_child(goomba)
