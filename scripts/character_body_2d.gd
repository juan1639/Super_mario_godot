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
const RESPAWN_POSITION = Vector2(-1578, -32)

# REFERENCIAS:
@onready var sprite = $Sprite2D
@onready var animationPlayer = $AnimationPlayer
@onready var panelShowVidas = $CanvasLayer/Panel
@onready var timer = $Timer
@onready var timerColision = $TimerColision
@onready var timerTransicionVidaMenos = $TimerTransicionVidaMenos
@onready var sonido_salto = $SonidoSalto
@onready var sonido_coin = $SonidoCoin
@onready var sonido_lose_life = $SonidoLoseLife
@onready var sonido_aplastar = $SonidoAplastar
@onready var musica_level_up = $MusicaLevelUp

# FUNCION INICIALIZADORA:
func _ready():
	reset_estados_cambio_estado_a("en_juego")
	reset_position()
	sonido_salto.volume_db = -20.0
	timer.start(0.2)
	timerColision.start(0.1)
	timerTransicionVidaMenos.start(3.1)

# FUNCION EJECUTANDOSE A 60 FPS:
func _physics_process(delta):
	if GlobalValues.estado_juego["transicion_flag_pole"]:
		aplicar_gravedad_leve(delta)
		check_start_go_goal_zone()
		move_and_slide()
		update_animation()
		return
	
	if GlobalValues.estado_juego["transicion_goal_zone"] or GlobalValues.estado_juego["transicion_vida_menos"]:
		aplicar_gravedad(delta)
		move_and_slide()
		update_animation()
		aplicar_clamps()
		
		if timerTransicionVidaMenos.time_left == 0.0 and GlobalValues.estado_juego["transicion_vida_menos"]:
			timerTransicionVidaMenos.start(2.1)
			reset_estados_cambio_estado_a("transicion_next_vida")
			reset_position()
			panelShowVidas.visible = true
		return
	
	if GlobalValues.estado_juego["transicion_fireworks"]:
		return
	
	if GlobalValues.estado_juego["transicion_next_vida"]:
		aplicar_gravedad(delta)
		move_and_slide()
		update_animation()
		
		if timerTransicionVidaMenos.time_left == 0.0:
			reset_estados_cambio_estado_a("en_juego")
			panelShowVidas.visible = false
			GlobalValues.musicaFondo.play()
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
	MarioFuncionesAux.identificar_tile(global_position, salto, timer, sonido_coin)

# APLICAR GRAVEDAD:
func aplicar_gravedad(delta):
	if not is_on_floor():
		acel_gravedad += GlobalValues.GRAVEDAD * delta
		velocity.y += acel_gravedad
	else:
		acel_gravedad = 0
		if not GlobalValues.estado_juego["transicion_vida_menos"]:
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
	velocity.y = clamp(velocity.y, -700, 700)
	
	# CHECK WORLD-LIMITS-HOR:
	global_position.x = clamp(global_position.x, GlobalValues.LIMITE_IZ + 30, GlobalValues.LIMITE_DE - 20)

# GESTIONAR-ANIMACIONES-JUGADOR:
func update_animation():
	if GlobalValues.estado_juego["transicion_flag_pole"]:
		animationPlayer.play("FlagPole")
		return
	
	if GlobalValues.estado_juego["transicion_vida_menos"]:
		animationPlayer.play("LoseLife")
		return
	
	if not is_on_floor():
		animationPlayer.play("Jump")
	elif velocity.x != 0:
		animationPlayer.play("Walk")
	else:
		animationPlayer.play("Idle")

# SEÑALES:
func _on_fall_zone_body_entered(body):
	if body == self and GlobalValues.estado_juego["en_juego"]:
		actions_lose_life()

# BAJADA DE BANDERA:
func _on_flag_pole_body_entered(body):
	if body == self:
		velocity = Vector2.ZERO
		salto["presionado"] = false
		reset_estados_cambio_estado_a("transicion_flag_pole")
		GlobalValues.musicaFondo.stop()
		musica_level_up.play()
		var tween = create_tween()
		var bottom_pos = GlobalValues.flag_sprite.global_position + Vector2(0, 128) # 128 = posY bandera suelo
		tween.tween_property(GlobalValues.flag_sprite, "global_position", bottom_pos, 2.1)

# DESAPARECER POR LA PUERTA DEL CASITLLO:
func _on_goal_zone_body_entered(body):
	if body == self:
		print("goal")
		velocity = Vector2.ZERO
		visible = false
		reset_estados_cambio_estado_a("transicion_fireworks")

# COLISION VS GOOMBA (LOSE LIFE):
func _on_goomba_body_entered(body, goomba):
	if timerColision.time_left > 0:
		return
	
	if body == self and GlobalValues.estado_juego["en_juego"]:
		velocity = Vector2(0, POTENCIA_SALTO * 2)
		goomba.get_child(0).activo = 0
		actions_lose_life()

# COLISION VS GOOMBA (APLASTAR-GOOMBA):
func _on_aplastar_goomba_body_entered(body, goomba):
	if body == self and GlobalValues.estado_juego["en_juego"]:
		timerColision.start(0.1)
		goomba.queue_free()
		velocity = Vector2(velocity.x, POTENCIA_SALTO * 2.8)
		sonido_aplastar.play()

# ACCIONES AL PERDER VIDA:
func actions_lose_life():
	reset_estados_cambio_estado_a("transicion_vida_menos")
	GlobalValues.marcadores["lives"] -= 1
	var newText = "x " + str(GlobalValues.marcadores["lives"])
	panelShowVidas.get_child(1).text = newText
	
	timerTransicionVidaMenos.start(3.1)
	
	GlobalValues.musicaFondo.stop()
	sonido_lose_life.play()

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
	sprite.flip_h = false

# RESETEAR-ESTADOS Y CAMBIAR UN ESTADO:
func reset_estados_cambio_estado_a(estado):
	for keyName in GlobalValues.estado_juego.keys():
		GlobalValues.estado_juego[keyName] = false
	
	GlobalValues.estado_juego[estado] = true

# CHECK WORLD-BOTTOM-LIMIT:
func check_world_bottom_limit():
	if global_position.y > BOTTOM_LIMIT:
		reset_position()
