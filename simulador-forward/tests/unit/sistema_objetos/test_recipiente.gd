extends GutTest


func build_recipiente(fluido := false, solido := false, deforme := false, con_base := false, con_liquido := false, con_contenido := false, con_marker := false) -> Recipiente:
	var r := Recipiente.new()
	r.fluido = fluido
	r.solido = solido
	r.deforme = deforme

	if con_marker:
		var marker := Marker3D.new(); marker.name = "Marker3D"
		r.add_child(marker)

	if con_base or con_liquido or con_contenido:
		var modelo := Node3D.new(); modelo.name = "modelo"
		var cuerpo := Node3D.new(); cuerpo.name = "cuerpo"
		modelo.add_child(cuerpo)

		if con_base:
			var base := Node3D.new(); base.name = "base"
			cuerpo.add_child(base)
		if con_liquido:
			var liquido := Node3D.new(); liquido.name = "liquido"
			liquido.visible = false
			cuerpo.add_child(liquido)
		if con_contenido:
			var contenido := Node3D.new(); contenido.name = "contenido"
			cuerpo.add_child(contenido)

		r.add_child(modelo)

	add_child_autofree(r)
	return r


func build_sustancia_fake(nombre := "Sustancia") -> Sustancia:
	var s := Sustancia.new()
	s.info = Informacion.new()
	s.info.nombre = nombre
	autofree(s)
	return s


func build_utensilio_fake(cantidad_contenido := 0, cantidad_maxima := 1, sustancia: Sustancia = null) -> Utensilio:
	var u := Utensilio.new()
	u.cantidad_contenido = cantidad_contenido
	u.CANTIDAD_MAXIMA_CONTENIDO = cantidad_maxima
	u.sustancia = sustancia
	autofree(u)
	return u


func build_dispensado_fake(nombre := "Dispensado") -> Dispensado:
	var d := Dispensado.new()
	d.info = Informacion.new()
	d.info.nombre = nombre
	add_child_autofree(d)
	return d


# Comprobar que las sustancias se registran correctamente
# misma sustancia consecutiva => agrupa
# sustancia distinta => nueva entrada
# misma sustancia no consecutiva => no agrupa
func test_1():
	var recipiente := build_recipiente()
	var agua := build_sustancia_fake("Agua")
	var sal := build_sustancia_fake("Sal")
	
	##################################################
	# Registrar una sustancia
	##################################################
	
	assert_true(recipiente.vacio())
	
	recipiente.registrar_sustancia(agua)
	
	assert_false(recipiente.vacio())
	assert_eq(recipiente.sustancias.size(), 1)
	assert_eq(recipiente.sustancias[0]["nombre"], "Agua")
	assert_eq(recipiente.sustancias[0]["veces"], 1)
	assert_eq(recipiente.sustancias[0]["sustancia"], agua)
	
	##################################################
	# Misma sustancia consecutiva => agrupa
	##################################################
	
	recipiente.registrar_sustancia(agua)
	recipiente.registrar_sustancia(agua)
	
	assert_eq(recipiente.sustancias.size(), 1)
	assert_eq(recipiente.sustancias[0]["nombre"], "Agua")
	assert_eq(recipiente.sustancias[0]["veces"], 3)
	
	##################################################
	# Sustancia distinta => nueva entrada
	##################################################
	
	recipiente.registrar_sustancia(sal)
	
	assert_eq(recipiente.sustancias.size(), 2)
	assert_eq(recipiente.sustancias[0]["nombre"], "Agua")
	assert_eq(recipiente.sustancias[1]["nombre"], "Sal")
	assert_eq(recipiente.sustancias[0]["veces"], 3)
	assert_eq(recipiente.sustancias[1]["veces"], 1)
	
	##################################################
	# Misma sustancia no consecutiva => no agrupa
	##################################################
	
	recipiente.registrar_sustancia(agua)
	
	assert_eq(recipiente.sustancias.size(), 3)
	assert_eq(recipiente.sustancias[2]["nombre"], "Agua")
	assert_eq(recipiente.sustancias[2]["veces"], 1)


