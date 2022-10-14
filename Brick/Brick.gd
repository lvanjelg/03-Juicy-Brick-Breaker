extends StaticBody2D

var score = 0
var new_position = Vector2.ZERO
var dying = false
export var time_appear = 0.5
export var time_fall = 0.8
export var time_rotate = 1.0
export var time_a = 0.8
export var time_s = 1.2
export var time_v = 1.5

var powerup_prob = 0.1

var colors = [
	Color8(131, 125, 138),
	Color8(121, 107, 138),
	Color8(118, 93, 148),
	Color8(117, 87, 153),
	Color8(105, 66, 153),
	Color8(96, 49, 153),
	Color8(83, 30, 148),
	Color8(69, 7, 145)
]

var color_ind = 0
var color_distance = 0
var color_completed = true
var color_initial_pos = Vector2.ZERO
var color_randomizer = Vector2.ZERO

func _ready():
	randomize()
	position.x = new_position.x
	position.y = -100
	$Tween.interpolate_property(self, "position", position, new_position, time_appear + randf()*2, Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	$Tween.start()
	if score >= 100: color_ind = 7
	elif score >= 90: color_ind = 6
	elif score >= 80: color_ind = 5
	elif score >= 70: color_ind = 4
	elif score >= 60: color_ind = 3
	elif score >= 50: color_ind = 2
	elif score >= 40: color_ind = 1
	else: color_ind = 0
	$ColorRect.color = colors[color_ind]
	color_initial_pos = $ColorRect.rect_position
	color_randomizer = Vector2(randf()*6-3.0, randf()*6-3.0)

func _physics_process(_delta):
	if dying and not $Tween.is_active():
		queue_free()

func hit(_ball):
	var brick_sound = get_node_or_null("/root/Game/Brick")
	if brick_sound != null:
		brick_sound.play()
	die()

func die():
	dying = true
	collision_layer = 0
	Global.update_score(score)
	if not Global.feverish:
		Global.update_fever(score)
	get_parent().check_level()
	$Tween.interpolate_property(self, "position", position, Vector2(position.x, 1000), time_fall, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rotation", rotation, -PI + randf()*2*PI, time_rotate, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($ColorRect, "color:a", $ColorRect.color.a, 0, time_a, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($ColorRect, "color:s", $ColorRect.color.s, 0, time_s, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.interpolate_property($ColorRect, "color:v", $ColorRect.color.v, 0, time_v, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	if randf() < powerup_prob:
		var Powerup_Container = get_node_or_null("/root/Game/Powerup_Container")
		if Powerup_Container != null:
			var Powerup = load("res://Powerups/Powerup.tscn")
			var powerup = Powerup.instance()
			powerup.position = position
			Powerup_Container.call_deferred("add_child", powerup)
