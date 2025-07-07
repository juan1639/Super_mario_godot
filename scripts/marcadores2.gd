extends PanelContainer

# REFERENCIAS:
@onready var score = $MarginContainer/HBoxContainer/VBoxContainer0/ScoreNum
@onready var monedas = $MarginContainer/HBoxContainer/VBoxContainer2/MonedasNum
@onready var world = $MarginContainer/HBoxContainer/VBoxContainer3/WorldNum
@onready var tiempo = $MarginContainer/HBoxContainer/VBoxContainer4/TimeNum

var signalConnect = false

func _ready():
	if MarioFuncionesAux.has_signal("marcador_actualizado"):
		print("hecho")
		MarioFuncionesAux.connect("marcador_actualizado", Callable(self, "_actualizar_score"))
		MarioFuncionesAux.connect("monedas_actualizadas", Callable(self, "_actualizar_monedas"))
	
	GlobalValues.marcadores["score"] = 0
	
	#for obj in self.get_children():
		#obj.scale = Vector2(1.5, 1.5)

# FUNCION EJECUTANDOSE A 60 FPS (PARA RENDERIZAR EL TIEMPO):
func _process(delta):
	tiempo.text = str(int(GlobalValues.marcadores["time"]))

func _actualizar_score():
	score.text = str(GlobalValues.marcadores["score"])

func _actualizar_monedas():
	monedas.text = "x " + str(GlobalValues.marcadores["coins"])
