extends CharacterBody2D

# MOVIMIENTO HORIZONTAL:
const VEL_X = 30
var direccion = -1

# GRAVEDAD:
var acel_gravedad = 0.0

# REFERENCIAS:
@onready var sprite = $Sprite2D
@onready var animationPlayer = $AnimationPlayer

# FUNCION EJECUTANDOSE A 60 FPS:
func _physics_process(delta):
	aplicar_gravedad(delta)
	
	velocity.x = direccion * VEL_X
	
	move_and_slide()
	animationPlayer.play("Walk")
	
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
