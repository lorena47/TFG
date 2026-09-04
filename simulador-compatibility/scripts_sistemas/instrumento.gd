class_name Instrumento
extends StaticBody3D

@export var info: Informacion

@onready var marker = get_node_or_null("Marker3D")

var interaccionado := false
@export var texto_activar := ""
@export var texto_desactivar := ""

@onready var animacion := get_parent().get_parent().get_node_or_null("AnimationPlayer") as AnimationPlayer
@export var nombre_animacion := ""

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
	return objeto != null and marker != null and marker.get_child_count() == 0 and _nombre_aceptado(objeto)


func _nombre_aceptado(objeto: Movil) -> bool:
	var aceptado = objeto.info != null and objeto.info.nombre in nombres_aceptados
	if nombres_aceptados.is_empty():
		aceptado = true
	return aceptado


func obtener_objeto() -> Movil:
	var objeto = null
	if marker != null and marker.get_child_count() > 0:
		objeto = marker.get_child(0) as Movil
	return objeto
	

func recibir_interaccion(objeto: Movil = null) -> bool:
	var exito = false
	
	if objeto == null:
		if animacion != null and nombre_animacion != "":
			animacion.process_mode = Node.PROCESS_MODE_ALWAYS
 
			if interaccionado:
				animacion.play_backwards(nombre_animacion)
			else:
				animacion.play(nombre_animacion)
			interaccionado = !interaccionado
 
			Gestor.emitir(
				Evento.Tipo.INTERACTUAR, self, null, null,
				{
					"activo": interaccionado,
					"contenido": obtener_objeto()
				}
			)
 
			Gestor.pausar()
			await animacion.animation_finished
			Gestor.reanudar()
 
			exito = true
	else:
		var objeto_colocado := obtener_objeto()
		if objeto_colocado != null and objeto_colocado.recibir_interaccion(objeto):
			exito = true
 
	return exito


func puede_recibir(objeto: Movil = null) -> bool:
	var exito := false

	var objeto_colocado := obtener_objeto()
	if objeto_colocado != null and objeto_colocado.has_method("puede_recibir"):
		exito = objeto_colocado.puede_recibir(objeto)

	return exito


func texto_interaccion(objeto: Movil = null) -> String:
	var texto := ""
	if objeto == null:
		if animacion != null:
			texto = texto_desactivar if interaccionado else texto_activar
	return texto
