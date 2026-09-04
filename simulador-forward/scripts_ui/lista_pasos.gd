class_name ListaPasos
extends VBoxContainer

@onready var _nota: NotaInstrucciones = get_parent() as NotaInstrucciones

@onready var _plantilla_pendiente: HBoxContainer = $"../FilaPendiente"
@onready var _plantilla_bloqueada: HBoxContainer = $"../FilaBloqueada"
@onready var _plantilla_completada: HBoxContainer = $"../FilaCompletada"

@export var proporcion_margen_izq_der := 0.069
@export var proporcion_margen_superior := 0.33
@export var proporcion_margen_inferior := 0.062
@export var proporcion_separacion_items := 0.038
@export var proporcion_separacion_interna := 0.046
@export var proporcion_fuente := 0.05
@export var proporcion_casilla := 0.062

@export var proporcion_ajuste_vertical := -0.32
@export var factor_sangria := 1.4

@export var fuente_maxima := 16
@export var casilla_maxima := 20.0

var tamanio_fuente := 13
var tamanio_casilla := 16.0
var separacion_interna := 12.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 0.0
	anchor_bottom = 1.0

	if _nota != null:
		_nota.resized.connect(_actualizar_layout)

	_actualizar_layout()
	Gestor.evento_recibido.connect(_al_evento)
	actualizar()


func _actualizar_layout() -> void:
	if _nota != null:
		var lado = _nota.tamanio.x
		offset_left = lado * proporcion_margen_izq_der
		offset_right = -lado * proporcion_margen_izq_der
		offset_top = lado * proporcion_margen_superior
		offset_bottom = -lado * proporcion_margen_inferior
		add_theme_constant_override("separation", int(lado * proporcion_separacion_items))
		tamanio_fuente = int(min(lado * proporcion_fuente, fuente_maxima))
		tamanio_casilla = min(lado * proporcion_casilla, casilla_maxima)
		separacion_interna = lado * proporcion_separacion_interna
		actualizar()


func _al_evento(_evento: Evento) -> void:
	actualizar()


func actualizar() -> void:
	for hijo in get_children():
		hijo.queue_free()

	var experimento := Gestor.experimento
	if experimento != null:
		var grupo_filtro: String = (_nota.grupo_mostrado() if _nota != null else "")
		for id in experimento.hitos.keys():
			var sin_padre_visual := experimento.padre_visual_hito(id) == ""
			var en_grupo := grupo_filtro == "" or experimento.grupo_hito(id) == grupo_filtro
			if sin_padre_visual and en_grupo:
				add_child(_construir_bloque_hito(experimento, id, false))


func _construir_bloque_hito(experimento: Experimento, id: String, heredado_bloqueado: bool) -> Control:
	var alcanzado: bool = experimento.hito_alcanzado(id)
	var bloqueado: bool = (heredado_bloqueado or (
			!alcanzado and !experimento.requisitos_pendientes(id).is_empty())
		)

	var bloque := VBoxContainer.new()
	bloque.add_theme_constant_override("separation", int(separacion_interna))
	var texto := experimento.descripcion_hito(id)
	bloque.add_child(_crear_fila(texto, alcanzado, bloqueado))

	var hijos_visuales: Array = experimento.subpasos_visuales(id)
	if !hijos_visuales.is_empty():
		var subcontenedor_visual := VBoxContainer.new()
		subcontenedor_visual.add_theme_constant_override("separation", int(separacion_interna * 0.7))

		for id_hijo in hijos_visuales:
			subcontenedor_visual.add_child(_construir_bloque_hito(experimento, id_hijo, bloqueado))

		var sangria_visual := MarginContainer.new()
		sangria_visual.add_theme_constant_override("margin_left", int(tamanio_casilla * factor_sangria))
		sangria_visual.add_child(subcontenedor_visual)
		bloque.add_child(sangria_visual)

	return bloque


func _crear_fila(texto: String, completado: bool, bloqueado: bool) -> Control:
	var plantilla := _plantilla_pendiente
	if completado:
		plantilla = _plantilla_completada
	elif bloqueado:
		plantilla = _plantilla_bloqueada

	var fila: HBoxContainer = plantilla.duplicate()
	fila.visible = true
	fila.add_theme_constant_override("separation", int(separacion_interna))

	var casilla: Control = fila.get_node("Casilla")
	casilla.custom_minimum_size = Vector2(tamanio_casilla, tamanio_casilla)

	var margen: MarginContainer = fila.get_node("Margen")
	margen.add_theme_constant_override("margin_top", int(tamanio_fuente * proporcion_ajuste_vertical))

	if completado:
		var txt: RichTextLabel = margen.get_node("Texto")
		txt.text = ("[s]" + texto.replace("[", "[lb]") + "[/s]")
		txt.add_theme_font_size_override("normal_font_size", tamanio_fuente)
	else:
		var etiqueta: Label = margen.get_node("Descripcion")
		etiqueta.text = texto
		etiqueta.add_theme_font_size_override("font_size", tamanio_fuente)

	return fila
