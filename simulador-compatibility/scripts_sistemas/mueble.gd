extends Node3D

@export var puertas: Array[String] = []
@export var carpeta := ""
@export var sustituir_animacion := false

var estado_cerrado := {}


# Called when the node enters the scene tree for the first time.
func _ready():
	for puerta in puertas:
		estado_cerrado[puerta] = true
	if sustituir_animacion:
		_sustituir_animaciones()


func puerta(lado := ""):
	if lado == "":
		lado = puertas[0]

	if estado_cerrado.has(lado):
		if estado_cerrado[lado]:
			_abrir(lado)
		else:
			_cerrar(lado)


func _abrir(lado := ""):
	$AnimationPlayer.process_mode = Node.PROCESS_MODE_ALWAYS
	Gestor.pausar()
 
	$AnimationPlayer.play("Abrir" + lado)
	estado_cerrado[lado] = false
 
	await $AnimationPlayer.animation_finished
	Gestor.reanudar()
 
 
func _cerrar(lado := ""):
	$AnimationPlayer.process_mode = Node.PROCESS_MODE_ALWAYS
	Gestor.pausar()
 
	$AnimationPlayer.play_backwards("Abrir" + lado)
	estado_cerrado[lado] = true
 
	await $AnimationPlayer.animation_finished
	Gestor.reanudar()


func texto_puertas(lado := "") -> String:
	if lado == "":
		lado = puertas[0]

	if estado_cerrado[lado]:
		return "Abrir"
	else:
		return "Cerrar"


func _sustituir_animaciones() -> void:
	var libreria = $AnimationPlayer.get_animation_library("")
	if libreria != null:
		for nombre_animacion in libreria.get_animation_list():
			var ruta_segura := "res://animaciones_safe/%s/%s.anim" % [carpeta, nombre_animacion]
			if ResourceLoader.exists(ruta_segura):
				var animacion_segura: Animation = load(ruta_segura)
				libreria.remove_animation(nombre_animacion)
				libreria.add_animation(nombre_animacion, animacion_segura)
			else:
				push_warning("Sin copia segura para " + nombre_animacion + " (buscada en " + ruta_segura + ")")
