extends Node

enum RELEASE_TYPE {
	STABLE,
	EXPERIMENTAL
}

@export
var version_number : Vector3 = Vector3(1,0,0)

@export
var release_type : RELEASE_TYPE = RELEASE_TYPE.STABLE
var release_type_name = {
	RELEASE_TYPE.STABLE : "(Stable)",
	RELEASE_TYPE.EXPERIMENTAL : "(Experimental!)"
}

@export
var credits : PackedStringArray

func _ready():
	
	var version_string = "v" + str(version_number.x) + "." + str(version_number.y) + "." + str(version_number.z) + " " + release_type_name[release_type]
	var platform_string = OS.get_name()
	
	$"UI/Main Menu/Background/Version Info".text = version_string + "\n" + platform_string;
