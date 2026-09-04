extends CanvasLayer

@onready var puntero = $puntero
@onready var apuntado = $apuntado
@onready var instrucciones: NotaInstrucciones = $Instrucciones
@onready var acciones = $acciones
@onready var cuaderno: Cuaderno = $Cuaderno
@onready var errores: PanelErrores = $Errores


func set_puntero(activo: bool):

	if activo:
		puntero.add_theme_color_override(
			"font_color",
			Color.DODGER_BLUE
		)
	else:
		puntero.add_theme_color_override(
			"font_color",
			Color.BLACK
		)


func mostrar_apuntado(nombre: String) -> void:
	apuntado.text = nombre


func avanzar_instrucciones() -> void:
	instrucciones.avanzar_grupo()


func retroceder_instrucciones() -> void:
	instrucciones.retroceder_grupo()


const ICONOS_BOTON := {
	"pick": preload("res://iconos/click_izq.png"),
	"interactuar": preload("res://iconos/click_dch.png"),
	"tirar": preload("res://iconos/tecla_x.png"),
	"puertas": preload("res://iconos/tecla_espacio.png"),
	"ingredientes": preload("res://iconos/tecla_n.png"),
}
 
 
func mostrar_acciones(lista: Array[Dictionary]) -> void:
	acciones.clear()
	acciones.visible = !lista.is_empty()
 
	for accion in lista:
		if accion["texto"] != "":
			var icono: Texture2D = ICONOS_BOTON.get(accion["boton"])
			if icono != null:
				acciones.add_image(icono, 40, 40)
				acciones.add_text("  ")
			acciones.add_text(accion["texto"])
			acciones.newline()


func alternar_cuaderno(objeto: Node) -> void:
	if cuaderno.visible:
		cuaderno.ocultar()
	else:
		cuaderno.mostrar(objeto)
 
 
func desplazar_scroll_cuaderno(direccion: int = 1) -> void:
	cuaderno.desplazar_scroll(direccion)


func desplazar_scroll_errores(direccion: int = 1) -> void:
	errores.desplazar_scroll(direccion)


func alternar_instrucciones(visible_instrucciones: bool) -> void:
	instrucciones.visible = visible_instrucciones
