extends PanelContainer

@onready var musicaIntro = get_node("../MusicaIntroMarioSnes")

func _ready():
	musicaIntro.play()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_button_3_pressed() -> void:
	get_tree().quit()
