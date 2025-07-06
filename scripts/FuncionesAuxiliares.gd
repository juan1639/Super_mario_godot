extends Node

var tiempo_actual = 0.0

# APLICAR GRAVEDAD:
func aplicar_gravedad(delta, context):
	if not context.is_on_floor():
		context.acel_gravedad += GlobalValues.GRAVEDAD * delta
		context.velocity.y += context.acel_gravedad
	else:
		context.acel_gravedad = 0
		if not GlobalValues.estado_juego["transicion_vida_menos"]:
			context.velocity.y = 0

func efecto_intermitente_invulnerable(delta, context):
	if context.invulnerability:
		tiempo_actual += delta

		# Cambia el color cada frame o según el tiempo
		var intensidad = sin(tiempo_actual * 20.0) * 0.5 + 0.5
		context.modulate = Color(1, intensidad, intensidad)
	else:
		tiempo_actual = 0.0
