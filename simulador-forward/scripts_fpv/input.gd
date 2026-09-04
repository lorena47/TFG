extends Node3D

@onready var sistemas = $"../Sistemas"
@onready var ui = get_tree().current_scene.get_node("ui")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	ui.set_puntero(sistemas.accion_disponible)
	ui.mostrar_apuntado(sistemas.nombre_apuntado)
	ui.mostrar_acciones(sistemas.acciones_disponibles())


func _input(event):
	
	#if event.is_action_pressed("ui_cancel"):
		#get_tree().quit()
	
	#if event.is_action_pressed("ui_cancel"):
		#if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#else:
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if event.is_action_pressed("avanzar_instrucciones"):
		ui.avanzar_instrucciones()
		
	if event.is_action_pressed("retroceder_instrucciones"):
		ui.retroceder_instrucciones()

	if event.is_action_pressed("ingredientes"):
		ui.alternar_cuaderno(sistemas.apuntado)
 
	if event.is_action_pressed("scroll"):
		ui.desplazar_scroll_cuaderno()
		ui.desplazar_scroll_errores()

	if event.is_action_pressed("scroll_arriba"):
		ui.desplazar_scroll_cuaderno(-1)
		ui.desplazar_scroll_errores(-1)
	
	if event.is_action_pressed("tirar"):
			sistemas.tirar()
		
	if sistemas.apuntado != null:

		if event.is_action_pressed("puertas"):
			sistemas.puertas()

		if event.is_action_pressed("pick"):
			sistemas.pick()
		
		if event.is_action_pressed("interactuar"):
			sistemas.interactuar()
