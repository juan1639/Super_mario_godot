extends Node

# CONTANTAES COMPARTIDAS:
# GRAVEDAD:
const GRAVEDAD = 90.0

# LIMITES MUNDO:
const LIMITE_IZ = -1700
const LIMITE_DE = 1700

# REFERENCIA A LA BANDERA-SPRITE:
var flag_sprite: Sprite2D = null
var ref_tilemap: TileMapLayer = null

# ESTADOS DEL JUEGO
var estado_juego = {
	"prejuego": true,
	"en_juego": false,
	"transicion_flag_pole": false,
	"transicion_goal_zone": false,
	"transicion_vida_menos": false,
	"transicion_fireworks": false,
	"game_over": false
}
