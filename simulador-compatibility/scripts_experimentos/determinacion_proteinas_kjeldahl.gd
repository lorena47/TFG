class_name DeterminacionProteinasKjeldahl
extends Experimento

const PENALIZACION_CONTAMINACION := 10.0

var cantidad_pesada := 0

var _paso_preparacion_muestra_3_completo := false
var _paso_verter_perlas_2_completo := false

var _tubo_contaminado := false
var _matraz_contaminado := false

var _paso_dilucion_0_completo := false

var _paso_preparacion_receptor_1_completo := false

func _definir_objetos_requeridos():
	objetos_requeridos = [
		"Barquilla",
		"Balanza de precisión",
		"Muestra molida",
		"Espátula",
		"Perlas de vidrio",
		"Bote de catalizador",
		"Tubo Kjeldahl",
		"Dispensador",
		"Digestor",
		"Probeta",
		"Matraz Erlenmeyer",
		"Destilador izq",
		"Destilador dch",
		"Destilador",
		"Bureta",
	]


func _definir_hitos():

# -----------------------------------------------------------------
#
# HITO 1: PREPARACIÓN MUESTRA Y VERTER MUESTRA
#
# -----------------------------------------------------------------

	definir_hito(
		"preparacion_muestra",
		"Pesar 1g de muestra",
		[],
		Callable(), _reinicio_preparacion_muestra, _errores_preparacion_muestra, true,
		"1"
	)

	definir_hito(
		"preparacion_muestra_0",
		"Colocar la barquilla vacía sobre la balanza",
		[],
		_objeto_vacio_en.bind("Barquilla", "Balanza de precisión"),
		_objeto_retirado_de.bind("Barquilla", "Balanza de precisión"),
		_errores_preparacion_muestra_0, true,
		"1",
		"preparacion_muestra"
	)

	definir_hito(
		"preparacion_muestra_1",
		"Abrir el bote de muestra molida",
		[],
		_bote_abierto.bind("Muestra molida"),
		_bote_cerrado.bind("Muestra molida"),
		Callable(), true,
		"1",
		"preparacion_muestra"
	)

	definir_hito(
		"preparacion_muestra_2",
		"Coger la espátula vacía",
		["preparacion_muestra_1"],
		_objeto_cogido.bind("Espátula"),
		_reinicio_preparacion_muestra_2,
		Callable(), true,
		"1",
		"preparacion_muestra",
		false
	)

	definir_hito(
		"preparacion_muestra_3",
		"Cargar la espátula con muestra molida",
		["preparacion_muestra_2"],
		_espatula_cargada_con.bind("Muestra molida"),
		_reinicio_preparacion_muestra_3,
		Callable(), true,
		"1",
		"preparacion_muestra"
	)

	definir_hito(
		"preparacion_muestra_4",
		"Verter la muestra molida en la barquilla",
		["preparacion_muestra_0", "preparacion_muestra_3"],
		_paso_preparacion_muestra_4,
		_reinicio_preparacion_muestra_4,
		Callable(), true,
		"1",
		"preparacion_muestra"
	)

	definir_hito(
		"verter_muestra",
		"Verter la muestra pesada en el tubo Kjeldahl",
		["preparacion_muestra"],
		_muestra_presente,
		_reactivos_reinicio.bind("verter_muestra"),
		_reactivos_errores.bind("verter_muestra"),
		true,
		"1"
	)

# -----------------------------------------------------------------
#
# HITO 2: VERTER PERLAS
#
# -----------------------------------------------------------------

	definir_hito(
		"verter_perlas",
		"Añadir las perlas de vidrio al tubo Kjeldahl",
		[],
		_perlas_presentes,
		_reactivos_reinicio.bind("verter_perlas"),
		_reactivos_errores.bind("verter_perlas"),
		true,
		"2"
	)

	definir_hito(
		"verter_perlas_0",
		"Abrir el bote de perlas de vidrio",
		[],
		_bote_abierto.bind("Perlas de vidrio"),
		_bote_cerrado.bind("Perlas de vidrio"),
		Callable(), true,
		"2",
		"verter_perlas"
	)

	definir_hito(
		"verter_perlas_1",
		"Coger la espátula vacía",
		["verter_perlas_0"],
		_objeto_cogido.bind("Espátula"),
		_reinicio_verter_perlas_1,
		Callable(), true,
		"2",
		"verter_perlas",
		false
	)

	definir_hito(
		"verter_perlas_2",
		"Cargar la espátula con las perlas de vidrio",
		["verter_perlas_1"],
		_espatula_cargada_con.bind("Perlas de vidrio"),
		_reinicio_verter_perlas_2,
		Callable(), true,
		"2",
		"verter_perlas"
	)

	definir_hito(
		"verter_perlas_3",
		"Verter las perlas de vidrio en el tubo Kjeldahl",
		["verter_perlas_2"],
		_paso_verter_perlas_3,
		_objeto_vaciado.bind("Tubo Kjeldahl"),
		Callable(), true,
		"2",
		"verter_perlas"
	)

# -----------------------------------------------------------------
#
# HITO 3: VERTER CATALIZADOR
#
# -----------------------------------------------------------------

	definir_hito(
		"verter_catalizador",
		"Añadir la pastilla de catalizador al tubo Kjeldahl",
		[],
		_pastilla_presente,
		_reactivos_reinicio.bind("verter_catalizador"),
		_reactivos_errores.bind("verter_catalizador"),
		true,
		"3"
	)

	definir_hito(
		"verter_catalizador_0",
		"Extraer una pastilla del bote de catalizador",
		[],
		_objeto_dispensado_de.bind("Pastilla de catalizador", "Bote de catalizador"),
		_objeto_colocado.bind("Pastilla de catalizador"),
		Callable(), true,
		"3",
		"verter_catalizador"
	)

	definir_hito(
		"verter_catalizador_1",
		"Verter la pastilla en el tubo Kjeldahl",
		["verter_catalizador_0"],
		_objeto_vertido_en.bind("Pastilla de catalizador", "Tubo Kjeldahl"),
		_objeto_vaciado.bind("Tubo Kjeldahl"),
		Callable(), true,
		"3",
		"verter_catalizador"
	)

