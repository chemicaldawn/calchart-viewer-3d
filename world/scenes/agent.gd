extends Node3D

var selected_material = preload("res://world/materials/selected_agent.tres")
var default_material = preload("res://world/materials/agent.tres")

func select():
	$Body.material_override = selected_material
	$Marker.visible = true
	
func deselect():
	$Body.material_override = default_material
	$Marker.visible = false
