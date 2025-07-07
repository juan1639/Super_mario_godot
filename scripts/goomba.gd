extends CharacterBody2D

var tipo_goomba = {
	"normal": true,
	"paracaidas": false
}

# ACTIVO Y POSICION-INICIAL:
var activo = 0
var respawn_pos = 0.0
var respawneado_bool = false
var aplastado = false
var is_dying_not_aplastado = false

# MOVIMIENTO HORIZONTAL:
const VEL_X = 30
var direccion = -1

var input_salto = false

# GRAVEDAD:
var acel_gravedad = 0.0

# DISTANCIA A LA QUE SE ACTIVA GOOMBA (DISTANCIA MARIO-GOOMBA):
const DISTANCIA_ACTIVACION = 200

# REFERENCIAS:
@onready var sprite = $Sprite2D
@onready var animationPlayer = $AnimationPlayer
@onready var timerGoombaAplastado = $TimerGoombaAplastado

# FUNCION INIT:
func _ready():
	respawn_pos = global_position
	activo = 0
	aplastado = false
	timerGoombaAplastado.connect("timeout", _on_timer_timeout_aplastado)

# FUNCION EJECUTANDOSE A 60 FPS:
func _physics_process(delta):
	FuncionesAuxiliares.aplicar_gravedad(delta, self)
	
	if tipo_goomba["normal"]:
		if not aplastado:
			velocity.x = direccion * VEL_X * activo
	elif tipo_goomba["paracaidas"]:
			velocity.x = 0
	
	if input_salto and tipo_goomba["normal"]:
		velocity.y = -250
		input_salto = false
	
	move_and_slide()
	update_animation()
	respawn_goomba_transicion_next_vida()
	
	if is_on_wall():
		direccion *= -1
	
	if is_on_floor() and tipo_goomba["paracaidas"]:
		reset_tipo_goomba_cambio_a("normal")
	
	if not GlobalValues.estado_juego["en_juego"]:
		activo = 0
	
	if activo != 1 and not aplastado and tipo_goomba["normal"]:
		if abs(global_position.x - GlobalValues.marioRG.global_position.x) < DISTANCIA_ACTIVACION and GlobalValues.estado_juego["en_juego"]:
			activo = 1

# SEÑAL GOOMBA-APLASTADO:
func _on_timer_timeout_aplastado():
	queue_free()

# RESPAWNEAR A GOOMBA TRAS IMPACTO CON MARIO (vida menos):
func respawn_goomba_transicion_next_vida():
	if GlobalValues.estado_juego["transicion_next_vida"] and not respawneado_bool:
		respawneado_bool = true
		global_position = respawn_pos
	
	if GlobalValues.estado_juego["en_juego"] and respawneado_bool:
		respawneado_bool = false

# UPDATE ANIMATION:
func update_animation():
	# ANIMACIONES GOOMBA[PARACIDAS]:
	if tipo_goomba["paracaidas"]:
		update_animation_paracaidas()
		return
	
	# ANIMACIONES GOOMBA[NORMAL]:
	if not GlobalValues.estado_juego["en_juego"]:
		animationPlayer.play("RESET")
	elif is_dying_not_aplastado:
		animationPlayer.play("IsDyingNotAplastado")
		if is_on_floor():
			input_salto = true
	elif aplastado:
		animationPlayer.play("Aplastado")
	elif activo != 0:
		animationPlayer.play("Walk")
	else:
		animationPlayer.play("RESET")

# ANIMACIONES GOOMBA[PARACIDAS]:
func update_animation_paracaidas():
	animationPlayer.play("RESET")

# RESET TIPO-GOOMBA Y ESTABLECER EL NUEVO:
func reset_tipo_goomba_cambio_a(new_tipo):
	for keyName in tipo_goomba.keys():
		tipo_goomba[keyName] = false
	
	tipo_goomba[new_tipo] = true
