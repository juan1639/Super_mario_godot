extends Node2D

# REFERENCIAS A SPRITES (GOOMBA, etc.):
@onready var goomba_scene = preload("res://scenes/goomba.tscn")
@onready var goomba_spawns = $GoombaSpawns

@onready var bloquesSprites_scene = preload("res://scenes/bloques_sprites.tscn")
@onready var moneda_scene = preload("res://scenes/moneda.tscn")
@onready var seta_scene = preload("res://scenes/seta.tscn")
@onready var estrella_scene = preload("res://scenes/estrella.tscn")
@onready var gameover_scene = preload("res://scenes/gameover.tscn")
@onready var button_next_level_scene = preload("res://scenes/continuar_next_level.tscn")

# REFERENCIA A AREA2D (FallZone):
@onready var fallZones = $Map_1_1/FallZones

# REFERENCIAS A LA BANDERA Y GOAL-ZONE:
@onready var goalZone = $Map_1_1/GoalZone
@onready var flagPole = $Map_1_1/FlagPole

# REFERENCIA A LAS ZONAS INSTANCIA-GOOMBAS-PARACAIDAS:
@onready var zoneInstanciaParacaidas = $Map_1_1/ParacaidasZones

# REFERENCIA A MARIO/JUGADOR:
@onready var mario = $Jugador/CharacterBody2D

# FUNCION INICIALIZADORA:
func _ready():
	# CONEXION A SEÑALES GAMEOVER y BUTTON-NEXT-LEVEL:
	FuncionesAuxiliares.connect("gameover_instance", Callable(self, "_on_gameover_instance"))
	FuncionesAuxiliares.connect("next_level_instance", Callable(self, "_on_next_level_instance"))
	
	# REFERENCIA ESTE NODO PRINCIPAL (MAIN):
	GlobalValues.main_node = self

	# REFERENCIAR A MARIO EN GLOBAL-VALUES:
	GlobalValues.marioRG = mario
	
	# REFERENCIAS A LA BANDERA Y AL TILEMAP:
	GlobalValues.flag_sprite = $Map_1_1/FlagSprite
	GlobalValues.ref_tilemap = $Map_1_1/TileMapLayer
	
	# INSTANCIA DE UNA MONEDA-SPRITE (Posteriormente solo hace falta cambiar posicion):
	GlobalValues.monedaSprite = moneda_scene.instantiate()
	GlobalValues.monedaSprite.global_position = Vector2(-1400, -500)
	add_child(GlobalValues.monedaSprite)
	
	# INSTANCIA DE UN BLOQUE-SPRITE (Posteriormente solo hace falta cambiar posicion):
	GlobalValues.bloqueSprite = bloquesSprites_scene.instantiate()
	GlobalValues.bloqueSprite.global_position = Vector2(-1300, -500)
	add_child(GlobalValues.bloqueSprite)
	
	# INSTANCIA DE UNA SETA (Posteriormente solo hace falta cambiar posicion):
	GlobalValues.setaSprite = seta_scene.instantiate()
	GlobalValues.setaSprite.global_position = Vector2(-1500, -500)
	add_child(GlobalValues.setaSprite)
	
	# INSTANCIA DE UNA ESTRELLA (Posteriormente solo hace falta cambiar posicion):
	GlobalValues.estrellaSprite = estrella_scene.instantiate()
	GlobalValues.estrellaSprite.global_position = Vector2(-1550, -500)
	GlobalValues.estrellaSprite.get_child(3).connect("body_entered", Callable(mario, "_on_estrella_body_entered"))
	add_child(GlobalValues.estrellaSprite)
	
	# INSTANCIAR GOOMBAS:
	for spawn_point in goomba_spawns.get_children():
		#print("Instanciando Goomba en ", spawn_point.global_position)
		var goomba = goomba_scene.instantiate()
		goomba.global_position = spawn_point.global_position
		goomba.get_child(0).get_child(3).connect("body_entered", Callable(mario, "_on_goomba_body_entered").bind(goomba))
		goomba.get_child(0).get_child(4).connect("body_entered", Callable(mario, "_on_aplastar_goomba_body_entered").bind(goomba))
		add_child(goomba)
	
	# CONECTAR SEÑAL de fallZone:
	for fallZone in fallZones.get_children():
		fallZone.connect("body_entered", Callable(mario, "_on_fall_zone_body_entered"))
	
	# CONECTAR SEÑALES de FlagPole y GoalZone:
	flagPole.connect("body_entered", Callable(mario, "_on_flag_pole_body_entered"))
	goalZone.connect("body_entered", Callable(mario, "_on_goal_zone_body_entered"))
	
	# CONECTAR SEÑALES de zoneInstanciaParacaidas:
	for zone in zoneInstanciaParacaidas.get_children():
		zone.connect("body_entered", Callable(mario, "_on_instancia_paracaidas_body_entered").bind(zone))
	
	# START PLAY MUSIC:
	GlobalValues.musicaFondo = $MusicaFondo
	GlobalValues.musicaFondo.play()

# CALL-DEFERRED INSTANCIAR-GOOMBA-PARACAIDAS:
func instanciar_goomba_paracaidas():
	var goomba = goomba_scene.instantiate()
	goomba.global_position = Vector2(mario.global_position.x + 120, -200)
	goomba.get_child(0).reset_tipo_goomba_cambio_a("paracaidas")
	goomba.get_child(0).get_child(3).connect("body_entered", Callable(mario, "_on_goomba_body_entered").bind(goomba))
	goomba.get_child(0).get_child(4).connect("body_entered", Callable(mario, "_on_aplastar_goomba_body_entered").bind(goomba))
	add_child(goomba)

# INSTANCIAR GAME OVER:
func _on_gameover_instance():
	var gameover = gameover_scene.instantiate()
	add_child(gameover)

# INSTANCIAR BUTTON-NEXT-LEVVEL:
func _on_next_level_instance():
	var buttonNextLevel = button_next_level_scene.instantiate()
	add_child(buttonNextLevel)
