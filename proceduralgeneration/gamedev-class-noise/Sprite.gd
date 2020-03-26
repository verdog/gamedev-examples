extends Sprite3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var tex = texture
	var image = tex.noise.get_image(tex.width, tex.height)
	image.lock()
	print(image.get_pixel(10,20))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
