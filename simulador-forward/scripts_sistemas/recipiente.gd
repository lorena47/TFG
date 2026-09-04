class_name Recipiente
extends Movil

@onready var marker = get_node_or_null("Marker3D")

var sustancias := []
@export var fluido := false
@export var solido := false
@export var deforme := false

@onready var contenido = get_node_or_null("modelo/cuerpo/contenido")
var cantidad_contenido : float = 0.0
@export var CANTIDAD_MAXIMA_CONTENIDO : float = 1.0
var escala_contenido: Vector3

@onready var base = get_node_or_null("modelo/cuerpo/base")
@onready var liquido = get_node_or_null("modelo/cuerpo/liquido")
var cantidad_liquido := 0.0
@export var CANTIDAD_MAXIMA_LIQUIDO := 1.0
var escala_liquido: Vector3
@export var eje_escala_liquido := Vector3(0, 0, 1)
var shape_key_liquido: float

var contaminado := false
@onready var particulas_contaminacion: CPUParticles3D = get_node_or_null("particulas")


func _ready():
	super()

	if contenido != null:
		escala_contenido = contenido.scale
		contenido.visible = false
	
	if base != null:
		base.visible = false

	if liquido != null:
		escala_liquido = liquido.scale
		if deforme:
			shape_key_liquido = 1.0 / CANTIDAD_MAXIMA_LIQUIDO
			liquido.visible = false


func registrar_sustancia(sustancia: Node3D):

	var es_fluido: bool = sustancia is Sustancia and sustancia.fluido
	var color = sustancia.obtener_color() if sustancia is Sustancia else null

	if sustancias.is_empty():
		sustancias.append({
			"sustancia": sustancia,
			"nombre": sustancia.info.nombre,
			"veces": 1,
			"fluido": es_fluido,
			"color": color,
		})

	else:
		var ultima: Dictionary = sustancias.back()
		if ultima["nombre"] == sustancia.info.nombre:
			ultima["veces"] += 1
		else:
			sustancias.append({
				"sustancia": sustancia,
				"nombre": sustancia.info.nombre,
				"veces": 1,
				"fluido": es_fluido,
				"color": color,
			})

	if sustancia is Sustancia:
		_actualizar_material(sustancia, es_fluido)


func aceptar_sustancias(recipiente: Recipiente):
	var en_marker: Node3D = null
	if recipiente.marker != null and recipiente.marker.get_child_count() > 0:
		en_marker = recipiente.marker.get_child(0)

	for entrada: Dictionary in recipiente.sustancias:
		for i in entrada["veces"]:
			if en_marker != null and entrada["sustancia"] == en_marker:
				continue
			if is_instance_valid(entrada["sustancia"]):
				registrar_sustancia(entrada["sustancia"])
			else:
				_registrar_por_nombre(entrada["nombre"])


func _registrar_por_nombre(nombre_sustancia: String):
	if sustancias.is_empty():
		sustancias.append({"sustancia": null, "nombre": nombre_sustancia, "veces": 1})
	else:
		var ultima: Dictionary = sustancias.back()
		if ultima["nombre"] == nombre_sustancia:
			ultima["veces"] += 1
		else:
			sustancias.append({"sustancia": null, "nombre": nombre_sustancia, "veces": 1})


func interactuar(objeto: Node3D = null):
	if objeto is Recipiente or objeto is Instrumento or objeto is Contenedor:
		if await objeto.recibir_interaccion(self):
			_transferir_marker(objeto)
			Gestor.emitir(Evento.Tipo.VERTER, self, null, objeto)
			vaciar()


