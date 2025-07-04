extends Panel

# REFERENCIAS:
@onready var score = $ScoreNum
@onready var monedas = $MonedasNum
@onready var world = $WorldNum
@onready var tiempo = $TimeNum

var signalConnect = false

func _ready():
	if MarioFuncionesAux.has_signal("marcador_actualizado"):
		print("hecho")
		MarioFuncionesAux.connect("marcador_actualizado", Callable(self, "_actualizar_score"))
	
	GlobalValues.marcadores["score"] = 0

func _actualizar_score():
	score.text = str(GlobalValues.marcadores["score"])
