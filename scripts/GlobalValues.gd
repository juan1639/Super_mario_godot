extends Node

# CONSTANTES GLOBALES:
const GRAVEDAD = 90.0

# LIMITES MUNDO:
const LIMITE_IZ = -1700
const LIMITE_DE = 1700
const BOTTOM_LIMIT = 999 # BOTTOM-LIMIT (si es necesario)

# VARIABLES GLOBALES:
var ref_tilemap: TileMapLayer = null
var flag_sprite: Sprite2D = null
var bloqueSprite: Node2D = null
var monedaSprite: Sprite2D = null
var setaSprite: Node2D = null

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

# ITEMS (SETAS, y SETAS-EXTRA):
var lista_setas = [
	Vector2(-1352, -72), Vector2(-664, -88), Vector2(-440, -72), Vector2(40, -136)
]

var lista_desactivados = []
