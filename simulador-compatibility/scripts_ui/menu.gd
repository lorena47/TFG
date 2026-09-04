extends Control

enum Modo {GUIADO, EVALUACION}

@onready var panel_principal: Control = $PanelPrincipal
@onready var panel_creditos: Control = $PanelCreditos
@onready var panel_pausa: Control = $PanelPausa
@onready var panel_enhorabuena: Control = $PanelEnhorabuena
@onready var panel_resultado: Control = $PanelResultado
@onready var label_puntuacion: Label = $PanelResultado/CenterContainer/MarginContainer/VBoxContainer/Label2
@onready var ui_juego := get_tree().current_scene.get_node("ui")

var jugando := false
var modo := Modo.GUIADO
var _panel_pausando := false


func _ready() -> void:
	Gestor.reiniciar()
	Gestor.experimento_finalizado.connect(_on_experimento_finalizado)
	mostrar_panel(panel_principal)


func _unhandled_input(event: InputEvent) -> void:
	if jugando and event.is_action_pressed("menu"):
		alternar_pausa()


func mostrar_panel(panel: Control) -> void:
	self.visible = panel != null
	panel_principal.visible = panel == panel_principal
	panel_creditos.visible = panel == panel_creditos
	panel_pausa.visible = panel == panel_pausa
	panel_resultado.visible = panel == panel_resultado
	panel_enhorabuena.visible = panel == panel_enhorabuena
	ui_juego.visible = panel == null
 
	var debe_pausar := panel != null
	if debe_pausar and !_panel_pausando:
		Gestor.pausar()
	elif !debe_pausar and _panel_pausando:
		Gestor.reanudar()
	_panel_pausando = debe_pausar
 
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if panel != null else Input.MOUSE_MODE_CAPTURED)


func alternar_pausa() -> void:
	if panel_pausa.visible:
		_on_button_reanudar_pressed()
	else:
		mostrar_panel(panel_pausa)
		ui_juego.visible = false


func _empezar(modo_elegido: int) -> void:
	modo = modo_elegido
	jugando = true
	mostrar_panel(null)
	ui_juego.visible = true
	ui_juego.alternar_instrucciones(modo == Modo.GUIADO)


func _on_button_jugar_pressed() -> void:
	_empezar(Modo.GUIADO)


func _on_button_evaluar_pressed() -> void:
	_empezar(Modo.EVALUACION)


func _on_button_cred_pressed() -> void:
	mostrar_panel(panel_creditos)


func _on_button_volver_pressed() -> void:
	mostrar_panel(panel_principal)


func _on_button_reanudar_pressed() -> void:
	mostrar_panel(null)
	ui_juego.visible = true


func _on_button_fin_pressed() -> void:
	if modo == Modo.EVALUACION:
		_mostrar_resultado(Gestor.finalizar_experimento_manual())
	else:
		get_tree().reload_current_scene()


func _on_button_volver_inicio_pressed() -> void:
	get_tree().reload_current_scene()


func _on_experimento_finalizado() -> void:
	if !jugando:
		return
	if modo == Modo.EVALUACION:
		_mostrar_resultado(Gestor.experimento.puntuacion)
	else:
		_mostrar_pantalla_final(panel_enhorabuena)


func _mostrar_resultado(puntuacion: float) -> void:
	label_puntuacion.text = "Puntuación: %.2f / 100" % puntuacion
	_mostrar_pantalla_final(panel_resultado)


func _mostrar_pantalla_final(panel: Control) -> void:
	jugando = false
	ui_juego.visible = false
	mostrar_panel(panel)
