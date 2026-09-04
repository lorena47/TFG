extends GutTest


func build_utensilio(fluido := false, cantidad_maxima := 1, incremento := 0.1) -> Utensilio:
	var u := Utensilio.new()
	u.fluido = fluido
	u.CANTIDAD_MAXIMA_CONTENIDO = cantidad_maxima
	u.incremento = incremento

	var modelo := Node3D.new(); modelo.name = "modelo"
	var cuerpo := Node3D.new(); cuerpo.name = "cuerpo"
	var contenido := Node3D.new(); contenido.name = "contenido"

	cuerpo.add_child(contenido)
	modelo.add_child(cuerpo)
	u.add_child(modelo)

	add_child_autofree(u)
	return u


func build_sustancia(fluido := false, abierta := false) -> Sustancia:
	var s := Sustancia.new()
	s.info = Informacion.new()
	s.info.nombre = "Sustancia"
	s.fluido = fluido

	var modelo := Node3D.new(); modelo.name = "modelo"
	var cuerpo := Node3D.new(); cuerpo.name = "cuerpo"
	var tapa := Node3D.new(); tapa.name = "tapa"
	var contenido := Node3D.new(); contenido.name = "contenido"

	cuerpo.add_child(tapa)
	cuerpo.add_child(contenido)
	modelo.add_child(cuerpo)
	s.add_child(modelo)

	add_child_autofree(s)
	s.abierta = abierta
	return s


func build_recipiente_solido(acepta := false) -> Recipiente:
	var r := Recipiente.new()
	r.fluido = false
	r.solido = acepta

	if acepta:
		var modelo := Node3D.new(); modelo.name = "modelo"
		var cuerpo := Node3D.new(); cuerpo.name = "cuerpo"
		var contenido := Node3D.new(); contenido.name = "contenido"
		cuerpo.add_child(contenido)
		modelo.add_child(cuerpo)
		r.add_child(modelo)

	add_child_autofree(r)
	return r


# Comprobar que se cumplen las condiciones de tipo para interactuar con sustancia
# sustancia sólida => utensilio sólido && sustancia abierta
# sustancia líquida => utensilio líquido
func test_1():
	var utensilio_solido := build_utensilio()
	var sustancia_solida_cerrada := build_sustancia()
	var sustancia_solida_abierta := build_sustancia(false, true)
	
	var utensilio_liquido := build_utensilio(true)
	var sustancia_liquida := build_sustancia(true)

	##############################################################
	# sustancia sólida => utensilio sólido && sustancia abierta
	##############################################################
	
	assert_eq(utensilio_solido.cantidad_contenido, 0)
	assert_true(utensilio_solido.vacio)
	assert_eq(utensilio_solido.sustancia, null)
	assert_false(utensilio_solido.contenido.visible)
	
	utensilio_solido.interactuar(sustancia_liquida)
	assert_eq(utensilio_solido.cantidad_contenido, 0)
	assert_true(utensilio_solido.vacio)
	assert_eq(utensilio_solido.sustancia, null)
	assert_false(utensilio_solido.contenido.visible)
	
	utensilio_solido.interactuar(sustancia_solida_cerrada)
	assert_eq(utensilio_solido.cantidad_contenido, 0)
	assert_true(utensilio_solido.vacio)
	assert_eq(utensilio_solido.sustancia, null)
	assert_false(utensilio_solido.contenido.visible)
	
	utensilio_solido.interactuar(sustancia_solida_abierta)
	assert_eq(utensilio_solido.cantidad_contenido, 1)
	assert_false(utensilio_solido.vacio)
	assert_eq(utensilio_solido.sustancia, sustancia_solida_abierta)
	assert_true(utensilio_solido.contenido.visible)
	
	##############################################################
	# sustancia líquida => utensilio líquido
	##############################################################

	assert_eq(utensilio_liquido.cantidad_contenido, 0)
	assert_true(utensilio_liquido.vacio)
	assert_eq(utensilio_liquido.sustancia, null)
	assert_false(utensilio_liquido.contenido.visible)
	
	utensilio_liquido.interactuar(sustancia_solida_abierta)
	assert_eq(utensilio_liquido.cantidad_contenido, 0)
	assert_true(utensilio_liquido.vacio)
	assert_eq(utensilio_liquido.sustancia, null)
	assert_false(utensilio_liquido.contenido.visible)
	
	utensilio_liquido.interactuar(sustancia_liquida)
	assert_eq(utensilio_liquido.cantidad_contenido, 1)
	assert_false(utensilio_liquido.vacio)
	assert_eq(utensilio_liquido.sustancia, sustancia_liquida)
	assert_true(utensilio_liquido.contenido.visible)


# Comprobar que se cumplen las condiciones de cantidad para interactuar con sustancia
# si cantidad < CANTIDAD_MAXIMA => acepta
# si cantidad == CANTIDAD_MAXIMA => rechaza
func test_2():
	var utensilio := build_utensilio(false, 2, 0.15)
	var sustancia := build_sustancia(false, true)

	assert_eq(utensilio.cantidad_contenido, 0)
	var escala_original = utensilio.contenido.scale
	utensilio.interactuar(sustancia)
	assert_eq(utensilio.cantidad_contenido, 1)
	var escala_1 = utensilio.contenido.scale
	assert_eq(escala_original, escala_1)
	
	utensilio.interactuar(sustancia)
	assert_eq(utensilio.cantidad_contenido, 2)
	var escala_2 = utensilio.contenido.scale
	assert_eq(escala_2, escala_1 + escala_1 * 0.15)

	utensilio.interactuar(sustancia)
	assert_eq(utensilio.cantidad_contenido, 2)
	assert_eq(utensilio.contenido.scale, escala_2)


# Comprobar que se cumplen las consecuencias cuando otras clases aceptan interactuar
# si acepta => se vacía
# si rechaza => se mantiene
func test_3():
	var utensilio := build_utensilio()
	var sustancia := build_sustancia(false, true)
	var recipiente_rechaza := build_recipiente_solido()
	var recipiente_acepta := build_recipiente_solido(true)

	utensilio.interactuar(sustancia)
	
	utensilio.interactuar(recipiente_rechaza)
	assert_false(utensilio.vacio)
	assert_eq(utensilio.cantidad_contenido, 1)
	assert_ne(utensilio.sustancia, null)
	assert_true(utensilio.contenido.visible)
	
	utensilio.interactuar(recipiente_acepta)
	assert_true(utensilio.vacio)
	assert_eq(utensilio.cantidad_contenido, 0)
	assert_null(utensilio.sustancia)
	assert_false(utensilio.contenido.visible)


# Comprobar que al vaciar se queda en el estado esperado
func test_4():
	var utensilio := build_utensilio()
	var sustancia := build_sustancia(false, true)
	
	utensilio.interactuar(sustancia)
	utensilio.vaciar()
	
	assert_true(utensilio.vacio)
	assert_eq(utensilio.cantidad_contenido, 0)
	assert_null(utensilio.sustancia)
	assert_false(utensilio.contenido.visible)
	assert_eq(utensilio.contenido.scale, utensilio.escala_contenido)
