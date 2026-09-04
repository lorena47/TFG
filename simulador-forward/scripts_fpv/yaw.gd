extends Node3D

@export var sensibility := 200.0


func _input(event):
	if !get_tree().paused:
		if event is InputEventMouseMotion:
			rotation.y -= event.relative.x / sensibility
