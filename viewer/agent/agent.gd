extends Node3D

var selected_material = preload("res://viewer/materials/selected_agent.tres")
var default_material = preload("res://viewer/materials/agent.tres")

func select():
	for child in self.get_children():
		if child is MeshInstance3D:
			child.material_override = selected_material
	
func deselect():
	for child in self.get_children():
		if child is MeshInstance3D:
			child.material_override = default_material
