extends Node3D

@export var sensibility := 200.0

@onready var camara = get_parent().get_node("Yaw/Pitch")

@onready var raycast = camara.get_node("RayCast3D")
var apuntado : Node3D = null

var puerta := false

var interactuable := false
var distancia := 2.0
var nombre_apuntado := ""

@onready var mano = camara.get_node("Marker3D")
var en_mano : Movil = null
var soltando := false

var superficie := false
var apoyable := false
var apoyo : Node3D = null

var accion_disponible := false


#func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(_delta):
	_actualizar_apuntado()
	_actualizar_puerta()
	_actualizar_interactuable()
	_actualizar_accion_disponible()
	_actualizar_nombre_apuntado()
	_actualizar_apoyo()


func _actualizar_apuntado():
	apuntado = null
	if _al_alcance(distancia):
		apuntado = raycast.get_collider()


func _al_alcance(d: float) -> bool:
	var llegar := false
	if raycast.is_colliding():
		llegar = camara.global_position.distance_to(raycast.get_collision_point()) <= d
	return llegar


func _actualizar_accion_disponible():
	accion_disponible = interactuable or puerta


func _actualizar_puerta():
	puerta = apuntado is Puerta


func puertas():
	if apuntado is Puerta:
		apuntado.puerta()


func _actualizar_interactuable():
	interactuable = apuntado is Movil or apuntado is Instrumento


func _actualizar_nombre_apuntado():
	nombre_apuntado = ""
	if apuntado != null and "info" in apuntado and apuntado.info != null:
		nombre_apuntado = apuntado.info.nombre


func pick():
	if !soltando:
		if en_mano == null:
			_coger_objeto()
		else:
			_soltar_objeto()


func _coger_objeto():

	if apuntado is Instrumento:
		var objeto = apuntado.obtener_objeto()
		if objeto != null:
			en_mano = objeto
			en_mano.coger(mano)
			Gestor.emitir(Evento.Tipo.RETIRAR, en_mano, Gestor.donde_esta(en_mano))

	elif apuntado is Contenedor:
		if !apuntado.dispensador:
			var objeto = apuntado.obtener_objeto()
			if objeto != null:
				apuntado = objeto
		en_mano = apuntado
		en_mano.coger(mano)
		Gestor.emitir(Evento.Tipo.RETIRAR, en_mano, Gestor.donde_esta(en_mano))

	elif apuntado is Movil:
		en_mano = apuntado
		en_mano.coger(mano)
		var origen = Gestor.donde_esta(en_mano)
		Gestor.emitir(Evento.Tipo.RETIRAR, en_mano, origen)


func _soltar_objeto():
	if apoyo != null:
		soltando = true

		if apoyable:
			if apoyo.colocar(en_mano):
				en_mano = null
		elif superficie:
			var objeto := en_mano
			await en_mano.soltar(raycast.get_collision_point())
			Gestor.emitir(Evento.Tipo.COLOCAR, objeto, null, null)
			en_mano = null

		soltando = false


func _actualizar_apoyo():
	apoyable = false
	superficie = false
	apoyo = null

	if apuntado != null:
		apoyable = apuntado is Contenedor or apuntado is Instrumento
		superficie = apuntado.is_in_group("apoyo")
		if apoyable or superficie:
			apoyo = apuntado


func interactuar():
	if interactuable:
		if en_mano != null:
			en_mano.interactuar(apuntado)
			if not is_instance_valid(en_mano) or en_mano.get_parent() != mano:
				en_mano = null
		else:
			if await apuntado.recibir_interaccion():
				if apuntado is Contenedor:
					var contenedor := apuntado as Contenedor
					if contenedor.objeto_dispensado != null:
						en_mano = contenedor.objeto_dispensado
						contenedor.objeto_dispensado = null
						en_mano.coger(mano)


func tirar():
	if en_mano != null and en_mano.has_method("vaciar"):
		en_mano.vaciar()
		

func acciones_disponibles() -> Array[Dictionary]:
	var acciones: Array[Dictionary] = []
 
	if apuntado != null:
		if en_mano == null:
			var objeto_recogible: Movil = null
			if apuntado is Movil:
				objeto_recogible = apuntado
			elif apuntado is Instrumento:
				objeto_recogible = apuntado.obtener_objeto()
			
			if objeto_recogible != null:
				acciones.append({"boton": "pick", "texto": objeto_recogible.texto_coger()})

		elif apoyo != null:
			var puede_soltar := true
			if apoyable and apoyo.has_method("puede_colocar"):
				puede_soltar = apoyo.puede_colocar(en_mano)

			if puede_soltar:
				acciones.append({"boton": "pick", "texto": en_mano.texto_soltar()})
 
		if apuntado is Puerta:
			acciones.append({"boton": "puertas", "texto": apuntado.texto_puertas()})
 
		if interactuable:
			var origen = en_mano if en_mano != null else apuntado
			var objetivo = apuntado if en_mano != null else null
 
			if origen.has_method("texto_interaccion"):
				var texto: String = origen.texto_interaccion(objetivo)
				if texto != "":
					acciones.append({"boton": "interactuar", "texto": texto})
 
		if apuntado.has_method("texto_ingredientes"):
			acciones.append({"boton": "ingredientes", "texto": apuntado.texto_ingredientes()})
 
	if en_mano != null and en_mano.has_method("texto_vaciar"):
		acciones.append({"boton": "tirar", "texto": en_mano.texto_vaciar()})
 
	return acciones
