extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
export var JUMP_STRENGTH: float = 75.0
export var PUSH_STRENGTH: float = 75.0
export var BOUNCE_STRENGTH: float = 15.0
export var GRAVITY: float = 2.0
export var MAX_COOLDOWN: float = 0.2
export var COYOTE_TIME: float = 0.1

var local_time_scale: float
var gravity_factor: float
var cooldown: float
var air_time: float
var alive: bool
var on_ground: bool
var velocity: Vector2 = Vector2.ZERO


var CastLeft: RayCast2D
var CastRight: RayCast2D
var Animator: AnimationPlayer
var BallImage: Sprite
var BallHighlight: Sprite
var Collider: CollisionShape2D

var Particle = preload("res://Scenes/Objects/Emitter.tscn")

signal entered_hazard
signal touched_flag

var Sounds: Array
enum {JUMP, BUMP, DIE, FINISH, ENTER_WATER, EXIT_WATER}

# Called when the node enters the scene tree for the first time.
func _ready():
	alive = true
	on_ground = false
	CastLeft = $RayCastLeft
	CastRight = $RayCastRight
	BallImage = $Sprite
	BallHighlight = $Highlight
	Animator = $AnimationPlayer
	Sounds = $Sounds.get_children()
	cooldown = 0.0
	gravity_factor = 1.0
	
	local_time_scale = 1.0

# warning-ignore:unused_argument
func _process(delta):
	if alive:
		control()

func _physics_process(delta):
	delta *= local_time_scale
	
	# Used for vibration and animation (see in collision processing)
	var prev_on_ground = on_ground
	on_ground = false
	
	velocity.y += GRAVITY*gravity_factor
	velocity.x *= 0.98
	
	if cooldown > 0.0:
		cooldown -= delta
	
	# Collision processing
	var collision = self.move_and_collide(velocity * delta)
	if collision:
		var dot_normal = collision.normal.dot(Vector2.UP)
		if dot_normal < 0.1 and dot_normal > -0.1:
			velocity = velocity.bounce(collision.normal)*Vector2(0.8,1.0)
			velocity.y -= BOUNCE_STRENGTH
			
			Input.start_joy_vibration(0, 0.6, 0.6, 0.05)
			play_sound(BUMP, -4.0, 1.0)
			
		else:
			velocity = velocity.slide(collision.normal)*Vector2(0.98,1.0)
			if dot_normal > 0.9:
				on_ground = true

	if on_ground:
		air_time = 0.0
	elif air_time < COYOTE_TIME:
		air_time += delta
	
	if on_ground and not prev_on_ground:
		Input.start_joy_vibration(0, 1.0, 1.0, 0.05)
	
	distort(BallImage, velocity*delta, Vector2(-0.005,0.015), 0.047)
	distort(BallHighlight, velocity*delta, Vector2(-0.005,0.005), 0.023)
			
func control():
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up"):
		if (air_time < COYOTE_TIME) or (CastLeft.is_colliding() or CastRight.is_colliding()):
			velocity.y = -JUMP_STRENGTH
			
			randomize()
			play_sound(JUMP, -2.0, randf()*0.5+0.65)
	
	if Input.is_action_just_pressed("ui_right"):
		if cooldown <= 0.0:
			dash(Vector2.RIGHT)
			
	if Input.is_action_just_pressed("ui_left"):
		if cooldown <= 0.0:
			dash(Vector2.LEFT)

func dash(dir: Vector2):
	velocity += dir*PUSH_STRENGTH
	cooldown = MAX_COOLDOWN
	
	Animator.play("dash")
	Animator.playback_speed = 1.0 / MAX_COOLDOWN
	
	var temp_particule = Particle.instance()
	temp_particule.init(rad2deg(dir.angle()), -dir)
	add_child(temp_particule)

func distort(sprite: Sprite, vel: Vector2, multiplier: Vector2, size: float):
	sprite.rotation_degrees = rad2deg(vel.angle())+90
	sprite.scale = Vector2(size, size) + multiplier*vel.length()

func play_sound(sound_id: int, volume: float, pitch: float):
	if sound_id < Sounds.size():
		Sounds[sound_id].volume_db = volume
		Sounds[sound_id].pitch_scale = pitch
		Sounds[sound_id].play()
	
func _on_Effector_body_entered(body):
	if body.is_in_group("flag") :
		local_time_scale = 0.2
		
		# Input.start_joy_vibration(0, 1.0, 1.0, 0.2)
		play_sound(FINISH, -1.0, 1.0)
		
		emit_signal("touched_flag")

	elif body.is_in_group("hazards"):
		alive = false
		local_time_scale = 0.0
		$DeathParticle.emitting = true
		$Collider.disabled = true
		
		Input.start_joy_vibration(0, 1.0, 1.0, 0.2)
		play_sound(DIE, 0.0, 1.0)
		
		get_tree().call_group("player_sprite", "hide")
		emit_signal("entered_hazard")
	
	elif body.is_in_group("water"):
		gravity_factor = -1.4
		
		play_sound(ENTER_WATER, -2.0, 1.0)
		AudioServer.set_bus_effect_enabled(0, 0, true)
		Input.start_joy_vibration(0, 0.5, 0.2, 0.1)

func _on_Effector_body_exited(body):
	if body.is_in_group("water"):
		gravity_factor = 1.0
		
		play_sound(EXIT_WATER, -2.0, 1.0)
		AudioServer.set_bus_effect_enabled(0, 0, false)
		Input.start_joy_vibration(0, 0.5, 0.2, 0.1)
