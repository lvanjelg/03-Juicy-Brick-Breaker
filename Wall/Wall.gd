extends StaticBody2D

var decay = 0.01

func _ready():
	pass

func _physics_process(_delta):
	pass

func hit(_ball):
	var wall_sound = get_node_or_null("/root/Game/Wall")
	if wall_sound != null:
		wall_sound.play()
