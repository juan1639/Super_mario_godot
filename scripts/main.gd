extends Node2D

# REFERENCIAS A GOOMBA:
@onready var goomba_scene = preload("res://scenes/goomba.tscn")
@onready var goomba_spawns = $GoombaSpawns

# REFERENCIA A AREA2D (FallZone):
@onready var fallZones = $Map_1_1/FallZones

# REFERENCIAS A LA BANDERA Y GOAL-ZONE:
@onready var goalZone = $Map_1_1/GoalZone
@onready var flagPole = $Map_1_1/FlagPole

# REFERENCIA A MARIO/JUGADOR:
@onready var mario = $Jugador/CharacterBody2D

# FUNCION INICIALIZADORA:
func _ready():
	for spawn_point in goomba_spawns.get_children():
		#print("Instanciando Goomba en ", spawn_point.global_position)
		var goomba = goomba_scene.instantiate()
		goomba.global_position = spawn_point.global_position
		add_child(goomba)
	
	# Conectar señal de DeadZone
	for fallZone in fallZones.get_children():
		fallZone.connect("body_entered", Callable(mario, "_on_fall_zone_body_entered"))
	
	# Conectar señales de FlagPole y GoalZone:
	flagPole.connect("body_entered", Callable(mario, "_on_flag_pole_body_entered"))
	goalZone.connect("body_entered", Callable(mario, "_on_goal_zone_body_entered"))
