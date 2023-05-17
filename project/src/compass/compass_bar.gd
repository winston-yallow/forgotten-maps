class_name CompassBar
extends ColorRect


@onready var shader: ShaderMaterial = material


var heading: float = 0.0:
	set(value):
		heading = value
		shader.set_shader_parameter("offset", (heading / TAU) + 0.5)
