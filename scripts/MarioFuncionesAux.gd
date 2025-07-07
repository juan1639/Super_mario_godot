extends Node

signal marcador_actualizado
signal monedas_actualizadas

@onready var show_bonus_scene = preload("res://scenes/show_bonus.tscn")

# IDENTIFICAR TILE (EN LA POSICION DE MARIO):
func identificar_tile(global_position, salto, timer, sonido_coin):
	var tilemap = GlobalValues.ref_tilemap
	
	# OBTENEMOS EL TILE EN LA POSICION DE MARIO (y restamos (0,-1) encima de mario)
	var tile_pos = tilemap.local_to_map(global_position)
	tile_pos += Vector2i(0, -1)

	# Asegurar de que haya un tile ahí
	var source_id = tilemap.get_cell_source_id(tile_pos)
	
	if source_id == -1:
		return
	
	var atlas_coords = tilemap.get_cell_atlas_coords(tile_pos)
	#print("Coords del tile golpeado:", atlas_coords)
	
	# TILE-INTERROGACION = (2,1) | TILE-BLOQUE-LADRILLO = (3,1):
	const INTERROGACION = Vector2i(2, 1)
	const BLOQUE_LADRILLO = Vector2i(3, 1)
	const BLOQUE_INVISIBLE = Vector2i(0, 0)
	
	if timer.time_left > 0.0:
		return
	
	timer.start(0.2)
	
	if atlas_coords == INTERROGACION or atlas_coords == BLOQUE_INVISIBLE:
		impacto_bloques_tween(tilemap, tile_pos, source_id, INTERROGACION, global_position, salto, sonido_coin)
	elif atlas_coords == BLOQUE_LADRILLO:
		impacto_bloques_tween(tilemap, tile_pos, source_id, BLOQUE_LADRILLO, global_position, salto, sonido_coin)

# VOLVER A COLOCAR EL TILE (tras el tween):
func restore_block(tilemap: TileMapLayer, tile_pos: Vector2i, source_id: int, TIPO_BLOQUE: Vector2i):
	tilemap.set_cell(tile_pos, source_id, TIPO_BLOQUE)

# TWEEN TILES:
func impacto_bloques_tween(tilemap, tile_pos, source_id, TIPO_BLOQUE, global_position, salto, sonido_coin):
	# SUSTITUIR TEMPORALMENTE POR TILE(0,0)=CIELO_AZUL (efecto desaparece temporalmente):
	tilemap.set_cell(tile_pos, source_id, Vector2i(0, 0))
	# RESETEAR salto["presionado"]:
	salto["presionado"] = false
	#velocity.y = 0
	
	# PONER UN BLOQUE-SPRITE (IDENTICO AL TILE):
	var pos_mario_cabeza = global_position + Vector2(0, -16)
	var bloque_pos = tilemap.local_to_map(tilemap.to_local(pos_mario_cabeza))
	var bloque_pos2 = tilemap.map_to_local(bloque_pos) + tilemap.position
	var item_pos = bloque_pos2 + Vector2(0, -16)
	
	# ASEGURAR QUE EL TILE SE PONGA OPACO (DESPUES SE TRANSPARENTARA):
	GlobalValues.bloqueSprite.modulate = Color(1, 1, 1, 1)
	
	# QUE TIPO DE BLOQUE? (INTERROGACION O LADRILLO):
	if TIPO_BLOQUE == Vector2i(2, 1):
		GlobalValues.bloqueSprite.get_child(0).frame = 13
		moneda_tween(item_pos, sonido_coin, global_position)
	elif TIPO_BLOQUE == Vector2i(3, 1):
		GlobalValues.bloqueSprite.get_child(0).frame = 14
		item_ladrillos(item_pos, sonido_coin, global_position)
	
	GlobalValues.bloqueSprite.global_position = bloque_pos2
	#GlobalValues.bloqueSprite.visible = true
	
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
	
	# DESAPARECER (TRANSPARENTAR) EL 'TILE-SPRITE' TEMPORAL:
	tween.tween_property(GlobalValues.bloqueSprite, "modulate", Color(0, 0, 0, 0), 0.1).set_ease(Tween.EASE_IN)
	
	# COLOCAR EL TILE-DESACTIVADO:
	if TIPO_BLOQUE == Vector2i(2, 1):
		tween.tween_callback(Callable(self, "restore_block").bind(tilemap, tile_pos, source_id, Vector2i(7, 3)))

#func reemplazar_tile():
	#tilemap.set_cell(0, tile_pos, new_tile_id) # Cambia el tile
	#var moneda = preload("res://moneda.tscn").instantiate()
	#moneda.global_position = tilemap.map_to_local(tile_pos)
	#get_tree().current_scene.add_child(moneda)

# CREAR TWEEN MONEDA ROTANDO HACIA ARRIBA:
func moneda_tween(item_pos, sonido_coin, global_position):
	print(item_pos, GlobalValues.lista_setas)
	
	if item_pos in GlobalValues.lista_setas or item_pos in GlobalValues.lista_setas_extra:
		if not item_pos in GlobalValues.lista_desactivados:
			GlobalValues.setaSprite.get_child(0).global_position = item_pos
			GlobalValues.setaSprite.get_child(0).activa = true
			GlobalValues.setaSprite.get_child(0).sonido_seta.play()
			GlobalValues.lista_desactivados.append(item_pos)
	
	elif not item_pos in GlobalValues.lista_desactivados:
		sonido_coin.play()
		agregar_puntos(200, global_position)
		agregar_monedas(1)
		GlobalValues.monedaSprite.global_position = item_pos
		GlobalValues.lista_desactivados.append(item_pos)
		
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

# ESTRELLA, MONEDAS REPETITIVAS, etc.
func item_ladrillos(item_pos, sonido_coin, global_position):
	print(item_pos)
	
	if item_pos in GlobalValues.lista_estrellas:
		if not item_pos in GlobalValues.lista_desactivados:
			GlobalValues.estrellaSprite.global_position = item_pos
			GlobalValues.estrellaSprite.activa = true
			GlobalValues.setaSprite.get_child(0).sonido_seta.play()
			GlobalValues.lista_desactivados.append(item_pos)
	
	elif item_pos in GlobalValues.lista_repetitivas:
		if not item_pos in GlobalValues.lista_desactivados:
			moneda_tween(item_pos, sonido_coin, global_position)

# SCORES:
func agregar_puntos(cantidad, global_position):
	GlobalValues.marcadores["score"] += cantidad
	emit_signal("marcador_actualizado")
	var showBonus = show_bonus_scene.instantiate()
	showBonus.global_position = global_position
	showBonus.frame_ssheet = showBonus.choose_bonus[str(cantidad)]
	add_child(showBonus)

# SOLO SUMAR PUNTOS (BONUS-FINAL-NIVEL):
func agregar_puntos_sin_texto(cantidad):
	GlobalValues.marcadores["score"] += cantidad
	emit_signal("marcador_actualizado")

func agregar_monedas(cantidad):
	GlobalValues.marcadores["coins"] += cantidad
	emit_signal("monedas_actualizadas")