# -----------------------------------------------------------------
#
# HITO 4: PREPARACIÓN DISPENSADOR Y DISPENSACIÓN ÁCIDO
#
# -----------------------------------------------------------------

	definir_hito(
		"preparacion_dispensador",
		"Cargar el dispensador con el ácido",
		[],
		Callable(),
		_dispensador_no_cargado_con.bind("Dispensador", "Ácido sulfúrico 95%", _acido_presente),
		Callable(),
		true,
		"4"
	)
	
	definir_hito(
		"preparacion_dispensador_0",
		"Coger el ácido sulfúrico 95%",
		[],
		_objeto_cogido.bind("Ácido sulfúrico 95%"),
		_objeto_colocado.bind("Ácido sulfúrico 95%"),
		Callable(), true,
		"4",
		"preparacion_dispensador"
	)
	
	definir_hito(
		"preparacion_dispensador_1",
		"Rellenar el bidón del dispensador con el ácido",
		["preparacion_dispensador_0"],
		_dispensador_cargado_con.bind("Dispensador", "Ácido sulfúrico 95%"),
		_dispensador_no_cargado_con.bind("Dispensador", "Ácido sulfúrico 95%", _acido_presente),
		Callable(), true,
		"4",
		"preparacion_dispensador"
	)

	definir_hito(
		"dispensacion_acido",
		"Añadir el ácido sulfúrico al tubo Kjeldahl con el dispensador",
		["verter_muestra", "verter_perlas", "verter_catalizador"],
		_acido_presente,
		_reactivos_reinicio.bind("dispensacion_acido"),
		_reactivos_errores.bind("dispensacion_acido"),
		true,
		"4"
	)

	definir_hito(
		"dispensacion_acido_0",
		"Colocar el tubo Kjeldahl en el dispensador de líquido",
		["verter_muestra", "verter_perlas", "verter_catalizador"],
		_objeto_colocado_en.bind("Tubo Kjeldahl", "Dispensador"),
		_objeto_retirado_de.bind("Tubo Kjeldahl", "Dispensador"),
		Callable(), true,
		"4",
		"dispensacion_acido"
	)

	definir_hito(
		"dispensacion_acido_1",
		"Dispensar el ácido sulfúrico con el tubo colocado",
		["dispensacion_acido_0"],
		_objeto_vertido_en.bind("Dispensador", "Tubo Kjeldahl"),
		_objeto_retirado_de.bind("Tubo Kjeldahl", "Dispensador"),
		Callable(), true,
		"4",
		"dispensacion_acido"
	)

# -----------------------------------------------------------------
#
# HITO 5: DIGESTIÓN
#
# -----------------------------------------------------------------

	definir_hito(
		"digestion",
		"Llevar a cabo el proceso de digestión",
		["dispensacion_acido"],
		Callable(),
		_reactivos_reinicio,
		_reactivos_errores,
		true,
		"5"
	)

	definir_hito(
		"digestion_0",
		"Colocar el tubo Kjeldahl en el digestor",
		["dispensacion_acido"],
		_objeto_colocado_en.bind("Tubo Kjeldahl", "Digestor"),
		_objeto_retirado_de.bind("Tubo Kjeldahl", "Digestor"),
		Callable(), true,
		"5",
		"digestion"
	)

	definir_hito(
		"digestion_1",
		"Activar el digestor con el tubo colocado a 400ºC durante 90 minutos",
		["digestion_0"],
		_paso_digestion_1,
		_objeto_retirado_de.bind("Tubo Kjeldahl", "Digestor"),
		Callable(), true,
		"5",
		"digestion"
	)

# -----------------------------------------------------------------
#
# HITO 6: DILUCIÓN
#
# -----------------------------------------------------------------

	definir_hito(
		"dilucion",
		"Añadir agua destilada al tubo Kjeldahl midiéndola en la probeta",
		[],
		Callable(),
		_reactivos_reinicio.bind("dilucion"),
		_errores_dilucion,
		true,
		"6"
	)

	definir_hito(
		"dilucion_0",
		"Verter 50mL de agua destilada en la probeta",
		[],
		_probeta_contiene_solo.bind("Agua destilada"),
		_reinicio_dilucion_0,
		_errores_probeta.bind("dilucion_0"),
		true,
		"6",
		"dilucion"
	)

	definir_hito(
		"dilucion_1",
		"Verter el agua medida en el tubo Kjeldahl",
		["digestion", "dilucion_0"],
		_paso_dilucion_1,
		_objeto_vaciado.bind("Tubo Kjeldahl"),
		Callable(), true,
		"6",
		"dilucion"
	)

