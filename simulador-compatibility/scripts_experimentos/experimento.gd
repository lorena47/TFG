class_name Experimento
extends RefCounted

var depurar := false

var errores := []
var hitos := {}

var objetos_requeridos: Array[String] = []

var penalizacion := 0.0
var finalizado := false
var puntuacion := 0.0


func _init():
	_definir_objetos_requeridos()
	_definir_hitos()


func _definir_objetos_requeridos():
	pass


func _definir_hitos():
	pass


func definir_hito(id, descripcion, requiere := [], predicado: Callable = Callable(), reinicia_si: Callable = Callable(), errores_hito: Callable = Callable(), revocable := false, grupo: String = "", padre: String = "", avisar_bloqueo := true):
	hitos[id] = _base_hito(descripcion, requiere)
	hitos[id]["predicado"] = predicado
	hitos[id]["reinicia_si"] = reinicia_si
	hitos[id]["errores"] = errores_hito
	hitos[id]["revocable"] = revocable
	hitos[id]["grupo"] = grupo
	hitos[id]["padre"] = padre
	hitos[id]["avisar_bloqueo"] = avisar_bloqueo


func _base_hito(descripcion, requiere: Array) -> Dictionary:
	return {
		"descripcion": descripcion,
		"requiere": requiere,
		"predicado": Callable(),
		"reinicia_si": Callable(),
		"errores": Callable(),
		"revocable": false,
		"grupo": "",
		"padre": "",
		"avisar_bloqueo": true,
		"alcanzado": false,
	}


func descripcion_hito(id: String) -> String:
	var descripcion := id
	if hitos.has(id):
		descripcion = hitos[id]["descripcion"]
	return descripcion


func grupo_hito(id: String) -> String:
	var grupo := ""
	if hitos.has(id):
		grupo = hitos[id]["grupo"]
	return grupo


func padre_visual_hito(id: String) -> String:
	var padre := ""
	if hitos.has(id):
		padre = hitos[id]["padre"]
	return padre


func subpasos_visuales(id: String) -> Array:
	var resultado := []
	for otro in hitos:
		if hitos[otro]["padre"] == id:
			resultado.append(otro)
	return resultado


func requisitos_pendientes(id: String) -> Array:
	var pendientes := []
	if hitos.has(id):
		for id_requerido in hitos[id]["requiere"]:
			if !hito_alcanzado(id_requerido):
				pendientes.append(id_requerido)
	return pendientes


func hijos(id: String) -> Array:
	var resultado := []
	for otro in hitos:
		if id in hitos[otro]["requiere"]:
			resultado.append(otro)
	return resultado


func desbloqueados() -> Array:
	var resultado := []
	for id in hitos:
		if !hitos[id]["alcanzado"] and requisitos_pendientes(id).is_empty():
			resultado.append(id)
	return resultado


func recibir_evento(evento: Evento):
	if depurar:
		print("-----------------------------")
		print("EVENTO:", evento.nombre_tipo())
	comprobar_hitos(evento)
	mostrar_estado_hitos()


func comprobar_hitos(evento: Evento = null):
	for id in hitos:
		var hito: Dictionary = hitos[id]

		if hito["alcanzado"]:
			if hito["revocable"] and evento != null:
				_comprobar_revocacion(id, evento)
		else:
			var pendientes := requisitos_pendientes(id)
			if pendientes.is_empty():
				_comprobar_hito_desbloqueado(id, evento)
			elif evento != null and hito["avisar_bloqueo"]:
				_comprobar_orden_bloqueado(id, evento, pendientes)

	_comprobar_padres_completos()
	_comprobar_finalizacion_automatica()


func _comprobar_padres_completos():
	var cambio := true
	while cambio:
		cambio = false
		for id in hitos:
			var hijos_visuales := subpasos_visuales(id)
			if hijos_visuales.is_empty():
				continue

			var hito: Dictionary = hitos[id]
			if hito["alcanzado"]:
				continue

			var todos_alcanzados := true
			for id_hijo in hijos_visuales:
				if !hito_alcanzado(id_hijo):
					todos_alcanzados = false
					break

			if todos_alcanzados:
				alcanzar_hito(id)
				cambio = true


func _comprobar_hito_desbloqueado(id: String, evento: Evento):
	var hito: Dictionary = hitos[id]
	var reiniciado := false

	if evento != null:
		var reinicia_si: Callable = hito["reinicia_si"]
		if reinicia_si.is_valid():
			var resultado_reinicio = reinicia_si.call(evento)
			if resultado_reinicio:
				if resultado_reinicio is String:
					error(resultado_reinicio, id)
				reiniciado = true

		if !reiniciado:
			var errores_hito: Callable = hito["errores"]
			if errores_hito.is_valid():
				var resultado_error = errores_hito.call(evento)
				if resultado_error:
					error(resultado_error
						if resultado_error is String
						else ("Error detectado en: " + hito["descripcion"]), id)
					reiniciado = true

	if !reiniciado and evento != null:
		var predicado: Callable = hito["predicado"]
		if predicado.is_valid() and predicado.call(evento):
			alcanzar_hito(id)


func _comprobar_revocacion(id: String, evento: Evento):
	var padre := padre_visual_hito(id)
	if padre == "" or !hito_alcanzado(padre):
		var hito: Dictionary = hitos[id]
		var reinicia_si: Callable = hito["reinicia_si"]
		if reinicia_si.is_valid():
			var resultado_reinicio = reinicia_si.call(evento)
			if resultado_reinicio:
				_desalcanzar_con_hijos(id)
				if resultado_reinicio is String:
					error(resultado_reinicio, id)


