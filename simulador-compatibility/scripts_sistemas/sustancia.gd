class_name Sustancia
extends Movil

var abierta := false

@onready var tapa = $modelo/cuerpo/tapa
var posicion_tapa : Vector3

@onready var contenido = get_node_or_null("modelo/cuerpo/contenido")
@onready var liquido = get_node_or_null("modelo/cuerpo/liquido")
@export var fluido := false


func _ready():
	super()
	posicion_tapa = tapa.position


func obtener_material() -> Material:
	var nodo = liquido if fluido else contenido
	if nodo != null and nodo.has_method("get_active_material"):
		return nodo.get_active_material(0)
	return null


func obtener_color() -> Variant:
	var material := obtener_material()
	if material == null:
		return null
	return material.get("albedo_color")


func interactuar(objeto: Node3D = null):
	if objeto is Recipiente or objeto is Instrumento or objeto is Contenedor:
		if await objeto.recibir_interaccion(self):
			Gestor.emitir(Evento.Tipo.VERTER, self, null, objeto)


func recibir_interaccion(objeto: Node3D = null) -> bool:
	var exito = false

	if objeto == null:
		if !fluido:
			if abierta:
				abierta = false
				_animar_cierre()
			else:
				abierta = true
				_animar_apertura()

			Gestor.emitir(Evento.Tipo.INTERACTUAR, self, null, null, {"abierta": abierta})
			exito = true

	elif objeto is Utensilio:
		if fluido or abierta:
			exito = true

	return exito


func _animar_apertura():

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.parallel().tween_property(
		tapa,
		"position",
		posicion_tapa + tapa.transform.basis.y * 1,
		0.35
	)

	await tween.finished
	tapa.visible = false
	
func _animar_cierre():

	tapa.visible = true
	tapa.position = posicion_tapa + tapa.transform.basis.y * 1

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		tapa,
		"position",
		posicion_tapa,
		0.35
	)

	await tween.finished


func texto_interaccion(objeto: Node3D = null) -> String:
	if objeto == null:
		if !fluido:
			return "Cerrar" if abierta else "Abrir"
		return ""

	if objeto is Instrumento and objeto.has_method("texto_interaccion"):
		var texto: String = objeto.texto_interaccion(self)
		if texto != "":
			return texto

	if objeto.has_method("puede_recibir") and objeto.puede_recibir(self):
		return "Verter"

	return ""


func puede_recibir(objeto: Node3D = null) -> bool:
	return fluido or abierta
