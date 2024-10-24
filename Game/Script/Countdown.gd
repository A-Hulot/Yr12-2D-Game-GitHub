extends Label
@onready var _1s = $"1s"
@onready var global = get_node("/root/Global")

var time = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# If time isn't 0, the time will decrease by 1.
func _on_s_timeout():
	if time != 0:
		time -= 1
		# If time hits 0 seconds, the countown will hide and players can move.
		if time == 0:
			hide()
			global.canmove = true
		else:
			text = str(time)
		_1s.start()
