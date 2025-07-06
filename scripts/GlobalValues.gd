extends Node

# CONSTANTES GLOBALES:
const GRAVEDAD = 90.0
const DURACION_ESTRELLA = 8.1

# LIMITES MUNDO:
const LIMITE_IZ = -1700
const LIMITE_DE = 1700
const BOTTOM_LIMIT = 900 # BOTTOM-LIMIT (si es necesario)

# VARIABLES GLOBALES:
var ref_tilemap: TileMapLayer = null
var flag_sprite: Sprite2D = null
var bloqueSprite: Node2D = null
var monedaSprite: Sprite2D = null
var setaSprite: Node2D = null
var estrellaSprite: CharacterBody2D = null

# REFERENCIA GLOBAL A MARIO:
var marioRG: CharacterBody2D = null

# MUSICA FONDO:
var musicaFondo: AudioStreamPlayer2D = null

# MARCADORES:
const TIEMPO_INICIAL = 90

var marcadores = {
	"score": 0,
	"coins": 0,
	"world": [1, 1],
	"time:": TIEMPO_INICIAL,
	"lives": 4
}

# ESTADOS DEL JUEGO
var estado_juego = {
	"prejuego": true,
	"en_juego": false,
	"transicion_flag_pole": false,
	"transicion_goal_zone": false,
	"transicion_vida_menos": false,
	"transicion_next_vida": false,
	"transicion_fireworks": false,
	"fireworks": false,
	"game_over": false
}

# ITEMS (SETAS, y SETAS-EXTRA):
var lista_setas = [
	Vector2(-1352, -72), Vector2(-440, -72), Vector2(40, -136)
]

var lista_setas_extra = [
	Vector2(-664, -88)
]

var lista_estrellas = [
	Vector2(-72, -72)
]

var lista_repetitivas = [
	Vector2(-184, -72)
]

var lista_desactivados = []
