extends CPUParticles2D

var life
# Called when the node enters the scene tree for the first time.
func _ready():
	emitting = true

func _process(delta):
	if not emitting:
		queue_free()

func init(start_angle, start_dir):
	self.angle = start_angle
	self.direction = start_dir
