extends Camera3D

@export var sensibility := 200.0


func _input(event):
	if !get_tree().paused:
		if event is InputEventMouseMotion:
			rotation.x -= event.relative.y / sensibility
			rotation.x = clamp(rotation.x, deg_to_rad(-80), deg_to_rad(80))
