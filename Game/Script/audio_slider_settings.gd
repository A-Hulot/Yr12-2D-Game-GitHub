extends Control


@onready var audio_name_lbl = $HBoxContainer/Audio_Name_Lbl
@onready var audio_num_lbl = $HBoxContainer/Audio_Num_Lbl
@onready var h_slider = $HBoxContainer/HSlider

@export_enum("Master", "Music", "Sfx") var bus_name : String #Exports audio busses

var bus_index : int = 0


func _ready():
	h_slider.value_changed.connect(on_value_changed)
	get_bus_name_by_index()
	set_name_label_text()
	set_slider_value()


# Gets the name of the audio bus and sets that as label name.
func set_name_label_text() -> void:
	audio_name_lbl.text = str(bus_name) + " Volume"


# Gets slider value and then shows it as a percentage
func set_audio_num_label_text() -> void:
	audio_num_lbl.text = str(h_slider.value * 100) + "%"


# Gets the audio bus names.
func get_bus_name_by_index() -> void:
	bus_index = AudioServer.get_bus_index(bus_name)


# Sets the slider value wo the volume.
func set_slider_value() -> void:
	h_slider.value = db_to_linear(AudioServer.get_bus_volume_db(bus_index))
	set_audio_num_label_text()


func on_value_changed(value : float) -> void:
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
	set_audio_num_label_text()
