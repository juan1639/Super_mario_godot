extends Sprite2D

const vel_y = 30
const direccion = -1

@onready var timer = $Timer

# FUNCION INIT:
func _ready():
	scale = Vector2(0.5, 0.5)
	global_position += Vector2(0, -48)
	timer.start(1.8)

# FUNCION A 60 FPS:
func _process(delta):
	global_position.y += direccion * vel_y * delta
	
	if timer.time_left <= 0.0:
		queue_free()