# Comprobar que las sustancias se aceptan correctamente
# aunque ya no existan (los dispensados se destruyen al mezclar)
func test_2():
	var origen := build_recipiente()
	var agua := build_sustancia_fake("Agua")
	var sal := Sustancia.new()
	sal.info = Informacion.new()
	sal.info.nombre = "Sal"
	
	origen.registrar_sustancia(agua)
	origen.registrar_sustancia(agua)
	origen.registrar_sustancia(sal)
	sal.free() 
	
	var destino := build_recipiente()
	destino.aceptar_sustancias(origen)

	assert_eq(destino.sustancias.size(), 2)
	assert_eq(destino.sustancias[0]["nombre"], "Agua")
	assert_eq(destino.sustancias[0]["veces"], 2)
	assert_eq(destino.sustancias[1]["nombre"], "Sal")
	assert_eq(destino.sustancias[1]["veces"], 1)


# Comprobar que vaciar libere las sustancias y vacio tenga estado consistente
func test_3():
	var r := build_recipiente()
	assert_eq(r.sustancias, [])
	assert_true(r.vacio())
	r.registrar_sustancia(build_sustancia_fake())
	assert_ne(r.sustancias, [])
	assert_false(r.vacio())
	r.vaciar()
	assert_eq(r.sustancias, [])
	assert_true(r.vacio())


# Comprobar la recepción de una sustancia líquida (fluido)
# recipiente fluido && sustancia fluido => acepta
# 	sube cantidad liquido
# 	base/liquido se hacen visibles respectivamente cuando corresponde
# 	cantidad recipiente + cantidad sustancia <= CANTIDAD_MAXIMA => acumula
# 	cantidad recipiente + cantidad sustancia > CANTIDAD_MAXIMA => rechaza
# !(recipiente fluido) && sustancia fluido => rechaza
func test_4():
	var recipiente := build_recipiente(true, false, false, true, true)
	recipiente.CANTIDAD_MAXIMA_LIQUIDO = 3
	var liquido := build_sustancia_fake("Agua")
	liquido.fluido = true
	var recipiente_no_liquido := build_recipiente()

	########################################################
	# !(recipiente fluido) && sustancia fluido => rechaza
	########################################################

	assert_false(recipiente_no_liquido.recibir_interaccion(liquido))
	assert_eq(recipiente_no_liquido.cantidad_liquido, 0)
	assert_true(recipiente_no_liquido.vacio())

	########################################################
	# recipiente fluido && sustancia fluido => acepta
	# 	sube cantidad liquido
	# 	base se hace visible
	########################################################

	assert_true(recipiente.recibir_interaccion(liquido))
	assert_eq(recipiente.cantidad_liquido, 1)
	assert_true(recipiente.base.visible)
	assert_false(recipiente.liquido.visible)
	assert_false(recipiente.vacio())

	########################################################
	# recipiente fluido && sustancia fluido => acepta
	# 	liquido se hace visible
	# 	cantidad recipiente + cantidad sustancia <= CANTIDAD_MAXIMA => acumula
	########################################################
	
	assert_true(recipiente.recibir_interaccion(liquido))
	assert_eq(recipiente.cantidad_liquido, 2)
	assert_true(recipiente.base.visible)
	assert_true(recipiente.liquido.visible)
	assert_false(recipiente.vacio())
	assert_true(recipiente.recibir_interaccion(liquido))
	assert_eq(recipiente.cantidad_liquido, 3)
	assert_true(recipiente.base.visible)
	assert_true(recipiente.liquido.visible)
	assert_false(recipiente.vacio())

	########################################################
	# recipiente fluido && sustancia fluido => acepta
	# 	cantidad recipiente + cantidad sustancia > CANTIDAD_MAXIMA => rechaza
	########################################################

	assert_false(recipiente.recibir_interaccion(liquido))
	assert_eq(recipiente.cantidad_liquido, 3)