# -----------------------------------------------------------------
#
# HITO 7: PREPARACIÓN DEL RECEPTOR
#
# -----------------------------------------------------------------

	definir_hito(
		"preparacion_receptor",
		"Preparar el matraz Erlenmeyer",
		[],
		Callable(),
		_matraz_reinicio.bind("preparacion_receptor"),
		_errores_preparacion_receptor,
		true,
		"7"
	)

	definir_hito(
		"preparacion_receptor_0",
		"Coger el ácido bórico 4%",
		[],
		_objeto_cogido.bind("Ácido bórico 4%"),
		_reinicio_preparacion_receptor_0,
		Callable(), true,
		"7",
		"preparacion_receptor"
	)

	definir_hito(
		"preparacion_receptor_1",
		"Verter 25mL del ácido bórico en la probeta",
		["preparacion_receptor_0"],
		_probeta_contiene_solo.bind("Ácido bórico 4%"),
		_reinicio_preparacion_receptor_1,
		_errores_probeta.bind("preparacion_receptor_1"),
		true,
		"7",
		"preparacion_receptor"
	)

	definir_hito(
		"preparacion_receptor_2",
		"Verter el ácido bórico medido de la probeta al matraz Erlenmeyer",
		["preparacion_receptor_1"],
		_paso_preparacion_receptor_2,
		_matraz_reinicio,
		_matraz_errores.bind("preparacion_receptor_2"),
		true,
		"7",
		"preparacion_receptor"
	)

	definir_hito(
		"preparacion_receptor_3",
		"Coger el rojo de metilo",
		[],
		_objeto_cogido.bind("Rojo de metilo"),
		_reinicio_preparacion_receptor_3,
		Callable(), true,
		"7",
		"preparacion_receptor"
	)

	definir_hito(
		"preparacion_receptor_4",
		"Añadir 2-3 gotas del indicador en el matraz Erlenmeyer",
		["preparacion_receptor_3"],
		_matraz_contiene.bind("Rojo de metilo"),
		_matraz_reinicio,
		_matraz_errores.bind("preparacion_receptor_4"),
		true,
		"7",
		"preparacion_receptor"
	)

	definir_hito(
		"preparacion_receptor_5",
		"Colocar el matraz Erlenmeyer en el lado derecho del destilador",
		["preparacion_receptor_2", "preparacion_receptor_4"],
		_objeto_colocado_en.bind("Matraz Erlenmeyer", "Destilador dch"),
		_objeto_retirado_de.bind("Matraz Erlenmeyer", "Destilador dch"),
		Callable(), true,
		"7",
		"preparacion_receptor"
	)

# -----------------------------------------------------------------
#
# HITO 8: DESTILACIÓN
#
# -----------------------------------------------------------------

	definir_hito(
		"destilacion_izquierda",
		"Posicionar el tubo Kjeldahl en el destilador",
		["dilucion"],
		Callable(),
		_reactivos_reinicio,
		_reactivos_errores,
		true,
		"8"
	)

	definir_hito(
		"destilacion_izquierda_0",
		"Colocar el tubo Kjeldahl en el lado izquierdo del destilador",
		["dilucion"],
		_objeto_colocado_en.bind("Tubo Kjeldahl", "Destilador izq"),
		_objeto_retirado_de.bind("Tubo Kjeldahl", "Destilador izq"),
		Callable(), true,
		"8",
		"destilacion_izquierda"
	)

	definir_hito(
		"destilacion_izquierda_1",
		"Sujetar el tubo en el destilador",
		["destilacion_izquierda_0"],
		_paso_destilacion_izquierda_1,
		_objeto_retirado_de.bind("Tubo Kjeldahl", "Destilador izq"),
		Callable(), true,
		"8",
		"destilacion_izquierda"
	)

	definir_hito(
		"destilacion_derecha",
		"Realizar la destilación",
		["destilacion_izquierda", "preparacion_receptor"],
		Callable(), _matraz_reinicio.bind("destilacion_derecha"), _matraz_errores, true,
		"8"
	)

	definir_hito(
		"destilacion_derecha_0",
		"Completar con agua destilada el matraz hasta que la alargadera quede sumergida",
		["destilacion_izquierda", "preparacion_receptor"],
		_matraz_contiene.bind("Agua destilada"),
		_matraz_reinicio,
		_matraz_errores.bind("destilacion_derecha_0"), true,
		"8",
		"destilacion_derecha"
	)
	
	definir_hito(
		"destilacion_derecha_1",
		"Activar el destilador para dosificar 40mL de NaOH y observar cómo se produce el viraje del indicador",
		["destilacion_derecha_0"],
		_paso_destilacion_derecha_1,
		_objeto_retirado_de.bind("Tubo Kjeldahl", "Destilador izq"),
		Callable(), true,
		"8",
		"destilacion_derecha"
	)

# -----------------------------------------------------------------
#
# HITO 9: VALORACIÓN
#
# -----------------------------------------------------------------

	definir_hito(
		"preparacion_valoracion",
		"Preparar la bureta con HCl 0.1N",
		[],
		Callable(),
		_dispensador_no_cargado_con.bind("Bureta", "Ácido clorhídrico 0.1N", _hcl_presente),
		Callable(),
		true,
		"9",
	)

	definir_hito(
		"preparacion_valoracion_0",
		"Coger HCl 0.1N",
		[],
		_objeto_cogido.bind("Ácido clorhídrico 0.1N"),
		_objeto_colocado.bind("Ácido clorhídrico 0.1N"),
		Callable(), true,
		"9",
		"preparacion_valoracion"
	)

	definir_hito(
		"preparacion_valoracion_1",
		"Añadir el ácido clorhídrico a la bureta",
		["preparacion_valoracion_0"],
		_dispensador_cargado_con.bind("Bureta", "Ácido clorhídrico 0.1N"),
		_dispensador_no_cargado_con.bind("Bureta", "Ácido clorhídrico 0.1N", _hcl_presente),
		Callable(), true,
		"9",
		"preparacion_valoracion"
	)

	definir_hito(
		"valoracion",
		"Realizar la valoración del destilado",
		["destilacion_derecha", "preparacion_valoracion"],
		Callable(), _matraz_reinicio.bind("valoracion"), _matraz_errores, true,
		"9"
	)

	definir_hito(
		"valoracion_0",
		"Recoger el matraz con el amoniaco generado en la disolución de ácido bórico",
		["destilacion_derecha", "preparacion_valoracion"],
		_objeto_cogido.bind("Matraz Erlenmeyer"),
		_reinicio_valoracion_0,
		Callable(), true,
		"9",
		"valoracion"
	)

	definir_hito(
		"valoracion_1",
		"Colocar el amoniaco recogido en la bureta",
		["valoracion_0"],
		_objeto_colocado_en.bind("Matraz Erlenmeyer", "Bureta"),
		_objeto_retirado_de.bind("Matraz Erlenmeyer", "Bureta"),
		Callable(), true,
		"9",
		"valoracion"
	)

	definir_hito(
		"valoracion_2",
		"Abrir la llave de paso de la bureta hasta el retroviraje del indicador",
		["valoracion_1"],
		_paso_valoracion_2,
		_matraz_reinicio,
		_matraz_errores.bind("valoracion_2"), true,
		"9",
		"valoracion"
	)


