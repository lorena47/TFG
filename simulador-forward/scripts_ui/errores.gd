class_name PanelErrores
extends Control

@export var ruta_nota: NodePath
@export var separacion_bajo_nota := 0.06
@export var proporcion_alto := 0.35
@export var max_errores_mostrados := 4

@export var proporcion_fuente := 0.045
@export var fuente_maxima := 15

@onready var _nota: NotaInstrucciones = get_node_or_null(ruta_nota) as NotaInstrucciones
@onready var _contenedor: VBoxContainer = $MarginContainer/ScrollContainer/VBoxContainer
@onready var _etiqueta_vacia: Label = $MarginContainer/ScrollContainer/VBoxContainer/Label
@onready var _plantilla_fila: HBoxContainer = $FilaError

@onready var _scroll: ScrollContainer = $MarginContainer/ScrollContainer
@export var paso_scroll := 60.0


var _lineas: Array[Node] = []
var tamanio_fuente := 13


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	anchor_left = 1.0
	anchor_right = 1.0
	anchor_top = 0.0
	anchor_bottom = 0.0

	if _nota != null:
		_nota.resized.connect(_actualizar_layout)
		_nota.visibility_changed.connect(_actualizar_layout)

	Gestor.evento_recibido.connect(_al_evento)
	_actualizar_layout()


func _al_evento(_evento: Evento) -> void:
	actualizar()


func _actualizar_layout() -> void:

	if _nota != null:
		var lado := _nota.tamanio.x
		offset_left = _nota.offset_left
		offset_right = _nota.offset_right

		if _nota.visible:
			offset_top = _nota.offset_bottom + lado * separacion_bajo_nota
		else:
			offset_top = _nota.offset_top

		offset_bottom = offset_top + lado * proporcion_alto
		tamanio_fuente = int(min(lado * proporcion_fuente, fuente_maxima))
		actualizar()


func actualizar() -> void:
	for linea in _lineas:
		linea.queue_free()
	_lineas.clear()

	var experimento := Gestor.experimento
	var mensajes: Array = experimento.errores_activos() if experimento != null else []

	_etiqueta_vacia.visible = mensajes.is_empty()

	if !mensajes.is_empty():
		var recientes: Array = mensajes.slice(max(0, mensajes.size() - max_errores_mostrados), mensajes.size())
		recientes.reverse()
		for m in recientes:
			_aniadir_linea(m)


func _aniadir_linea(texto: String) -> void:
	var fila := _plantilla_fila.duplicate()
	fila.visible = true

	var icono: TextureRect = fila.get_node("Icono")
	icono.custom_minimum_size = Vector2(tamanio_fuente * 2, tamanio_fuente * 2)

	var etiqueta: Label = fila.get_node("Texto")
	etiqueta.text = texto
	etiqueta.add_theme_font_size_override("font_size", tamanio_fuente)

	_contenedor.add_child(fila)
	_lineas.append(fila)


func desplazar_scroll(direccion: int = 1) -> void:
	_scroll.scroll_vertical += int(paso_scroll) * direccion
