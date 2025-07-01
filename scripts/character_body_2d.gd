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
const BOTTOM_LIMIT = 999 # BOTTOM-LIMIT (si es necesario)

# RESPAWN-POSITION:
const RESPAWN_POSITION = Vector2(-1578, -100)

# REFERENCIAS:
@onready var sprite = $Sprite2D
@onready var animationPlayer = $AnimationPlayer

# FUNCION INICIALIZADORA:
func _ready():
	reset_estados_cambio_estado_a("en_juego")
	reset_position()

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
	salto(delta)
	aplicar_clamps()
	check_world_bottom_limit()
	
	move_and_slide()
	update_animation()
	identificar_tile()

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
func salto(delta):
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

# IDENTIFICAR TILE (EN LA POSICION DE MARIO):
func identificar_tile():
	var tilemap = GlobalValues.ref_tilemap
	
	# OBTENEMOS EL TILE EN LA POSICION DE MARIO (y restamos (0,-1) encima de mario)
	var tile_pos = tilemap.local_to_map(global_position)
	tile_pos += Vector2i(0, -1)

	# Asegurar de que haya un tile ahí
	var source_id = tilemap.get_cell_source_id(tile_pos)
	
	if source_id == -1:
		return
	
	var atlas_coords = tilemap.get_cell_atlas_coords(tile_pos)
	print("Coords del tile golpeado:", atlas_coords)
	
	# TILE-INTERROGACION = (2,1) | TILE-BLOQUE-LADRILLO = (3,1):
	const INTERROGACION = Vector2i(2, 1)
	const BLOQUE_LADRILLO = Vector2i(3, 1)
	
	if atlas_coords == INTERROGACION:
		impacto_bloques_tween(tilemap, tile_pos, source_id, INTERROGACION)
	elif atlas_coords == BLOQUE_LADRILLO:
		impacto_bloques_tween(tilemap, tile_pos, source_id, BLOQUE_LADRILLO)

# VOLVER A COLOCAR EL TILE (tras el tween):
func restore_block(tilemap: TileMapLayer, tile_pos: Vector2i, source_id: int, TIPO_BLOQUE: Vector2i):
	tilemap.set_cell(tile_pos, source_id, TIPO_BLOQUE)

# TWEEN TILES:
func impacto_bloques_tween(tilemap, tile_pos, source_id, TIPO_BLOQUE):
	#print("¡Tile detectado!")
	# Reemplazar tile y setear salto_presionado a false:
	tilemap.set_cell(tile_pos, source_id, Vector2i(0, 0))
	salto_presionado = false
	velocity.y = 0
	
	# PONER UN BLOQUE-SPRITE (IDENTICO AL TILE):
	var pos_mario_cabeza = global_position + Vector2(0, -16)
	var bloque_pos = tilemap.local_to_map(tilemap.to_local(pos_mario_cabeza))
	var bloque_pos2 = tilemap.map_to_local(bloque_pos) + tilemap.position
	var item_pos = bloque_pos2 + Vector2(0, -16)
	
	if TIPO_BLOQUE == Vector2i(2, 1):
		GlobalValues.bloqueSprite.get_child(0).frame = 13
		moneda_tween(item_pos)
	elif TIPO_BLOQUE == Vector2i(3, 1):
		GlobalValues.bloqueSprite.get_child(0).frame = 14
	
	GlobalValues.bloqueSprite.global_position = bloque_pos2
	
	# TWEEN DEL TILE (desplazamiento hacia arriba):
	var tween = create_tween()
	var startPos = GlobalValues.bloqueSprite.global_position
	var offset = GlobalValues.bloqueSprite.global_position + Vector2(0, -8)
	
	tween.tween_property(GlobalValues.bloqueSprite, "global_position", offset, 0.08)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(GlobalValues.bloqueSprite, "global_position", startPos, 0.08)\
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	# VOLVER A COLOCAR EL TILE:
	tween.tween_callback(Callable(self, "restore_block").bind(tilemap, tile_pos, source_id, TIPO_BLOQUE))

#func reemplazar_tile():
	#tilemap.set_cell(0, tile_pos, new_tile_id) # Cambia el tile
	#var moneda = preload("res://moneda.tscn").instantiate()
	#moneda.global_position = tilemap.map_to_local(tile_pos)
	#get_tree().current_scene.add_child(moneda)

# CREAR TWEEN MONEDA ROTANDO HACIA ARRIBA:
func moneda_tween(item_pos):
	print(item_pos, GlobalValues.lista_setas)
	
	if item_pos in GlobalValues.lista_setas:
		GlobalValues.setaSprite.get_child(0).global_position = item_pos
		GlobalValues.setaSprite.get_child(0).activa = true
	else:
		GlobalValues.monedaSprite.global_position = item_pos
		
		# CREAR TWEEN MONEDA ROTANDO HACIA ARRIBA:
		var tween = create_tween()
		var offset = item_pos + Vector2(0, -32)
		print("item_pos", item_pos)
		
		tween.tween_property(GlobalValues.monedaSprite, "global_position", offset, 0.3)\
			.set_trans(Tween.TRANS_LINEAR)
		
		# DESAPARECER:
		tween.tween_callback(Callable(self, "fin_moneda_ocultar"))

func fin_moneda_ocultar():
	GlobalValues.monedaSprite.global_position += Vector2(0, -500)

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
