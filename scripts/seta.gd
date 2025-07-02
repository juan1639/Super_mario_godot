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
		aplicar_gravedad(delta)
		velocity.x = direccion * VEL_X
	
	move_and_slide()
	check_bottom_limit_y_desactivar()
	
	if is_on_wall():
		direccion *= -1

# APLICAR GRAVEDAD:
func aplicar_gravedad(delta):
	if not is_on_floor():
		acel_gravedad += GlobalValues.GRAVEDAD * delta
		velocity.y += acel_gravedad
	else:
		acel_gravedad = 0
		velocity.y = 0

# CHECK BOTTOM-LIMIT -> (activa=false):
func check_bottom_limit_y_desactivar():
	if global_position.y > GlobalValues.BOTTOM_LIMIT:
		global_position = Vector2(-1500, -500)
		velocity = Vector2(0, 0)
		direccion = 1
		activa = false
