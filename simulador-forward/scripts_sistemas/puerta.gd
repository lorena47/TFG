class_name Puerta
extends StaticBody3D

@export var lado: StringName
@export var info: Informacion


func puerta():
	get_parent().get_parent().puerta(lado)


func texto_puertas() -> String:
	return get_parent().get_parent().texto_puertas(lado)
