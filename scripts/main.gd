extends Node2D

# REFERENCIAS A GOOMBA:
@onready var goomba_scene = preload("res://scenes/goomba.tscn")
@onready var goomba_spawns = $GoombaSpawns

@onready var bloquesSprites_scene = preload("res://scenes/bloques_sprites.tscn")

# REFERENCIA A AREA2D (FallZone):
@onready var fallZones = $Map_1_1/FallZones

# REFERENCIAS A LA BANDERA Y GOAL-ZONE:
@onready var goalZone = $Map_1_1/GoalZone
@onready var flagPole = $Map_1_1/FlagPole

# REFERENCIA A MARIO/JUGADOR:
@onready var mario = $Jugador/CharacterBody2D

# FUNCION INICIALIZADORA:
func _ready():
	# REFERENCIAS A LA BANDERA Y AL TILEMAP:
	GlobalValues.flag_sprite = $Map_1_1/FlagSprite
	GlobalValues.ref_tilemap = $Map_1_1/TileMapLayer
	
	# INSTANCIA DE UN BLOQUE-SPRITE (Posteriormente solo hace falta cambiar posicion):
	GlobalValues.bloqueSprite = bloquesSprites_scene.instantiate()
	GlobalValues.bloqueSprite.global_position = Vector2(-1300, -300)
	add_child(GlobalValues.bloqueSprite)
	
	# INSTANCIAR GOOMBAS:
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
