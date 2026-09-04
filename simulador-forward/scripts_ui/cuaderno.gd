class_name Cuaderno
extends Control

@export var paso_scroll := 60.0

@onready var _titulo: RichTextLabel = $Papel/Contenido/Titulo
@onready var _scroll: ScrollContainer = $Papel/Contenido/Scroll
@onready var _lista: Label = $Papel/Contenido/Scroll/Lista
@onready var _boton_cerrar: Button = $Papel/ButtonCerrar


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	process_mode = Node.PROCESS_MODE_ALWAYS

	_boton_cerrar.pressed.connect(ocultar)
	visible = false


func mostrar(objeto: Node) -> void:
	if objeto != null and objeto.has_method("texto_sustancias"):

		var nombre := "Sin nombre"
		if "info" in objeto and objeto.info != null:
			nombre = objeto.info.nombre

		_titulo.text = "[u]" + nombre.replace("[", "[lb]") + "[/u]"

		var texto: String = objeto.texto_sustancias()
		_lista.text = texto if texto != "" else "(sin sustancias)"
		_scroll.scroll_vertical = 0

		visible = true
		Gestor.pausar()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func ocultar() -> void:
	visible = false
	Gestor.reanudar()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func desplazar_scroll(direccion: int = 1) -> void:
	if visible:
		_scroll.scroll_vertical += int(paso_scroll) * direccion
