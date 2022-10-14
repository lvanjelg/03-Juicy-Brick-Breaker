extends Node2D


func _physics_process(_delta):
	for comet in get_children():
		if comet.modulate.a <= 0 or comet.modulate.v <= 0:
			comet.queue_free()
		comet.scale *= 0.99
		comet.modulate.a -= 0.03
		comet.modulate.v -= 0.01
		comet.modulate.h += 0.02

