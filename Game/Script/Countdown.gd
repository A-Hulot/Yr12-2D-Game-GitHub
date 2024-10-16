extends Label
var time = 3
@onready var _1s = $"1s"
@onready var global = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_s_timeout():
	if time != 0:
		time -= 1
		if time == 0:
			hide()
			global.canmove = true
		else:
			text = str(time)
		_1s.start()
