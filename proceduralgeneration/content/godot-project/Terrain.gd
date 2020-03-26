extends Spatial

onready var spr = $Sprite3D
onready var meshinst = $MeshInstance

func _ready():
	print("hello")
	gen()
	
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		gen()

func gen():
	# if you're here to learn about how to generate geometry, i'm probably
	# doing it very badly and you should read the actual documentation :)
	
	var tex = spr.texture
	var image = tex.noise.get_image(tex.width, tex.height)
	image.lock()
	
	var surface_tool = SurfaceTool.new()
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.add_smooth_group(true)
	
	var step = 16
	var f = -16

	for x in range(0, tex.get_width() - step, step):
		for y in range(0, tex.get_height() - step, step):
			surface_tool.add_vertex(Vector3(x/step, y/step, image.get_pixel(x,y)[0] * f))
			surface_tool.add_vertex(Vector3((x+step)/step, y/step, image.get_pixel(x+step,y)[0] * f))
			surface_tool.add_vertex(Vector3(x/step, (y+step)/step, image.get_pixel(x,y+step)[0] * f))
			
			surface_tool.add_vertex(Vector3((x+step)/step, y/step, image.get_pixel(x+step,y)[0] * f))
			surface_tool.add_vertex(Vector3((x+step)/step, (y+step)/step, image.get_pixel(x+step,y+step)[0] * f))
			surface_tool.add_vertex(Vector3(x/step, (y+step)/step, image.get_pixel(x,y+step)[0] * f))
	
	surface_tool.index()
	surface_tool.generate_normals()
	
	$MeshInstance.mesh = surface_tool.commit();
