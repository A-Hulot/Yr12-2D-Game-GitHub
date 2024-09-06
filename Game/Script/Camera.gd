extends Camera2D

@onready var p1 = get_parent().get_node("Knight2DP1")
@onready var p2 = get_parent().get_node("Knight2DP2")

var zoom_min = 1
var zoom_max = 1.7
var zoom_factor = 950

func _physics_process(_delta):
	position = (p1.position + p2.position) / Vector2(2, 2)

	var distance = p1.position.distance_to(p2.position)
	
	var zoom_value = max(zoom_min, min(zoom_max, zoom_factor / distance))
	
	zoom.x = zoom_value
	zoom.y = zoom_value
