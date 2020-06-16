extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
export var JUMP_STRENGTH: float = 75.0;
export var PUSH_STRENGTH: float = 75.0;
export var BOUNCE_STRENGTH: float = 15.0;
export var GRAVITY: float = 2.0;
export var MAX_COOLDOWN: float = 0.2;

export var local_time_scale: float

var velocity: Vector2 = Vector2.ZERO
var cooldown: float
var alive: bool

var CastLeft: RayCast2D
var CastRight: RayCast2D
var Animator: AnimationPlayer
var BallImage: Sprite
var BallHighlight: Sprite
var Particle = preload("res://Scenes/Objects/Emitter.tscn")

signal entered_hazard
signal touched_flag


# Called when the node enters the scene tree for the first time.
func _ready():
	alive = true
	CastLeft = $RayCastLeft
	CastRight = $RayCastRight
	BallImage = $Sprite
	BallHighlight = $Highlight
	Animator = $AnimationPlayer
	cooldown = 0.0
	
	local_time_scale = 1

# warning-ignore:unused_argument
func _process(delta):
	if alive:
		control()

func _physics_process(delta):
	
	delta *= local_time_scale
	velocity.y += GRAVITY
	
	velocity.x *= 0.98
	if cooldown > 0.0:
		cooldown -= delta
	var collision = self.move_and_collide(velocity * delta)
	if collision:
		var dot_normal = collision.normal.dot(Vector2.UP)
		if dot_normal < 0.1 and dot_normal > -0.1:
			velocity = velocity.bounce(collision.normal)*Vector2(0.8,1.0)
			velocity.y -= BOUNCE_STRENGTH
		else:
			velocity = velocity.slide(collision.normal)*Vector2(0.98,1.0)
	
	distort(BallImage, velocity*delta, Vector2(-0.005,0.015), 0.047)
	distort(BallHighlight, velocity*delta, Vector2(-0.005,0.005), 0.023)
			
func control():
	if Input.is_action_just_pressed("ui_accept"):
		if CastLeft.is_colliding() or CastRight.is_colliding():
			velocity.y -= JUMP_STRENGTH
	
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

func _on_Effector_body_entered(body):
	if body.is_in_group("flag") :
		local_time_scale = 0.2
		emit_signal("touched_flag")
	elif body.is_in_group("hazards"):
		alive = false
		local_time_scale = 0.2
		emit_signal("entered_hazard")
