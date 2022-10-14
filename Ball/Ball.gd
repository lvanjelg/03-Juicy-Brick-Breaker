extends RigidBody2D

var min_speed = 100.0
var max_speed = 600.0
var speed_multiplier = 1.0
var accelerate = false
var rot = 0.0
var released = true

var wobble_per = 0.0
var wobble_amp = 0.0
export var max_wobble = 5
var wobble_direction = Vector2.ZERO
var wobble_decay = 0.15
export var distort_effect = 0.0002

var initial_velocity = Vector2.ZERO

func _ready():
	contact_monitor = true
	contacts_reported = 8
	if Global.level < 0 or Global.level >= len(Levels.levels):
		Global.end_game(true)
	else:
		var level = Levels.levels[Global.level]
		min_speed *= level["multiplier"]
		max_speed *= level["multiplier"]
	

func _on_Ball_body_entered(body):
	if body.has_method("hit"):
		body.hit(self)
		accelerate = true
	$Tween.start()
	wobble_direction = linear_velocity.tangent().normalized()
	wobble_amp = max_wobble

func _input(event):
	if not released and event.is_action_pressed("release"):
		apply_central_impulse(initial_velocity)
		released = true


func _integrate_forces(state):
	if not released:
		var paddle = get_node_or_null("/root/Game/Paddle_Container/Paddle")
		if paddle != null:
			state.transform.origin = Vector2(paddle.position.x + paddle.width, paddle.position.y - 30)	
	else:
		comet()
		distort()
		wobble()

	if position.y > Global.VP.y + 100:
		die()
	if accelerate:
		state.linear_velocity = state.linear_velocity * 1.1
		accelerate = false
	if abs(state.linear_velocity.x) < min_speed * speed_multiplier:
		state.linear_velocity.x = sign(state.linear_velocity.x) * min_speed * speed_multiplier
	if abs(state.linear_velocity.y) < min_speed * speed_multiplier:
		state.linear_velocity.y = sign(state.linear_velocity.y) * min_speed * speed_multiplier
	if state.linear_velocity.length() > max_speed * speed_multiplier:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed * speed_multiplier

func change_speed(s):
	speed_multiplier = s

func comet():
	rot = wrapf(rot+.005,0,1)
	var comets = get_node_or_null("/root/Game/Comet_Container")
	if comets != null:
		var comet = $Images/Sprite.duplicate()
		comet.global_position = global_position
		comet.modulate.s = 0.3
		comet.modulate.a = 0.5
		comet.modulate.h = rot
		comets.add_child(comet)
	
func wobble():
	wobble_per += 0.3
	if wobble_amp >= 0:
		var pos = wobble_direction * wobble_amp * sin(wobble_per)
		$Images.position = pos
		wobble_amp -= wobble_decay
		
func distort():
	var direct = Vector2(1 + linear_velocity.length() * distort_effect, 1 - linear_velocity.length() * distort_effect)
	$Images.rotation = linear_velocity.angle()
	$Images.scale = direct

func die():
	var die_sound = get_node_or_null("/root/Game/Die")
	if die_sound != null:
		die_sound.play()
	queue_free()
