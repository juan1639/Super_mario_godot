extends CharacterBody2D

# VELOCIDAD HORIZONAL
const VEL_MAX = 250.0
const ACELERACION = 200.0
const DECELERACION = 250.0

# SALTO Y GRAVEDAD:
const POTENCIA_SALTO = -250.0
const SALTO_EXTRA = -280.0
const DURACION_SALTO_EXTRA = 0.2

var acel_gravedad = 0.0
var salto_presionado = false
var tiempo_salto = 0.0

# WORLD LIMITS:
const BOTTOM_LIMIT = 50

# RESPAWN-POSITION:
const RESPAWN_POSITION = Vector2(-1578, -100)

# REFERENCIAS:
@onready var sprite = $Sprite2D
@onready var animationPlayer = $AnimationPlayer

# FUNCION INICIALIZADORA:
func _ready():
	_reset_estados_cambio_estado_a("en_juego")
	_reset_position()

# FUNCION EJECUTANDOSE A 60 FPS:
func _physics_process(delta):
	if GlobalValues.estado_juego["transicion_flag_pole"]:
		_aplicar_gravedad_leve(delta)
		check_start_go_goal_zone()
		move_and_slide()
		_update_animation()
		return
	
	if GlobalValues.estado_juego["transicion_goal_zone"]:
		_aplicar_gravedad(delta)
		move_and_slide()
		_update_animation()
		return
	
	if GlobalValues.estado_juego["transicion_fireworks"]:
		return
	
	if not GlobalValues.estado_juego["en_juego"]:
		_aplicar_gravedad(delta)
		move_and_slide()
		return
	
	_aplicar_gravedad(delta)
	_movimiento_horizontal(delta)
	_salto(delta)
	_aplicar_clamps()
	#_check_world_bottom_limit()
	
	move_and_slide()
	_update_animation()

# APLICAR GRAVEDAD:
func _aplicar_gravedad(delta):
	if not is_on_floor():
		acel_gravedad += GlobalValues.GRAVEDAD * delta
		velocity.y += acel_gravedad
	else:
		acel_gravedad = 0
		velocity.y = 0

# APLICAR GRAVEDAD LEVE:
func _aplicar_gravedad_leve(delta):
	if not is_on_floor():
		velocity.y += GlobalValues.GRAVEDAD * delta
	else:
		acel_gravedad = 0
		velocity.y = 0

# MOVIMIENTO HORIZONTAL:
func _movimiento_horizontal(delta):
	var input_direccion = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if input_direccion != 0:
		velocity.x = move_toward(velocity.x, input_direccion * VEL_MAX, ACELERACION * delta)
		sprite.flip_h = input_direccion < 0
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERACION * delta)

# SALTO:
func _salto(delta):
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

func _aplicar_clamps():
	# CLAMP Velocity.y:
	velocity.y = clamp(velocity.y, -1000, 1000)
	
	# CHECK WORLD-LIMITS-HOR:
	global_position.x = clamp(global_position.x, GlobalValues.LIMITE_IZ + 30, GlobalValues.LIMITE_DE - 20)

# GESTIONAR-ANIMACIONES-JUGADOR:
func _update_animation():
	if GlobalValues.estado_juego["transicion_flag_pole"]:
		animationPlayer.play("FlagPole")
		return
	
	if not is_on_floor():
		animationPlayer.play("Jump")
	elif velocity.x != 0:
		animationPlayer.play("Walk")
	else:
		animationPlayer.play("Idle")

# SEÑALES:
func _on_fall_zone_body_entered(body):
	if body == self:
		_reset_position()

func _on_flag_pole_body_entered(body):
	if body == self:
		print("bandera")
		velocity = Vector2.ZERO
		_reset_estados_cambio_estado_a("transicion_flag_pole")
		var tween = create_tween()
		var new_pos = GlobalValues.flag_sprite.global_position + Vector2(0, 128) # o ajusta según altura
		tween.tween_property(GlobalValues.flag_sprite, "global_position", new_pos, 1.0)

func _on_goal_zone_body_entered(body):
	if body == self:
		print("goal")
		velocity = Vector2.ZERO
		visible = false
		_reset_estados_cambio_estado_a("transicion_fireworks")

# CHECK START-GO-GOAL-ZONE:
func check_start_go_goal_zone():
	if is_on_floor():
		velocity = Vector2(abs(VEL_MAX / 9), 0)
		_reset_estados_cambio_estado_a("transicion_goal_zone")

#func check_start_go_goal_zone():
	#var tween = create_tween()
	#tween.tween_property(self, "global_position", Vector2(-1500, -80), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# RESETEAR-RESPAWNEAR JUGADOR A SU POSICION INICIAL:
func _reset_position():
	global_position = RESPAWN_POSITION
	velocity = Vector2.ZERO
	
# RESETEAR-ESTADOS Y CAMBIAR UN ESTADO:
func _reset_estados_cambio_estado_a(estado):
	for keyName in GlobalValues.estado_juego.keys():
		GlobalValues.estado_juego[keyName] = false
	
	GlobalValues.estado_juego[estado] = true

# CHECK WORLD-BOTTOM-LIMIT:
func _check_world_bottom_limit():
	if global_position.y > BOTTOM_LIMIT:
		_reset_position()
