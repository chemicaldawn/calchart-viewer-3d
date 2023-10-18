extends Node

enum RELEASE_TYPE {
	STABLE,
	EXPERIMENTAL
}

@export
var version_number : String = "1.0.0"

@export
var release_type : RELEASE_TYPE = RELEASE_TYPE.STABLE

@export
var credits : PackedStringArray