# ===========================================================================
# 
# MEZCLAS
#
# ===========================================================================


const _HITOS_SUSTANCIA_TUBO := {
	"Muestra molida": "verter_muestra",
	"Perlas de vidrio": "verter_perlas",
	"Pastilla de catalizador": "verter_catalizador",
	"Ácido sulfúrico 95%": "dispensacion_acido",
	"Agua destilada": "dilucion",
}


func _hito_disponible(id: String) -> bool:
	return hitos.has(id) and requisitos_pendientes(id).is_empty()


func _sustancias_permitidas_tubo() -> Array[String]:
	var permitidas: Array[String] = ["Muestra molida", "Perlas de vidrio", "Pastilla de catalizador"]
	if _hito_disponible("dispensacion_acido"):
		permitidas.append("Ácido sulfúrico 95%")
	if _hito_disponible("dilucion_1"):
		permitidas.append("Agua destilada")
	return permitidas


func _reactivos_errores(evento: Evento, id_hito_propio: String = ""):
	var resultado = false
	var tubo := Gestor.buscar_objeto("Tubo Kjeldahl") as Recipiente
	if tubo != null:
		var permitidas := _sustancias_permitidas_tubo()
		var entradas_por_sustancia := {}
		for entrada: Dictionary in tubo.mezcla():
			if !permitidas.has(entrada["nombre"]):
				resultado = "En el tubo Kjeldahl hay sustancias incorrectas. Vacíalo y repite la preparación."
			entradas_por_sustancia[entrada["nombre"]] = entradas_por_sustancia.get(entrada["nombre"], 0) + 1

		if !resultado and id_hito_propio != "":
			for nombre_sustancia in _HITOS_SUSTANCIA_TUBO:
				if _HITOS_SUSTANCIA_TUBO[nombre_sustancia] == id_hito_propio:
					if hito_alcanzado(id_hito_propio) and entradas_por_sustancia.get(nombre_sustancia, 0) > 1:
						resultado = "En el tubo Kjeldahl se ha vuelto a añadir %s después de completado ese paso. Vacíalo y repite." % nombre_sustancia
					break

		if resultado and evento != null:
			_marcar_tubo_contaminado()

	return resultado


func _reactivos_reinicio(evento: Evento, id_hito_propio: String = ""):
	var reinicio := false
	var tubo := Gestor.buscar_objeto("Tubo Kjeldahl") as Recipiente
	if tubo != null:
		if evento.tipo == Evento.Tipo.VACIAR and evento.objeto == tubo:
			reinicio = true
			cantidad_pesada = 0
			_tubo_contaminado = false
		elif _tubo_contaminado:
			reinicio = true
		elif _reapertura_tubo(id_hito_propio):
			reinicio = true
			_marcar_tubo_contaminado()
	return reinicio


func _reapertura_tubo(id_hito_propio: String) -> bool:
	var tubo := Gestor.buscar_objeto("Tubo Kjeldahl") as Recipiente
	var nombre_propio := ""
	for nombre_sustancia in _HITOS_SUSTANCIA_TUBO:
		if _HITOS_SUSTANCIA_TUBO[nombre_sustancia] == id_hito_propio:
			nombre_propio = nombre_sustancia
			break
	var veces := 0
	if tubo != null and nombre_propio != "":
		for entrada: Dictionary in tubo.mezcla():
			if entrada["nombre"] == nombre_propio:
				veces += 1
	return id_hito_propio != "" and hito_alcanzado(id_hito_propio) and veces > 1


func _marcar_tubo_contaminado():
	if !_tubo_contaminado:
		penalizar(PENALIZACION_CONTAMINACION)
	_tubo_contaminado = true
	var tubo := Gestor.buscar_objeto("Tubo Kjeldahl") as Recipiente
	if tubo != null:
		tubo.contaminar()


func _sustancias_permitidas_matraz() -> Array[String]:
	var permitidas: Array[String] = ["Ácido bórico 4%", "Rojo de metilo"]
	if _hito_disponible("destilacion_derecha_0"):
		permitidas.append("Agua destilada")
	if _hito_disponible("valoracion_2"):
		permitidas.append("Ácido clorhídrico 0.1N")
	return permitidas


const _HITOS_SUSTANCIA_MATRAZ := {
	"Ácido bórico 4%": "preparacion_receptor_2",
	"Rojo de metilo": "preparacion_receptor_4",
	"Agua destilada": "destilacion_derecha_0",
	"Ácido clorhídrico 0.1N": "valoracion_2",
}


