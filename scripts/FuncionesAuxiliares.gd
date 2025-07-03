extends Node

# APLICAR GRAVEDAD:
func aplicar_gravedad(delta, context):
	if not context.is_on_floor():
		context.acel_gravedad += GlobalValues.GRAVEDAD * delta
		context.velocity.y += context.acel_gravedad
	else:
		context.acel_gravedad = 0
		if not GlobalValues.estado_juego["transicion_vida_menos"]:
			context.velocity.y = 0
