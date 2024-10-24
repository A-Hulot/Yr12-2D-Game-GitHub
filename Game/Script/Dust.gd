extends AnimatedSprite2D

# Gets rid of dust when animation has finished.
func _on_animation_finished():
	queue_free()