func _matraz_errores(evento: Evento, id_hito_propio: String = ""):
	var resultado = false
	var matraz := Gestor.buscar_objeto("Matraz Erlenmeyer") as Recipiente
	if matraz != null:
		var permitidas := _sustancias_permitidas_matraz()
		var entradas_por_sustancia := {}
		for entrada: Dictionary in matraz.mezcla():
			if !permitidas.has(entrada["nombre"]):
				resultado = "En el matraz Erlenmeyer hay sustancias incorrectas. Vacíalo y repite."
			entradas_por_sustancia[entrada["nombre"]] = entradas_por_sustancia.get(entrada["nombre"], 0) + 1

		if !resultado and id_hito_propio != "":
			for nombre_sustancia in _HITOS_SUSTANCIA_MATRAZ:
				if _HITOS_SUSTANCIA_MATRAZ[nombre_sustancia] == id_hito_propio:
					if hito_alcanzado(id_hito_propio) and entradas_por_sustancia.get(nombre_sustancia, 0) > 1:
						resultado = "En el matraz Erlenmeyer se ha vuelto a añadir %s después de completado ese paso. Vacíalo y repite." % nombre_sustancia
					break

		if resultado and evento != null:
			_marcar_matraz_contaminado()

	return resultado


func _matraz_reinicio(evento: Evento, id_hito_propio: String = ""):
	var reinicio := false
	var matraz := Gestor.buscar_objeto("Matraz Erlenmeyer") as Recipiente
	if matraz != null:
		if evento.tipo == Evento.Tipo.VACIAR and evento.objeto == matraz:
			reinicio = true
			_matraz_contaminado = false
		elif _matraz_contaminado:
			reinicio = true
		elif _reapertura_matraz(id_hito_propio):
			reinicio = true
			_marcar_matraz_contaminado()
	return reinicio


func _matraz_contiene(evento: Evento, nombre_sustancia: String) -> bool:
	var matraz := Gestor.buscar_objeto("Matraz Erlenmeyer") as Recipiente
	var presente := false
	if not _matraz_contaminado:
		if matraz != null:
			for entrada: Dictionary in matraz.mezcla():
				if entrada["nombre"] == nombre_sustancia:
					presente = true
	return presente


func _reapertura_matraz(id_hito_propio: String) -> bool:
	var matraz := Gestor.buscar_objeto("Matraz Erlenmeyer") as Recipiente
	var reabierta := false
	if matraz != null and id_hito_propio != "":
		var entradas_por_sustancia := {}
		for entrada: Dictionary in matraz.mezcla():
			entradas_por_sustancia[entrada["nombre"]] = entradas_por_sustancia.get(entrada["nombre"], 0) + 1
		for nombre_sustancia in _HITOS_SUSTANCIA_MATRAZ:
			var id_hito_sustancia: String = _HITOS_SUSTANCIA_MATRAZ[nombre_sustancia]
			var coincide := id_hito_sustancia == id_hito_propio or padre_visual_hito(id_hito_sustancia) == id_hito_propio
			if coincide and hito_alcanzado(id_hito_sustancia) and entradas_por_sustancia.get(nombre_sustancia, 0) > 1:
				reabierta = true
	return reabierta


func _marcar_matraz_contaminado():
	if !_matraz_contaminado:
		penalizar(PENALIZACION_CONTAMINACION)
	_matraz_contaminado = true
	var matraz := Gestor.buscar_objeto("Matraz Erlenmeyer") as Recipiente
	if matraz != null:
		matraz.contaminar(Color(0.15, 0.2, 0.05))


# ===========================================================================
# 
# FUNCIONES AUXILIARES
#
# ===========================================================================


func _objeto_vacio_en(evento: Evento, nombre_objeto: String, nombre_lugar: String) -> bool:
	var objeto := Gestor.buscar_objeto(nombre_objeto) as Recipiente
	var lugar := Gestor.buscar_objeto(nombre_lugar)
	return objeto != null and lugar != null and Gestor.esta_en(objeto, lugar) and objeto.vacio()


func _objeto_retirado_de(evento: Evento, nombre_objeto: String, nombre_origen: String) -> bool:
	var objeto := Gestor.buscar_objeto(nombre_objeto)
	var origen := Gestor.buscar_objeto(nombre_origen)
	return (
		objeto != null and origen != null
		and evento.tipo == Evento.Tipo.RETIRAR
		and evento.objeto == objeto
		and evento.origen == origen
	)


func _objeto_cogido(evento: Evento, nombre_objeto: String) -> bool:
	var objeto := Gestor.buscar_objeto(nombre_objeto)
	return (
		objeto != null
		and evento.tipo == Evento.Tipo.RETIRAR
		and evento.objeto == objeto
	)


func _objeto_colocado(evento: Evento, nombre_objeto: String) -> bool:
	var objeto := Gestor.buscar_objeto(nombre_objeto)
	return objeto != null and evento.tipo == Evento.Tipo.COLOCAR and evento.objeto == objeto


func _objeto_vaciado(evento: Evento, nombre_objeto: String) -> bool:
	var objeto := Gestor.buscar_objeto(nombre_objeto)
	return objeto != null and evento.tipo == Evento.Tipo.VACIAR and evento.objeto == objeto


func _bote_abierto(evento: Evento, nombre_bote: String) -> bool:
	var bote := Gestor.buscar_objeto(nombre_bote) as Sustancia
	return bote != null and bote.abierta


func _bote_cerrado(evento: Evento, nombre_bote: String) -> bool:
	var bote := Gestor.buscar_objeto(nombre_bote) as Sustancia
	return bote != null and !bote.abierta


