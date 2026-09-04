class_name Utensilio
extends Movil

var sustancia : Sustancia = null

@onready var contenido = $modelo/cuerpo/contenido
var cantidad_contenido : int = 0
@export var CANTIDAD_MAXIMA_CONTENIDO : int = 1
@export var incremento : float = 0.1
var escala_contenido : Vector3
@export var fluido := false

var vacio := true

func _ready():
	super()
	escala_contenido = contenido.scale
	contenido.visible = false


func interactuar(objeto: Node3D = null):

	if objeto is Sustancia:
		if fluido == objeto.fluido:
			if objeto.recibir_interaccion(self) and cantidad_contenido < CANTIDAD_MAXIMA_CONTENIDO:
				if cantidad_contenido == 0:
					contenido.visible = true
					contenido.scale = escala_contenido
				else:
					contenido.scale += escala_contenido * incremento

				sustancia = objeto
				var material = objeto.obtener_material()
				if material != null and contenido.has_method("set_surface_override_material"):
					contenido.set_surface_override_material(0, material.duplicate())

				cantidad_contenido += 1
				vacio = false
				Gestor.emitir(Evento.Tipo.VERTER, objeto, null, self)

	elif objeto is Recipiente or objeto is Instrumento or objeto is Contenedor:
		if !vacio:
			if await objeto.recibir_interaccion(self):
				Gestor.emitir(Evento.Tipo.VERTER, self, null, objeto)
				vaciar()


func vaciar():

	cantidad_contenido = 0
	sustancia = null
	contenido.scale = escala_contenido
	contenido.visible = false
	if contenido.has_method("set_surface_override_material"):
		contenido.set_surface_override_material(0, null)
	vacio = true

	Gestor.emitir(Evento.Tipo.VACIAR, self)


func texto_vaciar() -> String:
	if vacio:
		return ""
	return "Vaciar"


func texto_interaccion(objeto: Node3D = null) -> String:
	if objeto is Sustancia:
		if fluido == objeto.fluido and cantidad_contenido < CANTIDAD_MAXIMA_CONTENIDO:
			if objeto.puede_recibir(self):
				return "Extraer"
	elif objeto is Recipiente or objeto is Instrumento or objeto is Contenedor:
		if !vacio and objeto.has_method("puede_recibir") and objeto.puede_recibir(self):
			return "Verter"
	return ""
