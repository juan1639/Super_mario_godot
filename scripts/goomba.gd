extends CharacterBody2D

# ACTIVO Y POSICION-INICIAL:
var activo = 0
var respawn_pos = 0.0
var aplastado = false

# MOVIMIENTO HORIZONTAL:
const VEL_X = 30
var direccion = -1

# GRAVEDAD:
var acel_gravedad = 0.0

# DISTANCIA A LA QUE SE ACTIVA GOOMBA (DISTANCIA MARIO-GOOMBA):
const DISTANCIA_ACTIVACION = 200

# REFERENCIAS:
@onready var sprite = $Sprite2D
@onready var animationPlayer = $AnimationPlayer

# FUNCION INIT:
func _ready():
	respawn_pos = global_position

# FUNCION EJECUTANDOSE A 60 FPS:
func _physics_process(delta):
	FuncionesAuxiliares.aplicar_gravedad(delta, self)
	
	if not aplastado:
		velocity.x = direccion * VEL_X * activo
	
	move_and_slide()
	update_animation()
	
	if is_on_wall():
		direccion *= -1
	
	if not GlobalValues.estado_juego["en_juego"]:
		activo = 0
	
	if activo != 1 and not aplastado:
		if abs(global_position.x - GlobalValues.marioRG.global_position.x) < DISTANCIA_ACTIVACION and GlobalValues.estado_juego["en_juego"]:
			activo = 1
	
	if GlobalValues.estado_juego["transicion_next_vida"]:
		global_position = respawn_pos

# UPDATE ANIMATION:
func update_animation():
	if not GlobalValues.estado_juego["en_juego"]:
		animationPlayer.play("RESET")
	elif aplastado:
		animationPlayer.play("Aplastado")
	elif activo != 0:
		animationPlayer.play("Walk")
	else:
		animationPlayer.play("RESET")