func _espatula_cargada_con(evento: Evento, nombre_sustancia: String) -> bool:
	var espatula := Gestor.buscar_objeto("Espátula") as Utensilio
	return (
		espatula != null
		and espatula.sustancia != null
		and espatula.sustancia.info.nombre == nombre_sustancia
	)


func _espatula_no_cargada_con(evento: Evento, nombre_sustancia: String) -> bool:
	var espatula := Gestor.buscar_objeto("Espátula") as Utensilio
	return (
		espatula != null
		and espatula.sustancia != null
		and espatula.sustancia.info.nombre != nombre_sustancia
	)


func _objeto_vertido_en(evento: Evento, nombre_objeto: String, nombre_destino: String) -> bool:
	var objeto := Gestor.buscar_objeto(nombre_objeto)
	var destino := Gestor.buscar_objeto(nombre_destino)
	return (
		objeto != null and destino != null
		and evento.tipo == Evento.Tipo.VERTER
		and evento.objeto == objeto
		and evento.destino == destino
	)


func _objeto_dispensado_de(evento: Evento, nombre_objeto: String, nombre_origen: String) -> bool:
	var objeto := Gestor.buscar_objeto(nombre_objeto)
	var origen := Gestor.buscar_objeto(nombre_origen)
	return (
		objeto != null and origen != null
		and evento.tipo == Evento.Tipo.DISPENSAR
		and evento.objeto == objeto
		and evento.origen == origen
	)


func _objeto_colocado_en(evento: Evento, nombre_objeto: String, nombre_lugar: String) -> bool:
	var objeto := Gestor.buscar_objeto(nombre_objeto)
	var lugar := Gestor.buscar_objeto(nombre_lugar)
	return objeto != null and lugar != null and Gestor.esta_en(objeto, lugar)


func _dispensador_cargado_con(evento: Evento, nombre_instrumento: String, nombre_sustancia: String) -> bool:
	var dispensador := Gestor.buscar_instrumento(nombre_instrumento) as Dosificador
	return (dispensador != null and dispensador.sustancia != null and dispensador.sustancia.info.nombre == nombre_sustancia)


func _dispensador_no_cargado_con(evento: Evento, nombre_instrumento: String, nombre_sustancia: String, condicion: Callable = Callable()) -> bool:
	var resultado := false
	if !(condicion.is_valid() and condicion.call(evento)):
		var dispensador := Gestor.buscar_instrumento(nombre_instrumento) as Dosificador
		resultado = (dispensador != null and (dispensador.sustancia == null or dispensador.sustancia.info.nombre != nombre_sustancia))
	return resultado


func _probeta_contiene_solo(evento: Evento, nombre_sustancia: String) -> bool:
	var probeta := Gestor.buscar_objeto("Probeta") as Recipiente
	var resultado := false
	if probeta != null and !probeta.vacio():
		resultado = true
		for entrada: Dictionary in probeta.mezcla():
			if entrada["nombre"] != nombre_sustancia:
				resultado = false
	return resultado


func _errores_probeta(evento: Evento, id_hito: String):
	var resultado = false
	if !hito_alcanzado(id_hito):
		var probeta := Gestor.buscar_objeto("Probeta") as Recipiente
		if probeta != null and !probeta.vacio():
			var nombres := {}
			for entrada: Dictionary in probeta.mezcla():
				nombres[entrada["nombre"]] = true
			if nombres.size() > 1:
				resultado = "En la probeta solo debe medirse una sustancia. Vacíala y repite."
	return resultado


# -----------------------------------------------------------------
#
# HITO 1: PREPARACION_MUESTRA
#
# -----------------------------------------------------------------A


func _errores_preparacion_muestra(evento: Evento):
	var resultado = _reactivos_errores(evento)
	if !resultado:
		var tubo := Gestor.buscar_objeto("Tubo Kjeldahl") as Recipiente
		if tubo != null:
			var veces_muestra := 0
			for entrada: Dictionary in tubo.mezcla():
				if entrada["nombre"] == "Muestra molida":
					veces_muestra += entrada["veces"]
			if veces_muestra > 0 and veces_muestra != cantidad_pesada:
				resultado = "En el tubo Kjeldahl debe verterse únicamente la muestra que se pese en la barquilla."
				if evento != null:
					_marcar_tubo_contaminado()
	return resultado


func _muestra_presente(evento: Evento) -> bool:
	var presente := false
	var tubo := Gestor.buscar_objeto("Tubo Kjeldahl") as Recipiente
	if tubo != null and cantidad_pesada != 0:
		var veces_muestra := 0
		for entrada: Dictionary in tubo.mezcla():
			if entrada["nombre"] == "Muestra molida":
				veces_muestra += entrada["veces"]
				presente = veces_muestra == cantidad_pesada
	return presente


func _reinicio_preparacion_muestra(evento: Evento):
	var reinicio = _reactivos_reinicio(evento)
	if !reinicio and cantidad_pesada != 0 and !hito_alcanzado("verter_muestra"):
		var barquilla := Gestor.buscar_objeto("Barquilla") as Recipiente
		var balanza := Gestor.buscar_objeto("Balanza de precisión") as Instrumento
		if barquilla != null and balanza != null and evento.tipo == Evento.Tipo.VERTER:
			var en_balanza := Gestor.esta_en(barquilla, balanza)
			var destino_esperado = balanza if en_balanza else barquilla
			if evento.destino == destino_esperado:
				if en_balanza:
					var contenido := barquilla.mezcla()
					if contenido.size() == 1 and contenido[0]["nombre"] == "Muestra molida":
						cantidad_pesada = contenido[0]["veces"]
					else:
						reinicio = "La barquilla ya no contiene únicamente la muestra pesada. Vacíala y repite el pesaje."
						cantidad_pesada = 0
				else:
					reinicio = "Se ha añadido muestra sin pesar a la barquilla. Vacíala y repite el pesaje."
					cantidad_pesada = 0
	return reinicio