# Comprobar la recepción de una sustancia sólida (no fluido)
# recipiente sólido && sustancia sólida directa => rechaza
# !(recipiente sólido) => rechaza
func test_5():
	var recipiente := build_recipiente(false, true)
	var solido := build_sustancia_fake("Muestra")
	var recipiente_no_solido := build_recipiente()
 
	###########################################################
	# !(recipiente sólido) => rechaza
	###########################################################
 
	assert_false(recipiente_no_solido.recibir_interaccion(solido))
	assert_eq(recipiente_no_solido.cantidad_contenido, 0)
	assert_true(recipiente_no_solido.vacio())
 
	###########################################################
	# recipiente sólido && sustancia sólida directa => rechaza
	###########################################################
 
	assert_false(recipiente.recibir_interaccion(solido))
	assert_eq(recipiente.cantidad_contenido, 0)
	assert_true(recipiente.vacio())
 

# Comprobar la recepción de un utensilio sólido (no fluido)
# recipiente solido && utensilio no fluido => acepta
# 	sube cantidad contenido
# 	contenido se hace visible
# 	cantidad recipiente + cantidad utensilio <= CANTIDAD_MAXIMA => acumula
# 	cantidad recipiente + cantidad utensilio > CANTIDAD_MAXIMA => rechaza
# !(recipiente solido)
# 	recipiente con líquido => acepta
# 	recipiente vacío => rechaza
# utensilio vacio => rechaza
func test_6():
	var recipiente := build_recipiente(false, true, false, false, false, true)
	recipiente.CANTIDAD_MAXIMA_CONTENIDO = 2.0
	var solido := build_sustancia_fake("Muestra")
	var utensilio_lleno := build_utensilio_fake(1, 1, solido)
 
	########################################################
	# utensilio vacio => rechaza
	########################################################
 
	var utensilio_vacio := build_utensilio_fake(0, 1, solido)
	assert_false(recipiente.recibir_interaccion(utensilio_vacio))
	assert_true(recipiente.vacio())
 
	########################################################
	# !(recipiente solido) && recipiente vacío => rechaza
	########################################################
 
	var recipiente_no_solido := build_recipiente(true)
	assert_false(recipiente_no_solido.recibir_interaccion(utensilio_lleno))
	assert_true(recipiente_no_solido.vacio())
 
	########################################################
	# !(recipiente solido) && recipiente con líquido => acepta
	########################################################
 
	var agua := build_sustancia_fake("Agua")
	agua.fluido = true
	recipiente_no_solido.recibir_interaccion(agua)
	assert_false(recipiente_no_solido.vacio())
	assert_true(recipiente_no_solido.recibir_interaccion(utensilio_lleno))
	assert_eq(recipiente_no_solido.sustancias.back()["nombre"], "Muestra")
 
	########################################################
	# recipiente solido && utensilio no fluido => acepta
	# 	sube cantidad contenido
	# 	contenido se hace visible
	########################################################
 
	assert_true(recipiente.vacio())
	assert_true(recipiente.recibir_interaccion(utensilio_lleno))
	assert_eq(recipiente.cantidad_contenido, 1.0)
	assert_eq(recipiente.contenido.scale, recipiente.escala_contenido * 1.0)
	assert_true(recipiente.contenido.visible)
	assert_false(recipiente.vacio())
	assert_eq(recipiente.sustancias[0]["nombre"], "Muestra")
 

	########################################################
	# recipiente solido && utensilio no fluido => acepta
	# 	cantidad recipiente + cantidad utensilio <= CANTIDAD_MAXIMA => acumula
	########################################################
 
	var utensilio_medio := build_utensilio_fake(1, 2, solido)
 
	assert_true(recipiente.recibir_interaccion(utensilio_medio))
	assert_eq(recipiente.cantidad_contenido, 1.5)
	assert_eq(recipiente.contenido.scale, recipiente.escala_contenido * 1.5)
	assert_true(recipiente.recibir_interaccion(utensilio_medio))
	assert_eq(recipiente.cantidad_contenido, 2.0)
	assert_eq(recipiente.contenido.scale, recipiente.escala_contenido * 2.0)
 
	########################################################
	# recipiente solido && utensilio no fluido => acepta
	# 	cantidad recipiente + cantidad utensilio > CANTIDAD_MAXIMA => rechaza
	########################################################
 
	assert_false(recipiente.recibir_interaccion(utensilio_medio))
	assert_eq(recipiente.cantidad_contenido, 2.0)
 

