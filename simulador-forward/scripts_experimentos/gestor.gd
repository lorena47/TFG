extends Node

var depurar := false

var estado := {}
var objetos := []
var experimento: Experimento = null

signal evento_recibido(evento: Evento)
signal experimento_finalizado

var _finalizado_notificado := false

var _pausas_activas := 0


func _ready():
	evento_recibido.connect(_al_recibir_evento)
	reiniciar()


func reiniciar() -> void:
	estado.clear()
	objetos.clear()
	_finalizado_notificado = false
	_pausas_activas = 0
	experimento = DeterminacionProteinasKjeldahl.new()
	call_deferred("registrar_objetos_experimento")


func pausar() -> void:
	_pausas_activas += 1
	get_tree().paused = true


func reanudar() -> void:
	_pausas_activas = max(_pausas_activas - 1, 0)
	get_tree().paused = _pausas_activas > 0


func finalizar_experimento_manual() -> float:
	_finalizado_notificado = true
	return experimento.finalizar_experimento()


func emitir_evento(evento: Evento):
	evento_recibido.emit(evento)


func emitir(tipo: Evento.Tipo, objeto: Node, origen: Node = null, destino: Node = null, datos := {}):

	var evento := Evento.new()

	evento.tipo = tipo
	evento.objeto = objeto
	evento.origen = origen
	evento.destino = destino
	evento.datos = datos

	evento_recibido.emit(evento)


func registrar_objetos_experimento():
	if experimento != null:
		var raiz := get_tree().current_scene
		if raiz == null:
			raiz = get_tree().root
		for nombre in experimento.objetos_requeridos:
			var objeto := _buscar_en_arbol(raiz, nombre)
			if objeto != null:
				registrar(objeto)
			else:
				if depurar:
					push_warning("Objeto requerido por el experimento no encontrado en la escena: " + nombre)


func _buscar_en_arbol(raiz: Node, nombre: String) -> Node:
	var salida = null
	if "info" in raiz and raiz.info != null and raiz.info.nombre == nombre:
		salida = raiz
	else:
		for hijo in raiz.get_children():
			var encontrado := _buscar_en_arbol(hijo, nombre)
			if encontrado != null:
				salida = encontrado
				break
	return salida


func registrar(objeto: Node):
	if objeto != null and !objetos.has(objeto):
		#if depurar:
			#print("REGISTRANDO:", _nombre_de(objeto), " (", objeto.get_class(), ")")
		objetos.append(objeto)
		objeto.tree_exiting.connect(_al_salir_del_arbol.bind(objeto))


func _nombre_de(objeto: Node) -> String:
	var nombre := "superficie"
	if objeto != null:
		if "info" in objeto and objeto.info != null:
			nombre = objeto.info.nombre
		else:
			nombre = objeto.name
	return nombre


func _al_recibir_evento(evento: Evento):
	registrar(evento.objeto)
	registrar(evento.origen)
	registrar(evento.destino)

	match evento.tipo:

		Evento.Tipo.COLOCAR:
			estado[evento.objeto] = evento.destino
			if depurar:
				print(_nombre_de(evento.objeto), " colocado en ", _nombre_de(evento.destino))

		Evento.Tipo.RETIRAR:
			estado.erase(evento.objeto)
			if depurar:
				if evento.origen != null:
					print(_nombre_de(evento.objeto), " retirado de ", _nombre_de(evento.origen))
				else:
					print(_nombre_de(evento.objeto), " retirado")

		Evento.Tipo.DISPENSAR:
			if depurar:
				print(_nombre_de(evento.objeto), " dispensado desde ", _nombre_de(evento.origen))

		Evento.Tipo.VERTER:
			if depurar:
				print(_nombre_de(evento.objeto), " vertido en ", _nombre_de(evento.destino))

		Evento.Tipo.INTERACTUAR:
			if depurar:
				if evento.datos.is_empty():
					print(_nombre_de(evento.objeto), " interaccionado")
				else:
					print(_nombre_de(evento.objeto), " interaccionado (", evento.datos, ")")

		Evento.Tipo.VACIAR:
			if depurar:
				print(_nombre_de(evento.objeto), " vaciado")

	if experimento != null:
		experimento.recibir_evento(evento)
		if experimento.finalizado and not _finalizado_notificado:
			_finalizado_notificado = true
			experimento_finalizado.emit()


func _al_salir_del_arbol(objeto: Node):
	if is_instance_valid(objeto) and objeto.is_queued_for_deletion():
		objetos.erase(objeto)
		estado.erase(objeto)


func donde_esta(objeto: Node) -> Node:
	return estado.get(objeto)


func esta_en(objeto: Node, destino: Node) -> bool:
	return estado.get(objeto) == destino


func buscar_objeto(nombre: String) -> Node3D:
	var encontrado = null
	for objeto in objetos:
		if is_instance_valid(objeto) and "info" in objeto and objeto.info != null and objeto.info.nombre == nombre:
			encontrado = objeto
			break

		#print("OBJETOS REGISTRADOS:")
		#for objeto in objetos:
			#if is_instance_valid(objeto):
				#print("-", objeto.info.nombre)
	return encontrado


func buscar_instrumento(nombre: String) -> Instrumento:
	var encontrado: Instrumento = null
	for objeto in objetos:
		if is_instance_valid(objeto) and objeto is Instrumento and "info" in objeto and objeto.info != null and objeto.info.nombre == nombre:
			encontrado = objeto
			break
	return encontrado