func _reinicio_preparacion_muestra_2(evento: Evento) -> bool:
	return _objeto_colocado(evento, "Espátula") and !_espatula_cargada_con(evento, "Muestra molida")


func _reinicio_preparacion_muestra_3(evento: Evento) -> bool:
	var reinicio := _espatula_no_cargada_con(evento, "Muestra molida")
	if _objeto_vaciado(evento, "Espátula") and !_paso_preparacion_muestra_3_completo:
		reinicio = true
	return reinicio


func _paso_preparacion_muestra_4(evento: Evento) -> bool:
	var exito := false
	var barquilla := Gestor.buscar_objeto("Barquilla") as Recipiente
	if barquilla != null:
		var contenido := barquilla.mezcla()
		if contenido.size() == 1 and contenido[0]["nombre"] == "Muestra molida":
			exito = true
			if requisitos_pendientes("preparacion_muestra_4").is_empty():
				cantidad_pesada = contenido[0]["veces"]
				_paso_preparacion_muestra_3_completo = true
				call_deferred("_reinicio_preparacion_muestra_3_completo")
	return exito


func _reinicio_preparacion_muestra_3_completo():
	_paso_preparacion_muestra_3_completo = false


func _reinicio_preparacion_muestra_4(evento: Evento) -> bool:
	var barquilla := Gestor.buscar_objeto("Barquilla") as Recipiente
	var reinicio := barquilla != null and evento.tipo == Evento.Tipo.VACIAR and evento.objeto == barquilla
	if reinicio:
		cantidad_pesada = 0
	return reinicio


func _errores_preparacion_muestra_0(evento: Evento):
	var resultado = false
	if !hito_alcanzado("preparacion_muestra_4"):
		var barquilla := Gestor.buscar_objeto("Barquilla") as Recipiente
		var balanza := Gestor.buscar_objeto("Balanza de precisión") as Instrumento
		if barquilla != null and balanza != null and !barquilla.vacio():
			if Gestor.esta_en(barquilla, balanza):
				resultado = "La barquilla debe colocarse vacía sobre la balanza. Vacíala y repite."
			else:
				resultado = "Coloca primero la barquilla vacía sobre la balanza antes de verter contenido."
	return resultado


# -----------------------------------------------------------------
#
# HITO 2: VERTER PERLAS
#
# -----------------------------------------------------------------


func _perlas_presentes(evento: Evento) -> bool:
	var presentes := false
	if !_tubo_contaminado:
		var tubo := Gestor.buscar_objeto("Tubo Kjeldahl") as Recipiente
		if tubo != null:
			for entrada: Dictionary in tubo.mezcla():
				if entrada["nombre"] == "Perlas de vidrio":
					presentes = true
	return presentes


func _reinicio_verter_perlas_1(evento: Evento) -> bool:
	return _objeto_colocado(evento, "Espátula") and !_espatula_cargada_con(evento, "Perlas de vidrio")


func _reinicio_verter_perlas_2(evento: Evento) -> bool:
	var reinicio := _espatula_no_cargada_con(evento, "Perlas de vidrio")
	if _objeto_vaciado(evento, "Espátula") and !_paso_verter_perlas_2_completo:
		reinicio = true
	return reinicio


func _paso_verter_perlas_3(evento: Evento) -> bool:
	var exito := _objeto_vertido_en(evento, "Espátula", "Tubo Kjeldahl")
	if exito:
		if requisitos_pendientes("verter_perlas_3").is_empty():
			_paso_verter_perlas_2_completo = true
			call_deferred("_reinicio_verter_perlas_2_completo")
	return exito


func _reinicio_verter_perlas_2_completo():
	_paso_verter_perlas_2_completo = false


# -----------------------------------------------------------------
#
# HITO 3: VERTER CATALIZADOR
#
# -----------------------------------------------------------------


func _pastilla_presente(evento: Evento) -> bool:
	var presente := false
	if !_tubo_contaminado:
		var tubo := Gestor.buscar_objeto("Tubo Kjeldahl") as Recipiente
		if tubo != null:
			for entrada: Dictionary in tubo.mezcla():
				if entrada["nombre"] == "Pastilla de catalizador":
					presente = true
	return presente


# -----------------------------------------------------------------
#
# HITO 4: PREPARACIÓN DISPENSADOR Y DISPENSACIÓN ÁCIDO
#
# -----------------------------------------------------------------


func _acido_presente(evento: Evento) -> bool:
	var presente := false
	if !_tubo_contaminado:
		var tubo := Gestor.buscar_objeto("Tubo Kjeldahl") as Recipiente
		if tubo != null:
			for entrada: Dictionary in tubo.mezcla():
				if entrada["nombre"] == "Ácido sulfúrico 95%":
					presente = true
	return presente


# -----------------------------------------------------------------
#
# HITO 5: DIGESTIÓN
#
# -----------------------------------------------------------------


func _paso_digestion_1(evento: Evento) -> bool:
	var digestor := Gestor.buscar_objeto("Digestor") as Instrumento
	var tubo := Gestor.buscar_objeto("Tubo Kjeldahl")
	return digestor != null and tubo != null and digestor.interaccionado and digestor.obtener_objeto() == tubo


# -----------------------------------------------------------------
#
# HITO 6: DILUCIÓN
#
# -----------------------------------------------------------------