# Comprobar la recepción de un utensilio líquido (fluido)
# recipiente fluido && utensilio fluido => acepta
# 	sube cantidad liquido
# 	base/liquido se hacen visibles según corresponda
# 	cantidad recipiente + cantidad utensilio <= CANTIDAD_MAXIMA => acumula
# 	cantidad recipiente + cantidad utensilio > CANTIDAD_MAXIMA => rechaza
# !(recipiente fluido) => rechaza
# utensilio vacio => rechaza
func test_7():
	var recipiente := build_recipiente(true, false, false, true, true)
	recipiente.CANTIDAD_MAXIMA_LIQUIDO = 2.0
	var liquido := build_sustancia_fake("Agua")
	liquido.fluido = true
	var utensilio_lleno := build_utensilio_fake(1, 1, liquido)
	utensilio_lleno.fluido = true

	########################################################
	# utensilio vacio => rechaza
	########################################################

	var utensilio_vacio := build_utensilio_fake(0, 1, liquido)
	utensilio_vacio.fluido = true
	assert_false(recipiente.recibir_interaccion(utensilio_vacio))
	assert_true(recipiente.vacio())

	########################################################
	# !(recipiente fluido) => rechaza
	########################################################

	var recipiente_no_fluido := build_recipiente()
	assert_false(recipiente_no_fluido.recibir_interaccion(utensilio_lleno))
	assert_true(recipiente_no_fluido.vacio())

	########################################################
	# recipiente fluido && utensilio fluido => acepta
	# 	sube cantidad liquido
	# 	base se hace visible
	########################################################

	assert_true(recipiente.recibir_interaccion(utensilio_lleno))
	assert_eq(recipiente.cantidad_liquido, 1.0)
	assert_true(recipiente.base.visible)
	assert_false(recipiente.liquido.visible)
	assert_false(recipiente.vacio())
	assert_eq(recipiente.sustancias[0]["nombre"], "Agua")

	########################################################
	# recipiente fluido && utensilio fluido => acepta
	# 	liquido se hace visible
	# 	cantidad recipiente + cantidad utensilio <= CANTIDAD_MAXIMA => acumula
	########################################################

	var utensilio_medio := build_utensilio_fake(1, 2, liquido) # aporta 0.5
	utensilio_medio.fluido = true
	assert_true(recipiente.recibir_interaccion(utensilio_medio))
	assert_eq(recipiente.cantidad_liquido, 1.5)
	assert_true(recipiente.liquido.visible)
	assert_true(recipiente.recibir_interaccion(utensilio_medio))
	assert_eq(recipiente.cantidad_liquido, 2.0)

	########################################################
	# recipiente fluido && utensilio fluido => acepta
	# 	cantidad recipiente + cantidad utensilio > CANTIDAD_MAXIMA => rechaza
	########################################################

	assert_false(recipiente.recibir_interaccion(utensilio_medio))
	assert_eq(recipiente.cantidad_liquido, 2.0)


