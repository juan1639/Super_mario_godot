extends CharacterBody2D

# ACTIVA bool:
var activa = false

# MOVIMIENTO HORIZONTAL:
const VEL_X = 60
var direccion = 1

# GRAVEDAD:
var acel_gravedad = 0.0

# REFERENCIAS:
@onready var sprite = $Sprite2D
@onready var sonido_seta = $SonidoSeta

# FUNCION EJECUTANDOSE A 60 FPS:
func _physics_process(delta):
	if activa:
		FuncionesAuxiliares.aplicar_gravedad(delta, self)
		velocity.x = direccion * VEL_X
	
	move_and_slide()
	check_bottom_limit_y_desactivar()
	
	if is_on_wall():
		direccion *= -1

# CHECK BOTTOM-LIMIT -> (activa=false):
func check_bottom_limit_y_desactivar():
	if global_position.y > GlobalValues.BOTTOM_LIMIT:
		global_position = Vector2(-1500, -500)
		velocity = Vector2(0, 0)
		direccion = 1
		activa = false
