class_name Contenedor
extends Movil

@onready var marker = $Marker3D
@export var dispensador := false
@export var contenido: PackedScene

var objeto_dispensado: Dispensado = null

@export var nombres_aceptados: Array[String] = []


func colocar(objeto: Movil = null) -> bool:
	var exito := false

	if puede_colocar(objeto):
		objeto.cambiar_padre(marker)
		objeto.escalar_original(marker.global_basis.get_scale())
		Gestor.emitir(Evento.Tipo.COLOCAR, objeto, null, self)
		exito = true

	return exito


func puede_colocar(objeto: Movil = null) -> bool:
	return !dispensador and objeto != null and objeto is Recipiente and marker.get_child_count() == 0 and _nombre_aceptado(objeto)


func _nombre_aceptado(objeto: Movil) -> bool:
	var aceptado = objeto.info != null and objeto.info.nombre in nombres_aceptados
	if nombres_aceptados.is_empty():
		aceptado = true
	return aceptado


func obtener_objeto() -> Movil:
	var objeto = null
	if !dispensador and marker.get_child_count() > 0:
		objeto = marker.get_child(0) as Movil
	return objeto


func recibir_interaccion(objeto: Node3D = null) -> bool:
	var exito := false
	
	if objeto == null:
		if dispensador:
			exito = (dispensar() != null)
	
	else:
		var recipiente := obtener_objeto() as Recipiente
		if recipiente != null and recipiente.recibir_interaccion(objeto):
			exito = true

	return exito


func interactuar(objeto: Node3D = null):
	var recipiente := obtener_objeto() as Recipiente
	if recipiente != null:
		recipiente.interactuar(objeto)


func dispensar() -> Movil:
	var copia : Movil = null

	if dispensador:
		copia = contenido.instantiate() as Movil
		get_parent().add_child(copia)
		copia.global_transform = marker.global_transform
		copia.padre_original = get_parent()
		objeto_dispensado = copia
		Gestor.emitir(Evento.Tipo.DISPENSAR, copia, self, null)

	return copia


func puede_recibir(objeto: Node3D = null) -> bool:
	var exito := false

	var recipiente := obtener_objeto() as Recipiente
	if recipiente != null:
		exito = recipiente.puede_recibir(objeto)

	return exito


func texto_interaccion(objeto: Node3D = null) -> String:
	var texto := ""

	if objeto == null:
		if dispensador:
			texto = "Extraer"

	else:
		var recipiente := obtener_objeto() as Recipiente
		if recipiente != null and recipiente.has_method("texto_interaccion"):
			texto = recipiente.texto_interaccion(objeto)

	return texto