# Comprobar la recepcion de un recipiente
# origen vacío => rechaza
# liquido en no fluido => rechaza
# contenido en no solido
# 	sin liquido de por medio => rechaza
# 	con liquido en el destino => acepta
# 	con liquido en el origen => acepta
# mismo tipo y con capacidad => acepta
# mismo tipo pero sin capacidad => rechaza
func test_8():
	var recipiente := build_recipiente(true, true, false, true, true, true)
	recipiente.CANTIDAD_MAXIMA_LIQUIDO = 5.0
	recipiente.CANTIDAD_MAXIMA_CONTENIDO = 5.0

	########################################################
	# origen vacío => rechaza
	########################################################

	var origen_vacio := build_recipiente(true, true)
	assert_false(recipiente.recibir_interaccion(origen_vacio))
	assert_true(recipiente.vacio())

	########################################################
	# liquido en no fluido => rechaza
	########################################################

	var recipiente_solido := build_recipiente(false, true, false, false, false, true) # solido, NO fluido
	recipiente_solido.CANTIDAD_MAXIMA_CONTENIDO = 5.0
	
	var origen_mixto := build_recipiente(true, true)
	
	origen_mixto.cantidad_liquido = 1.0
	origen_mixto.cantidad_contenido = 1.0
	origen_mixto.sustancias = [{"sustancia": null, "nombre": "Agua", "veces": 1}, {"sustancia": null, "nombre": "Sal", "veces": 1}]
	assert_false(recipiente_solido.recibir_interaccion(origen_mixto))
	assert_true(recipiente_solido.vacio())
	assert_eq(recipiente_solido.cantidad_contenido, 0.0)
	
	origen_mixto.cantidad_liquido = 0.0
	origen_mixto.cantidad_contenido = 1.0
	origen_mixto.sustancias = [{"sustancia": null, "nombre": "Sal", "veces": 1}]
	assert_true(recipiente_solido.recibir_interaccion(origen_mixto))
	assert_false(recipiente_solido.vacio())
	assert_eq(recipiente_solido.cantidad_contenido, 1.0)

	########################################################
	# contenido en no solido, sin liquido de por medio => rechaza
	########################################################

	var recipiente_fluido := build_recipiente(true, false, false, true, true)
	recipiente_fluido.CANTIDAD_MAXIMA_LIQUIDO = 5.0
	var origen_solido := build_recipiente(false, true)
	origen_solido.cantidad_contenido = 1.0
	origen_solido.sustancias = [{"sustancia": null, "nombre": "Sal", "veces": 1}]
	
	assert_true(recipiente_fluido.vacio())
	assert_false(recipiente_fluido.recibir_interaccion(origen_solido))
	assert_true(recipiente_fluido.vacio())

	########################################################
	# contenido en no solido, con liquido en el destino => acepta
	########################################################

	recipiente_fluido.cantidad_liquido = 2.0
	assert_true(recipiente_fluido.recibir_interaccion(origen_solido))
	assert_eq(recipiente_fluido.cantidad_liquido, 2.0)
	assert_eq(recipiente_fluido.cantidad_contenido, 1.0)
	assert_false(recipiente_fluido.vacio())
	assert_eq(recipiente_fluido.sustancias.back()["nombre"], "Sal")
	
	########################################################
	# contenido en no solido, con liquido en el origen => acepta
	########################################################
	
	recipiente_fluido.vaciar()
	origen_mixto.cantidad_liquido = 1.0
	origen_mixto.cantidad_contenido = 1.0
	origen_mixto.sustancias = [{"sustancia": null, "nombre": "Agua", "veces": 1}, {"sustancia": null, "nombre": "Sal", "veces": 1}]

	assert_true(recipiente_fluido.vacio())
	assert_true(recipiente_fluido.recibir_interaccion(origen_mixto))
	assert_eq(recipiente_fluido.cantidad_liquido, 1.0)
	assert_eq(recipiente_fluido.cantidad_contenido, 1.0)
	assert_eq(recipiente_fluido.sustancias.size(), 2)
	assert_eq(recipiente_fluido.sustancias[1]["nombre"], "Sal")
	
	########################################################
	# mismo tipo y con capacidad => acepta
	########################################################
	
	var origen_completo := build_recipiente(true, true)
	origen_completo.cantidad_liquido = 2.0
	origen_completo.cantidad_contenido = 1.5
	origen_completo.sustancias = [{"sustancia": null, "nombre": "Agua", "veces": 2}, {"sustancia": null, "nombre": "Arena", "veces": 1}]

	assert_true(recipiente.recibir_interaccion(origen_completo))
	assert_eq(recipiente.cantidad_liquido, 2.0)
	assert_eq(recipiente.cantidad_contenido, 1.5)
	assert_true(recipiente.base.visible)
	assert_true(recipiente.liquido.visible)
	assert_false(recipiente.contenido.visible)
	assert_eq(recipiente.contenido.scale, recipiente.escala_contenido * 1.5)
	assert_eq(recipiente.sustancias.size(), 2)
	
	########################################################
	# mismo tipo pero sin capacidad => rechaza
	########################################################
	
	var origen_excede := build_recipiente(true, true)
	origen_excede.cantidad_liquido = 10.0
	origen_excede.cantidad_contenido = 0.5
	origen_excede.sustancias = [{"sustancia": null, "nombre": "Exceso", "veces": 1}]

	assert_false(recipiente.recibir_interaccion(origen_excede))
	assert_eq(recipiente.cantidad_liquido, 2.0)
	assert_eq(recipiente.cantidad_contenido, 1.5)
	assert_eq(recipiente.sustancias.size(), 2)


