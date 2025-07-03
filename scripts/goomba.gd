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
	aplicar_gravedad(delta)
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

# APLICAR GRAVEDAD:
func aplicar_gravedad(delta):
	if not is_on_floor():
		acel_gravedad += GlobalValues.GRAVEDAD * delta
		velocity.y += acel_gravedad
	else:
		acel_gravedad = 0
		velocity.y = 0