func _comprobar_orden_bloqueado(id: String, evento: Evento, pendientes: Array):
	var hito: Dictionary = hitos[id]
	var predicado: Callable = hito["predicado"]
	if predicado.is_valid() and predicado.call(evento):
		var mensaje := "No puedes completar:\n\n"
		mensaje += hito["descripcion"]
		mensaje += "\n\nAntes debes completar:\n"
		for id_requerido in pendientes:
			mensaje += "- " + descripcion_hito(id_requerido) + "\n"
		error(mensaje, id)


func alcanzar_hito(id: String) -> bool:
	var alcanzar := false
	if !hitos.has(id):
		push_warning("Hito no definido: " + id)
	else:
		var hito: Dictionary = hitos[id]
		if !hito["alcanzado"]:
			var pendientes := requisitos_pendientes(id)

			if !pendientes.is_empty():
				var mensaje := "No puedes realizar:\n\n"
				mensaje += hito["descripcion"]
				mensaje += "\n\nAntes debes completar:\n"
				for id_requerido in pendientes:
					mensaje += "- " + descripcion_hito(id_requerido) + "\n"
				error(mensaje, id)

			else:
				hito["alcanzado"] = true
				if depurar:
					print("HITO ALCANZADO: ", id, " (grupo ", grupo_hito(id), ": ", progreso(grupo_hito(id)) * 100, "%)")
				_alcanzar_con_hijos(id)
				if depurar:
					if completado():
						print("EXPERIMENTO COMPLETADO")
				alcanzar = true
	return alcanzar


func desalcanzar_hito(id: String):
	if hitos.has(id):
		hitos[id]["alcanzado"] = false


func hito_alcanzado(id: String) -> bool:
	return hitos.has(id) and hitos[id]["alcanzado"]


func _desalcanzar_con_hijos(id: String):
	desalcanzar_hito(id)
	for id_hijo in subpasos_visuales(id):
		if hito_alcanzado(id_hijo):
			_desalcanzar_con_hijos(id_hijo)


func _alcanzar_con_hijos(id: String):
	for id_hijo in subpasos_visuales(id):
		if !hito_alcanzado(id_hijo):
			hitos[id_hijo]["alcanzado"] = true
			if depurar:
				print("HITO ALCANZADO (heredado de ", id, "): ", id_hijo)
			_alcanzar_con_hijos(id_hijo)



func completado() -> bool:
	var completado := true
	if hitos.is_empty():
		completado = false
	else:
		for id in hitos:
			if !hitos[id]["alcanzado"]:
				completado = false
				break
	return completado


func errores_activos() -> Array:
	var por_texto := {}

	for id in hitos:
		var hito: Dictionary = hitos[id]
		if hito["alcanzado"]:
			if !hito["revocable"]:
				continue
		else:
			if !requisitos_pendientes(id).is_empty():
				continue

		var errores_hito: Callable = hito["errores"]
		if errores_hito.is_valid():
			var resultado_check = errores_hito.call(null)
			if resultado_check is String:
				if !por_texto.has(resultado_check):
					por_texto[resultado_check] = []
				var numero := grupo_hito(id)
				if numero != "" and !por_texto[resultado_check].has(numero):
					por_texto[resultado_check].append(numero)

	var resultado := []
	for texto in por_texto:
		var numeros: Array = por_texto[texto]
		var mensaje = texto
		if !numeros.is_empty():
			var etiqueta := "Hito" if numeros.size() == 1 else "Hitos"
			mensaje = "[%s %s] %s" % [etiqueta, ", ".join(numeros), texto]
		resultado.append(mensaje)
	return resultado


func error(texto: String, id_hito: String = ""):
	var mensaje := _con_prefijo_hito(texto, id_hito)
	errores.append(mensaje)
	if depurar:
		print("ERROR: ", mensaje)


func _con_prefijo_hito(texto: String, id_hito: String) -> String:
	var mensaje := texto
	if id_hito != "":
		var numero := grupo_hito(id_hito)
		if numero != "":
			mensaje = "[Hito %s] %s" % [numero, texto]
	return mensaje


func grupos() -> Array:
	var resultado := []
	for id in hitos:
		var grupo: String = hitos[id]["grupo"]
		if grupo != "" and !resultado.has(grupo):
			resultado.append(grupo)
	return resultado


func grupo_completado(grupo: String) -> bool:
	var completado_grupo := true
	for id in hitos:
		if hitos[id]["grupo"] == grupo and !hitos[id]["alcanzado"]:
			completado_grupo = false
			break
	return completado_grupo


func mostrar_estado_hitos():
	if depurar:
		for id in hitos:
			var hito: Dictionary = hitos[id]
			print(id, "  alcanzado=", hito["alcanzado"])


func progreso(grupo: String) -> float:
	var porcentaje := 0.0
	var total := 0
	var alcanzados := 0
	for id in hitos:
		if hitos[id]["grupo"] == grupo:
			total += 1
			if hitos[id]["alcanzado"]:
				alcanzados += 1
	if total > 0:
		porcentaje = float(alcanzados) / total
	return porcentaje


func progreso_grupos() -> float:
	var todos_grupos := grupos()
	var porcentaje := 0.0
	if !todos_grupos.is_empty():
		var completados := 0
		for grupo in todos_grupos:
			if grupo_completado(grupo):
				completados += 1
		porcentaje = float(completados) / todos_grupos.size() * 100.0
	return porcentaje


func penalizar(cantidad: float):
	penalizacion += cantidad


func finalizar_experimento() -> float:
	if !finalizado:
		finalizado = true
		puntuacion = progreso_grupos() - penalizacion
	return puntuacion


func _comprobar_finalizacion_automatica():
	if !finalizado and progreso_grupos() >= 100.0:
		finalizar_experimento()
