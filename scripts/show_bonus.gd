extends Sprite2D

var choose_bonus = {
	"1000": 0, "2000": 1, "5000": 2,
	"100": 3, "200": 4, "400": 5, "800": 6
}

var frame_ssheet = 0
const vel_y = 45
const direccion = -1

@onready var timer = $Timer

# FUNCION INIT:
func _ready():
	frame = frame_ssheet
	global_position += Vector2(0, -48)
	timer.start(1.0)

# FUNCION A 60 FPS:
func _process(delta):
	global_position.y += direccion * vel_y * delta
	
	if timer.time_left <= 0.0:
		queue_free()
