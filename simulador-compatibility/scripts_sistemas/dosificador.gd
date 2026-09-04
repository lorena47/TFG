class_name Dosificador
extends Instrumento

var sustancia: Sustancia = null
@onready var liquido = get_parent().get_parent().get_node_or_null("contenedor/liquido")

@onready var echar = get_parent().get_node_or_null("echar")
@export var duracion_caida := 0.4


func _ready():
	if liquido != null:
		liquido.visible = false


func recibir_interaccion(objeto: Movil = null) -> bool:
	var exito := false

	if objeto == null:
		var activando := !interaccionado
		if activando and sustancia != null:
			var objeto_colocado := obtener_objeto()
			if objeto_colocado != null:
				_dispensar(objeto_colocado)

		exito = await super.recibir_interaccion(objeto)

	elif objeto is Sustancia:
		if objeto.fluido:
			sustancia = objeto
			if liquido != null:
				liquido.visible = true
				var material = objeto.obtener_material()
				if material != null:
					liquido.set_surface_override_material(0, material.duplicate())
					if echar != null:
						echar.set_surface_override_material(0, material.duplicate())
				exito = true

	else:
		exito = await super.recibir_interaccion(objeto)

	return exito


func _dispensar(objeto_colocado: Movil):
	await _animar_caida()
	if objeto_colocado.recibir_interaccion(sustancia):
		Gestor.emitir(Evento.Tipo.VERTER, self, null, objeto_colocado)


func _animar_caida():
	if echar != null:

		var escala_inicial: Vector3 = echar.scale

		echar.visible = true
		echar.scale = escala_inicial

		var tween := create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(echar, "scale:y", 0.0, duracion_caida)
		await tween.finished

		echar.visible = false
		echar.scale = escala_inicial


func texto_sustancias() -> String:
	if sustancia == null:
		return ""
	return "- " + sustancia.info.nombre
 
 
func texto_ingredientes() -> String:
	return "Ver sustancia"


func texto_interaccion(objeto: Movil = null) -> String:
	var texto := ""
	if objeto is Sustancia and objeto.fluido:
		texto = "Cambiar sustancia"
	else:
		texto = super.texto_interaccion(objeto)
	return texto
