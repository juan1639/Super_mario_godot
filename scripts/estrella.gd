extends CharacterBody2D

var activa = false

# CONSTANTES
const VELOCIDAD_X = 80.0
const FUERZA_SALTO = -200.0
const GRAVEDAD = 500.0

# VARIABLES
var direccion = 1
var velocidad_y = 0.0

# REFERENCIAS:
@onready var animationPlayer = $AnimationPlayer

# FUNCION INIT:
func _ready():
	velocidad_y = FUERZA_SALTO

# FUNCION UPDATE:
func _physics_process(delta):
	if activa:
		# Aplicar gravedad
		velocidad_y += GRAVEDAD * delta

		# Movimiento horizontal constante
		velocity.x = direccion * VELOCIDAD_X
		velocity.y = velocidad_y
	
	move_and_slide()
	animationPlayer.play("Intermitente")
	
	if is_on_floor():
		velocidad_y = FUERZA_SALTO
	
	if is_on_wall():
		direccion *= -1
	
	check_bottom_limit_y_desactivar()
	
func check_bottom_limit_y_desactivar():
	if global_position.y > GlobalValues.BOTTOM_LIMIT:
		global_position = Vector2(-1550, -500)
		velocity = Vector2(0, 0)
		direccion = 1
		activa = false
