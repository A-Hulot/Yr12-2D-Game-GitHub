extends CanvasLayer

@onready var global = get_node("/root/Global")
@onready var p1_score = $"P1 Score"
@onready var p2_score = $"P2 Score"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Updates player score with the current global score.
func _process(delta):
	p1_score.text = (str(global.score))
	p2_score.text = (str(global.score2))
