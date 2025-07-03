extends CharacterBody2D

# ACTIVO Y POSICION-INICIAL:
var activo = 1
var respawn_pos = 0.0

# MOVIMIENTO HORIZONTAL:
const VEL_X = 30
var direccion = -1

# GRAVEDAD:
var acel_gravedad = 0.0

# REFERENCIAS:
@onready var sprite = $Sprite2D
@onready var animationPlayer = $AnimationPlayer

# FUNCION INIT:
func _ready():
	respawn_pos = global_position

# FUNCION EJECUTANDOSE A 60 FPS:
func _physics_process(delta):
	FuncionesAuxiliares.aplicar_gravedad(delta, self)
	velocity.x = direccion * VEL_X * activo
	move_and_slide()
	
	if is_on_wall():
		direccion *= -1
	
	if GlobalValues.estado_juego["en_juego"]:
		animationPlayer.play("Walk")
		activo = 1
	else:
		animationPlayer.play("RESET")
		activo = 0
	
	if GlobalValues.estado_juego["transicion_next_vida"]:
		global_position = respawn_pos
