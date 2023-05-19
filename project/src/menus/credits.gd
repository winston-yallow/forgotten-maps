extends VBoxContainer


const TITLE_SIZE := 25
const NAME_SIZE := 16
const TEXT_SIZE := 12


class License extends RefCounted:
	var name: String
	var text: String
	func _init(n: String, t: String) -> void:
		name = n
		text = t


class Section extends RefCounted:
	var name: String
	var licenses: Array[License]
	func _init(n: String, l: Array[License] = []) -> void:
		name = n
		licenses = l


var sections: Array[Section] = [
	Section.new("Godot Engine", [License.new("", Engine.get_license_text())]),
	Section.new("Copyright Notices", get_copyright_notices()),
	Section.new("Third-party Licenses", get_thirdparty_licenses()),
]

@onready var custom_licenses: RichTextLabel = %CustomLicenses
@onready var engine_licenses: RichTextLabel = %EngineLicenses


func _ready() -> void:
	custom_licenses.meta_clicked.connect(func (meta):
		OS.shell_open(str(meta))
	)
	
	for section in sections:
		engine_licenses.newline()
		engine_licenses.push_font_size(TITLE_SIZE)
		engine_licenses.add_text(section.name)
		engine_licenses.pop()
		engine_licenses.newline()
		for license in section.licenses:
			engine_licenses.newline()
			if not license.name.is_empty():
				engine_licenses.push_font_size(NAME_SIZE)
				engine_licenses.add_text(license.name)
				engine_licenses.pop()
				engine_licenses.newline()
			engine_licenses.push_font_size(TEXT_SIZE)
			engine_licenses.add_text(license.text)
			engine_licenses.pop()
			engine_licenses.newline()


func get_copyright_notices() -> Array[License]:
	var result: Array[License] = []
	var infos := Engine.get_copyright_info()
	for info in infos:
		var text := ""
		for part in info.parts:
			text += "\nFiles:\n"
			for file in part.files:
				text += "    %s\n" % file
			for line in part.copyright:
				text += "@ %s\n" % line
			text += "License: %s\n" % part.license
		result.append(License.new(info.name, text))
	return result


func get_thirdparty_licenses() -> Array[License]:
	var result: Array[License] = []
	var infos := Engine.get_license_info()
	for key in infos:
		result.append(License.new(key, infos[key]))
	return result
