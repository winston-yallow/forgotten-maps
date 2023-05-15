class_name CompassBar
extends Control


@onready var shader: ShaderMaterial = %Degrees.material


var heading: float = 0.0:
	set(value):
		heading = value
		shader.set_shader_parameter("offset", (heading / TAU) + 0.5)
