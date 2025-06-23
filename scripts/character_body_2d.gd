extends CharacterBody2D

# VELOCIDAD HORIZONAL
const VEL_MAX = 250.0
const ACELERACION = 200.0
const DECELERACION = 250.0

# SALTO Y GRAVEDAD
const GRAVEDAD = 90.0
const POTENCIA_SALTO = -250.0
const SALTO_EXTRA = -280.0
const DURACION_SALTO_EXTRA = 0.2

var acel_gravedad = 0.0
var salto_presionado = false
var tiempo_salto = 0.0

const LIMITE_IZ = -1700
const LIMITE_DE = 1700

@onready var sprite = $Sprite2D
@onready var animationPlayer = $AnimationPlayer

func _physics_process(delta):
	# APLICAR GRAVEDAD:
	if not is_on_floor():
		acel_gravedad += GRAVEDAD * delta
		velocity.y += acel_gravedad
	else:
		acel_gravedad = 0
		velocity.y = 0
	
	# MOVIMIENTO HORIZONTAL:
	var input_direccion = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if input_direccion != 0:
		velocity.x = move_toward(velocity.x, input_direccion * VEL_MAX, ACELERACION * delta)
		sprite.flip_h = input_direccion < 0
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERACION * delta)
	
	# SALTO:
	if is_on_floor() and Input.get_action_strength("ui_accept"):
		salto_presionado = true
		tiempo_salto = 0.0
		
		# SALTO BASE + impulso adicional
		var impulso_extra = abs(velocity.x) * 0.45
		velocity.y = POTENCIA_SALTO - impulso_extra
	
	if salto_presionado:
		tiempo_salto += delta
		
		if Input.get_action_strength("ui_accept") and tiempo_salto < DURACION_SALTO_EXTRA:
			velocity.y += SALTO_EXTRA * delta
		else:
			salto_presionado = false
	
	# CHECK LIMITES WORLD:
	global_position.x = clamp(global_position.x, LIMITE_IZ + 30, LIMITE_DE - 20)
	
	# ANIMACIONES:
	_update_animation()
	
	move_and_slide()

func _update_animation():
	if not is_on_floor():
		animationPlayer.play("Jump")
	elif velocity.x != 0:
		animationPlayer.play("Walk")
	else:
		animationPlayer.play("Idle")