# Comprobar la recepción de un dispensado
# recipiente con marker && dispensado => acepta
# recipiente sin marker => rechaza
func test_9():
	var recipiente := build_recipiente(false, false, false, false, false, false, true)
	var dispensado := build_dispensado_fake("Pastilla")

	########################################################
	# recipiente sin marker => rechaza
	########################################################

	var recipiente_sin_marker := build_recipiente()
	var otro_dispensado := build_dispensado_fake("Otro")

	assert_false(recipiente_sin_marker.recibir_interaccion(otro_dispensado))
	assert_true(recipiente_sin_marker.vacio())

	########################################################
	# recipiente con marker && dispensado => acepta
	########################################################

	assert_true(recipiente.recibir_interaccion(dispensado))
	assert_eq(dispensado.get_parent(), recipiente.marker)
	assert_eq(recipiente.marker.get_child_count(), 1)
	assert_false(recipiente.vacio())
	assert_eq(recipiente.sustancias[0]["nombre"], "Pastilla")


# Comprobar que el origen se vacía si el destino lo acepta
func test_10():
	var origen := build_recipiente(true, false, false, true, true)
	origen.cantidad_liquido = 1.0
	origen.sustancias = [{"sustancia": null, "nombre": "Agua", "veces": 1}]

	var destino := build_recipiente(true, false, false, true, true)
	destino.CANTIDAD_MAXIMA_LIQUIDO = 5.0

	origen.interactuar(destino)

	assert_eq(destino.cantidad_liquido, 1.0)
	assert_eq(destino.sustancias[0]["nombre"], "Agua")
	assert_true(origen.vacio())
	assert_eq(origen.cantidad_liquido, 0.0)


# Comprobar que el origen queda intacto si el destino rechaza
func test_11():
	var origen := build_recipiente(true, false, false, true, true)
	origen.cantidad_liquido = 2.0
	origen.sustancias = [{"sustancia": null, "nombre": "Agua", "veces": 1}]

	var destino := build_recipiente(true)
	destino.CANTIDAD_MAXIMA_LIQUIDO = 1.0

	origen.interactuar(destino)

	assert_false(origen.vacio())
	assert_eq(origen.cantidad_liquido, 2.0)
	assert_true(destino.vacio())


# Comprobar qué pasa con lo que hay colocado en el marker del origen
# destino acepta interacción => se reubica
# 	destino sin marker => se destruye
func test_12():
	
	########################################################
	# destino con marker => se reubica
	########################################################

	var origen := build_recipiente(false, true, false, false, false, false, true)
	origen.cantidad_contenido = 1.0
	origen.sustancias = [{"sustancia": null, "nombre": "Arena", "veces": 1}]

	var destino := build_recipiente(false, true, false, false, false, true, true)
	destino.CANTIDAD_MAXIMA_CONTENIDO = 5.0

	var dispensado := Dispensado.new()
	dispensado.info = Informacion.new()
	dispensado.info.nombre = "Pastilla"
	origen.marker.add_child(dispensado)
	autofree(dispensado)

	origen.interactuar(destino)

	assert_false(dispensado.is_queued_for_deletion())
	assert_eq(dispensado.get_parent(), destino.marker)
	assert_eq(destino.marker.get_child_count(), 1)
	assert_eq(origen.marker.get_child_count(), 0)
	assert_eq(destino.sustancias.back()["nombre"], "Pastilla")

	########################################################
	# destino sin marker => se destruye
	########################################################

	origen = build_recipiente(true, false, false, true, true, false, true)
	origen.cantidad_liquido = 1.0
	origen.sustancias = [{"sustancia": null, "nombre": "Agua", "veces": 1}]

	var destino_sin_marker := build_recipiente(true)
	destino_sin_marker.CANTIDAD_MAXIMA_LIQUIDO = 5.0

	dispensado = Dispensado.new()
	dispensado.info = Informacion.new()
	dispensado.info.nombre = "Residuo"
	origen.marker.add_child(dispensado)
	autofree(dispensado)

	origen.interactuar(destino_sin_marker)

	assert_true(dispensado.is_queued_for_deletion())
