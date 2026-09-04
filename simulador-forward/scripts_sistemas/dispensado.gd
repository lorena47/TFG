class_name Dispensado
extends Movil

func interactuar(objeto: Node3D = null):
	if objeto is Recipiente or objeto is Instrumento or objeto is Contenedor:
		if await objeto.recibir_interaccion(self):
			Gestor.emitir(Evento.Tipo.VERTER, self, null, objeto)


func texto_interaccion(objeto: Node3D = null) -> String:
	var texto := ""

	if objeto is Recipiente or objeto is Instrumento or objeto is Contenedor:
		if objeto.has_method("puede_recibir") and objeto.puede_recibir(self):
			texto = "Verter"

	return texto
