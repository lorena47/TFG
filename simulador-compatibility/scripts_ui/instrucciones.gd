class_name NotaInstrucciones
extends Control

@export var proporcion_tamanio := 0.4
@export var proporcion_alto := 1.6
@export var tamanio_maximo := 340.0
@export var proporcion_margen := 0.09

var tamanio := Vector2(260, 416)
var margen := Vector2(24, 24)
var indice_grupo := 1

@onready var _lista: ListaPasos = $ListaPasos
@onready var _paginador: HBoxContainer = $Paginador
@onready var _indicador_izq: Label = $Paginador/Izquierda
@onready var _etiqueta_paginador: Label = $Paginador/Numero
@onready var _indicador_der: Label = $Paginador/Derecha
@onready var _etiqueta_hito: Label = $Hito


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	anchor_left = 1.0
	anchor_right = 1.0
	anchor_top = 0.0
	anchor_bottom = 0.0

	get_viewport().size_changed.connect(_actualizar_layout)
	_actualizar_layout()
	_refrescar_paginador()


func avanzar_grupo() -> void:
	var total := _grupos_totales()
	if total != 0:
		if indice_grupo < total:
			indice_grupo += 1
			_refrescar_paginador()


func retroceder_grupo() -> void:
	if indice_grupo > 1:
		indice_grupo -= 1
		_refrescar_paginador()


func _refrescar_paginador() -> void:
	var total := _grupos_totales()
	if total == 0:
		_paginador.visible = false
		_etiqueta_hito.visible = false
	else:
		indice_grupo = clamp(indice_grupo, 1, total)
		_paginador.visible = true
		_etiqueta_paginador.text = "%d/%d" % [indice_grupo, total]

		_etiqueta_hito.visible = true
		_etiqueta_hito.text = "HITO %d" % indice_grupo

		_indicador_izq.modulate.a = (1.0 if indice_grupo > 1 else 0.0)
		_indicador_der.modulate.a = (1.0 if indice_grupo < total else 0.0)

	if _lista != null:
		_lista.actualizar()


func _grupos_totales() -> int:
	var experimento := Gestor.experimento
	var maximo := 0
	if experimento != null:
		for id in experimento.hitos.keys():
			var g := experimento.grupo_hito(id)
			if g != "":
				maximo = max(maximo, int(g))
	return maximo


func grupo_mostrado() -> String:
	if _grupos_totales() == 0:
		return ""
	return str(indice_grupo)


func _actualizar_layout() -> void:
	var tam_ventana := get_viewport_rect().size
	var lado = min(min(tam_ventana.x, tam_ventana.y) * proporcion_tamanio, tamanio_maximo)
	tamanio = Vector2(lado, lado * proporcion_alto)
	margen = Vector2(lado, lado) * proporcion_margen
	offset_left = -tamanio.x - margen.x
	offset_right = -margen.x
	offset_top = margen.y
	offset_bottom = margen.y + tamanio.y