func recibir_interaccion(objeto: Node3D = null) -> bool:
	var exito = false
 
	if objeto != null:
 
		if objeto is Sustancia:
			if objeto.fluido and fluido:
				if cantidad_liquido + 1.0 <= CANTIDAD_MAXIMA_LIQUIDO:
					_aniadir_liquido(1.0)
					registrar_sustancia(objeto)
					exito = true
 
		elif objeto is Utensilio:
			if objeto.cantidad_contenido > 0:
				if objeto.fluido:
					if fluido:
						var cantidad_recibida = float(objeto.cantidad_contenido) / objeto.CANTIDAD_MAXIMA_CONTENIDO
						if cantidad_liquido + cantidad_recibida <= CANTIDAD_MAXIMA_LIQUIDO:
							_aniadir_liquido(cantidad_recibida)
							registrar_sustancia(objeto.sustancia)
							exito = true
				else:
					if solido:
						var cantidad_recibida = float(objeto.cantidad_contenido) / objeto.CANTIDAD_MAXIMA_CONTENIDO
						if cantidad_contenido + cantidad_recibida <= CANTIDAD_MAXIMA_CONTENIDO:
							registrar_sustancia(objeto.sustancia)

							if cantidad_contenido == 0:
								contenido.scale = escala_contenido
							else:
								contenido.scale += escala_contenido * cantidad_recibida

							cantidad_contenido += cantidad_recibida
							contenido.visible = true
							exito = true
					elif fluido and cantidad_liquido > 0:
						registrar_sustancia(objeto.sustancia)
						exito = true
 
		elif objeto is Recipiente:
			var origen_tiene_dispensado = objeto.marker != null and objeto.marker.get_child_count() > 0

			if objeto.cantidad_liquido > 0 or objeto.cantidad_contenido > 0 or origen_tiene_dispensado:

				var puede_liquido := true
				if objeto.cantidad_liquido > 0:
					puede_liquido = fluido and cantidad_liquido + objeto.cantidad_liquido <= CANTIDAD_MAXIMA_LIQUIDO

				var puede_solido := true
				if objeto.cantidad_contenido > 0:
					if solido:
						puede_solido = cantidad_contenido + objeto.cantidad_contenido <= CANTIDAD_MAXIMA_CONTENIDO
					else:
						puede_solido = objeto.cantidad_liquido > 0 or cantidad_liquido > 0

				if puede_liquido and puede_solido:
					aceptar_sustancias(objeto)

					if objeto.cantidad_liquido > 0:
						_aniadir_liquido(objeto.cantidad_liquido)

					if objeto.cantidad_contenido > 0:
						cantidad_contenido += objeto.cantidad_contenido
						if solido:
							contenido.scale = escala_contenido * cantidad_contenido
							contenido.visible = true

					exito = true
 
		elif objeto is Dispensado:
			if marker != null:
				objeto.cambiar_padre(marker)
				objeto.escalar_original(marker.global_basis.get_scale())
				registrar_sustancia(objeto)
				
				exito = true
 
	mezclar()
	return exito


func _aniadir_liquido(cantidad: float):
	cantidad_liquido += cantidad
 
	if base != null:
		base.visible = true
 
	if liquido != null and cantidad_liquido > 1.0:
		liquido.visible = true
		if deforme:
			liquido.set(
				"blend_shapes/Empty",
				1.0 - (cantidad_liquido - 1.0) * shape_key_liquido
			)
		else:
			liquido.scale = escala_liquido + eje_escala_liquido * (cantidad_liquido - 1.0)


func mezclar():
	if cantidad_liquido > 0:
		if contenido != null:
			contenido.visible = false
		_vaciar_marker()


func vacio() -> bool:
	return sustancias.is_empty()


func vaciar():
	descontaminar()
	sustancias = []

	cantidad_contenido = 0.0
	if contenido != null:
		contenido.scale = escala_contenido
		contenido.visible = false
		if contenido.has_method("set_surface_override_material"):
			contenido.set_surface_override_material(0, null)

	cantidad_liquido = 0
	if base != null:
		base.visible = false
		if base.has_method("set_surface_override_material"):
			base.set_surface_override_material(0, null)
	if liquido != null:
		liquido.visible = false
		if liquido.has_method("set_surface_override_material"):
			liquido.set_surface_override_material(0, null)
		if deforme:
			liquido.set("blend_shapes/Empty", 1.0)
		else:
			liquido.scale = escala_liquido

	_vaciar_marker()
	Gestor.emitir(Evento.Tipo.VACIAR, self)


func _transferir_marker(destino: Node3D):
	if marker != null and marker.get_child_count() > 0:
		var objeto_colocado := marker.get_child(0) as Movil

		if objeto_colocado != null:
			var transferido := false
			if objeto_colocado is Recipiente and destino.has_method("colocar"):
				transferido = destino.colocar(objeto_colocado)
			if not transferido and objeto_colocado is Dispensado and destino.has_method("recibir_interaccion"):
				transferido = await destino.recibir_interaccion(objeto_colocado)
			if not transferido:
				objeto_colocado.queue_free()


func _vaciar_marker():
	if marker != null:
		for hijo in marker.get_children():
			hijo.queue_free()


func mezcla() -> Array[Dictionary]:
	var salida: Array[Dictionary] = []
	for entrada: Dictionary in sustancias:
		salida.append({
			"nombre": entrada["nombre"],
			"veces": entrada["veces"]
		})
	return salida


func texto_vaciar() -> String:
	if sustancias.is_empty():
		return ""
	return "Vaciar"


