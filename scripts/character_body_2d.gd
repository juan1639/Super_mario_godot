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

var salto = {
	"presionado": false,
	"tiempo": 0.0
}

# WORLD LIMITS:
const BOTTOM_LIMIT = 999 # BOTTOM-LIMIT (si es necesario)

# RESPAWN-POSITION:
const RESPAWN_POSITION = Vector2(-1578, -100)

# REFERENCIAS:
@onready var sprite = $Sprite2D
@onready var animationPlayer = $AnimationPlayer
@onready var sonido_salto = $SonidoSalto
@onready var sonido_coin = $SonidoCoin

# FUNCION INICIALIZADORA:
func _ready():
	reset_estados_cambio_estado_a("en_juego")
	reset_position()
	sonido_salto.volume_db = -20.0

# FUNCION EJECUTANDOSE A 60 FPS:
func _physics_process(delta):
	if GlobalValues.estado_juego["transicion_flag_pole"]:
		aplicar_gravedad_leve(delta)
		check_start_go_goal_zone()
		move_and_slide()
		update_animation()
		return
	
	if GlobalValues.estado_juego["transicion_goal_zone"]:
		aplicar_gravedad(delta)
		move_and_slide()
		update_animation()
		return
	
	if GlobalValues.estado_juego["transicion_fireworks"]:
		return
	
	if not GlobalValues.estado_juego["en_juego"]:
		aplicar_gravedad(delta)
		move_and_slide()
		return
	
	aplicar_gravedad(delta)
	movimiento_horizontal(delta)
	salto_jugador(delta)
	aplicar_clamps()
	check_world_bottom_limit()
	
	move_and_slide()
	update_animation()
	MarioFuncionesAux.identificar_tile(global_position, salto, sonido_coin)

# APLICAR GRAVEDAD:
func aplicar_gravedad(delta):
	if not is_on_floor():
		acel_gravedad += GlobalValues.GRAVEDAD * delta
		velocity.y += acel_gravedad
	else:
		acel_gravedad = 0
		velocity.y = 0

# APLICAR GRAVEDAD LEVE:
func aplicar_gravedad_leve(delta):
	if not is_on_floor():
		velocity.y += GlobalValues.GRAVEDAD * delta
	else:
		acel_gravedad = 0
		velocity.y = 0

# MOVIMIENTO HORIZONTAL:
func movimiento_horizontal(delta):
	var input_direccion = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if input_direccion != 0:
		velocity.x = move_toward(velocity.x, input_direccion * VEL_MAX, ACELERACION * delta)
		sprite.flip_h = input_direccion < 0
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERACION * delta)

# SALTO:
func salto_jugador(delta):
	if is_on_floor() and Input.get_action_strength("ui_accept"):
		salto["presionado"] = true
		salto["tiempo"] = 0.0
		sonido_salto.play()
		
		# SALTO BASE + impulso adicional
		var impulso_extra = abs(velocity.x) * 0.45
		velocity.y = POTENCIA_SALTO - impulso_extra
	
	if salto["presionado"]:
		salto["tiempo"] += delta
		
		if Input.get_action_strength("ui_accept") and salto["tiempo"] < DURACION_SALTO_EXTRA and not is_on_ceiling():
			velocity.y += SALTO_EXTRA * delta
		else:
			salto["presionado"] = false

# WORLD CLAMPS:
func aplicar_clamps():
	# CLAMP Velocity.y:
	velocity.y = clamp(velocity.y, -1000, 1000)
	
	# CHECK WORLD-LIMITS-HOR:
	global_position.x = clamp(global_position.x, GlobalValues.LIMITE_IZ + 30, GlobalValues.LIMITE_DE - 20)

# GESTIONAR-ANIMACIONES-JUGADOR:
func update_animation():
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
		reset_position()

func _on_flag_pole_body_entered(body):
	if body == self:
		print("bandera")
		velocity = Vector2.ZERO
		salto["presionado"] = false
		reset_estados_cambio_estado_a("transicion_flag_pole")
		var tween = create_tween()
		var bottom_pos = GlobalValues.flag_sprite.global_position + Vector2(0, 128) # 128 = posY bandera suelo
		tween.tween_property(GlobalValues.flag_sprite, "global_position", bottom_pos, 2.1)

func _on_goal_zone_body_entered(body):
	if body == self:
		print("goal")
		velocity = Vector2.ZERO
		visible = false
		reset_estados_cambio_estado_a("transicion_fireworks")

# CHECK START-GO-GOAL-ZONE:
func check_start_go_goal_zone():
	if is_on_floor():
		velocity = Vector2(abs(VEL_MAX / 9), 0)
		reset_estados_cambio_estado_a("transicion_goal_zone")

#func check_start_go_goal_zone():
	#var tween = create_tween()
	#tween.tween_property(self, "global_position", Vector2(-1500, -80), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# RESETEAR-RESPAWNEAR JUGADOR A SU POSICION INICIAL:
func reset_position():
	global_position = RESPAWN_POSITION
	velocity = Vector2.ZERO
	
# RESETEAR-ESTADOS Y CAMBIAR UN ESTADO:
func reset_estados_cambio_estado_a(estado):
	for keyName in GlobalValues.estado_juego.keys():
		GlobalValues.estado_juego[keyName] = false
	
	GlobalValues.estado_juego[estado] = true

# CHECK WORLD-BOTTOM-LIMIT:
func check_world_bottom_limit():
	if global_position.y > BOTTOM_LIMIT:
		reset_position()