func _errores_dilucion(evento: Evento):
	var resultado = false
	var tubo := Gestor.buscar_objeto("Tubo Kjeldahl") as Recipiente
	var agua := Gestor.buscar_objeto("Agua destilada")
	if (tubo != null and agua != null and evento != null and evento.tipo == Evento.Tipo.VERTER
		and evento.objeto == agua and evento.destino == tubo):

		resultado = "El agua destilada debe medirse primero en la probeta y verterse desde ahí al tubo Kjeldahl, no directamente desde el bote. Vacíalo y repite."
	if resultado and evento != null:
		_marcar_tubo_contaminado()
	if !resultado:
		resultado = _reactivos_errores(evento, "dilucion")
	return resultado


func _reinicio_dilucion_0(evento: Evento) -> bool:
	return _objeto_vaciado(evento, "Probeta") and !_paso_dilucion_0_completo


func _paso_dilucion_1(evento: Evento) -> bool:
	var exito := _objeto_vertido_en(evento, "Probeta", "Tubo Kjeldahl")
	if exito and requisitos_pendientes("dilucion_1").is_empty():
		_paso_dilucion_0_completo = true
		call_deferred("_reinicio_dilucion_0_completo")
	return exito


func _reinicio_dilucion_0_completo():
	_paso_dilucion_0_completo = false


# -----------------------------------------------------------------
#
# HITO 7: PREPARACIÓN DEL RECEPTOR
#
# -----------------------------------------------------------------


func _reinicio_preparacion_receptor_0(evento: Evento) -> bool:
	var reinicio := _objeto_colocado(evento, "Ácido bórico 4%") and !hito_alcanzado("preparacion_receptor_1")
	if !reinicio:
		reinicio = _reinicio_preparacion_receptor_1(evento)
	return reinicio


func _reinicio_preparacion_receptor_1(evento: Evento) -> bool:
	if _objeto_vertido_en(evento, "Probeta", "Matraz Erlenmeyer"):
		_paso_preparacion_receptor_1_completo = true
		call_deferred("_reinicio_preparacion_receptor_1_completo")
	var reinicio := _objeto_vaciado(evento, "Probeta") and !_paso_preparacion_receptor_1_completo
	if !reinicio and hito_alcanzado("preparacion_receptor_2"):
		reinicio = _matraz_reinicio(evento)
	return reinicio


func _reinicio_preparacion_receptor_3(evento: Evento) -> bool:
	var reinicio := _objeto_colocado(evento, "Rojo de metilo") and !hito_alcanzado("preparacion_receptor_4")
	if !reinicio:
		reinicio = _matraz_reinicio(evento)
	return reinicio


func _paso_preparacion_receptor_2(evento: Evento) -> bool:
	var exito := _objeto_vertido_en(evento, "Probeta", "Matraz Erlenmeyer")
	if exito:
		_paso_preparacion_receptor_1_completo = true
		call_deferred("_reinicio_preparacion_receptor_1_completo")
	return exito


func _reinicio_preparacion_receptor_1_completo():
	_paso_preparacion_receptor_1_completo = false


func _errores_preparacion_receptor(evento: Evento):
	var resultado = false
	var matraz := Gestor.buscar_objeto("Matraz Erlenmeyer") as Recipiente
	var acido := Gestor.buscar_objeto("Ácido bórico 4%")
	if (matraz != null and acido != null and evento != null and evento.tipo == Evento.Tipo.VERTER
		and evento.objeto == acido and evento.destino == matraz):

		resultado = "El ácido bórico debe medirse primero en la probeta y verterse desde ahí al matraz Erlenmeyer, no directamente desde el bote. Vacíalo y repite."
	if resultado and evento != null:
		_marcar_matraz_contaminado()
	if !resultado:
		resultado = _matraz_errores(evento)
	return resultado

# -----------------------------------------------------------------
#
# HITO 8: DESTILACIÓN
#
# -----------------------------------------------------------------


func _paso_destilacion_izquierda_1(evento: Evento) -> bool:
	var destilador := Gestor.buscar_objeto("Destilador izq") as Instrumento
	var tubo := Gestor.buscar_objeto("Tubo Kjeldahl")
	return destilador != null and tubo != null and destilador.interaccionado and destilador.obtener_objeto() == tubo


func _paso_destilacion_derecha_1(evento: Evento) -> bool:
	var destilador := Gestor.buscar_instrumento("Destilador")
	return destilador != null and destilador.interaccionado


# -----------------------------------------------------------------
#
# HITO 9: VALORACIÓN
#
# -----------------------------------------------------------------


func _hcl_presente(evento: Evento) -> bool:
	var presente := false
	var matraz := Gestor.buscar_objeto("Matraz Erlenmeyer") as Recipiente
	if matraz != null:
		for entrada: Dictionary in matraz.mezcla():
			if entrada["nombre"] == "Ácido clorhídrico 0.1N":
				presente = true
	return presente


func _paso_valoracion_2(evento: Evento) -> bool:
	var bureta := Gestor.buscar_instrumento("Bureta")
	var matraz := Gestor.buscar_objeto("Matraz Erlenmeyer")
	return bureta != null and matraz != null and bureta.interaccionado and bureta.obtener_objeto() == matraz


func _reinicio_valoracion_0(evento: Evento) -> bool:
	var bureta := Gestor.buscar_instrumento("Bureta")
	var matraz := Gestor.buscar_objeto("Matraz Erlenmeyer")
	var es_colocado_en_bureta := (bureta != null and matraz != null and evento.tipo == Evento.Tipo.COLOCAR
		and evento.objeto == matraz and evento.destino == bureta)
	return _objeto_colocado(evento, "Matraz Erlenmeyer") and !es_colocado_en_bureta