func puede_recibir(objeto: Node3D = null) -> bool:
	var exito := false

	if objeto != null:

		if objeto is Sustancia:
			exito = objeto.fluido and fluido and cantidad_liquido + 1.0 <= CANTIDAD_MAXIMA_LIQUIDO

		elif objeto is Utensilio:
			if objeto.cantidad_contenido > 0:
				if objeto.fluido:
					if fluido:
						var cantidad_recibida = float(objeto.cantidad_contenido) / objeto.CANTIDAD_MAXIMA_CONTENIDO
						exito = cantidad_liquido + cantidad_recibida <= CANTIDAD_MAXIMA_LIQUIDO
				else:
					if solido:
						var cantidad_recibida = float(objeto.cantidad_contenido) / objeto.CANTIDAD_MAXIMA_CONTENIDO
						exito = cantidad_contenido + cantidad_recibida <= CANTIDAD_MAXIMA_CONTENIDO
					elif fluido and cantidad_liquido > 0:
						exito = true

		elif objeto is Recipiente:
			var origen_tiene_dispensado = objeto.marker != null and objeto.marker.get_child_count() > 0

			if objeto.cantidad_liquido > 0 or objeto.cantidad_contenido > 0 or origen_tiene_dispensado:
				var puede_liquido := true
				if objeto.cantidad_liquido > 0:
					puede_liquido = fluido and cantidad_liquido + objeto.cantidad_liquido <= CANTIDAD_MAXIMA_LIQUIDO

				var puede_solido := true
				if objeto.cantidad_contenido > 0:
					if solido:
						puede_solido = cantidad_contenido + objeto.cantidad_contenido <= CANTIDAD_MAXIMA_CONTENIDO
					else:
						puede_solido = objeto.cantidad_liquido > 0 or cantidad_liquido > 0

				exito = puede_liquido and puede_solido

		elif objeto is Dispensado:
			exito = marker != null

	return exito


func texto_interaccion(objeto: Node3D = null) -> String:
	if objeto is Recipiente or objeto is Instrumento or objeto is Contenedor:
		if objeto.has_method("puede_recibir") and objeto.puede_recibir(self):
			return "Verter"

	return ""


func texto_sustancias() -> String:
	var lineas := []
	for entrada: Dictionary in mezcla():
		lineas.append("- " + entrada["nombre"])
	return "\n".join(lineas)
 
 
func texto_ingredientes() -> String:
	return "Ver sustancias"


func _actualizar_material(sustancia: Sustancia, es_fluido: bool) -> void:
	var material := sustancia.obtener_material()

	if material != null:
		if es_fluido:
			if liquido != null and liquido.has_method("set_surface_override_material"):
				var mezcla: Material = material.duplicate()
				var color_mezcla = _color_liquido_mezclado()
				if color_mezcla != null:
					mezcla.set("albedo_color", color_mezcla)
				liquido.set_surface_override_material(0, mezcla)
				if base != null and base.has_method("set_surface_override_material"):
					base.set_surface_override_material(0, mezcla)
		else:
			if contenido != null and contenido.has_method("set_surface_override_material"):
				contenido.set_surface_override_material(0, material.duplicate())


func _color_liquido_mezclado() -> Variant:
	var suma := Color(0, 0, 0, 0)
	var peso_total := 0.0
	var resultado = null

	for entrada: Dictionary in sustancias:
		if entrada.get("fluido", false) and entrada.get("color") != null:
			var peso: float = entrada["veces"]
			suma += entrada["color"] * peso
			peso_total += peso

	if peso_total > 0.0:
		resultado = suma / peso_total

	return resultado


func contaminar(color := Color(0.05, 0.05, 0.05)) -> void:
	contaminado = true

	var material: Material = null
	if liquido != null and liquido.has_method("get_active_material"):
		material = liquido.get_active_material(0)
	if material == null and contenido != null and contenido.has_method("get_active_material"):
		material = contenido.get_active_material(0)
	if material != null:
		material = material.duplicate()
	else:
		material = StandardMaterial3D.new()
	material.set("albedo_color", color)

	if liquido != null and liquido.has_method("set_surface_override_material"):
		liquido.set_surface_override_material(0, material)
	if base != null and base.has_method("set_surface_override_material"):
		base.set_surface_override_material(0, material)
	if contenido != null and contenido.has_method("set_surface_override_material"):
		contenido.set_surface_override_material(0, material)

	if particulas_contaminacion != null:
		var tinte := color
		tinte.a = 0.5
		particulas_contaminacion.color = tinte
		particulas_contaminacion.emitting = true


func descontaminar() -> void:
	contaminado = false
	if particulas_contaminacion != null:
		particulas_contaminacion.emitting = false
