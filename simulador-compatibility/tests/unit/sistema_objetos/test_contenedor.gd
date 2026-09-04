extends GutTest


func build_contenedor(dispensador := false, contenido: PackedScene = null) -> Contenedor:
	var c := Contenedor.new()
	c.dispensador = dispensador
	c.contenido = contenido

	var marker := Marker3D.new(); marker.name = "Marker3D"
	c.add_child(marker)

	add_child_autofree(c)
	return c


func build_recipiente_fake(fluido := false) -> Recipiente:
	var r := Recipiente.new()
	r.fluido = fluido
	add_child_autofree(r)
	return r


func build_sustancia_fake(nombre := "Sustancia", fluido := false) -> Sustancia:
	var s := Sustancia.new()
	s.info = Informacion.new()
	s.info.nombre = nombre
	s.fluido = fluido
	autofree(s)
	return s


func build_escena_movil(nombre := "Dispensado") -> PackedScene:
	var nodo := Dispensado.new()
	nodo.name = nombre
	var escena := PackedScene.new()
	escena.pack(nodo)
	nodo.free()
	return escena


# Comprobar cómo se colocan los móviles en el contenedor
# objeto == null || !recipiente || dispensador => rechaza
# !dispensador && recipiente => acepta
func test_1():
	var contenedor := build_contenedor()
	var recipiente := build_recipiente_fake()

	########################################################
	# objeto == null || !recipiente || dispensador => rechaza
	########################################################

	assert_false(contenedor.colocar(null))
	
	var no_recipiente := Movil.new()
	add_child_autofree(no_recipiente)
	assert_false(contenedor.colocar(no_recipiente))
	
	var dispensador := build_contenedor(true)
	assert_false(dispensador.colocar(recipiente))
	assert_ne(recipiente.get_parent(), dispensador.marker)

	########################################################
	# !dispensador && recipiente => acepta
	########################################################

	assert_true(contenedor.colocar(recipiente))
	assert_eq(recipiente.get_parent(), contenedor.marker)
	assert_eq(contenedor.marker.get_child_count(), 1)


# Comprobar cómo se obtiene el objeto
# (!dispensador && marker vacío) || dispensador => null
# !dispensador && marker con objeto => lo devuelve
func test_2():
	var contenedor := build_contenedor()
	var recipiente := build_recipiente_fake()

	########################################################
	# (!dispensador && marker vacío) || dispensador => null
	########################################################

	assert_null(contenedor.obtener_objeto())
	
	var dispensador := build_contenedor(true)
	var otro_recipiente := Recipiente.new()
	autofree(otro_recipiente)
	dispensador.marker.add_child(otro_recipiente)
	assert_null(dispensador.obtener_objeto())

	########################################################
	# !dispensador && marker con objeto => lo devuelve
	########################################################

	contenedor.colocar(recipiente)
	assert_eq(contenedor.obtener_objeto(), recipiente)

	


# Comprobar cuando se recibe una iteracción vacía
# !dispensador => rechaza
# dispensador => dispensa y acepta
func test_3():
	var escena := build_escena_movil()

	########################################################
	# !dispensador => rechaza
	########################################################

	var contenedor := build_contenedor(false, escena)
	assert_false(contenedor.recibir_interaccion(null))
	assert_null(contenedor.objeto_dispensado)

	########################################################
	# dispensador => dispensa y acepta
	########################################################

	var contenedor_dispensador := build_contenedor(true, escena)
	assert_true(contenedor_dispensador.recibir_interaccion(null))
	assert_ne(contenedor_dispensador.objeto_dispensado, null)
	autofree(contenedor_dispensador.objeto_dispensado)


# Comprobar cuando se recibe una iteracción con un objeto
# !dispensador && hay recipiente colocado => se delega
# !dispensador && no hay recipiente colocado => rechaza
# dispensador => rechaza
func test_4():
	var contenedor := build_contenedor()
	var agua := build_sustancia_fake("Agua", true)

	########################################################
	# !dispensador && no hay recipiente colocado => rechaza
	########################################################

	assert_false(contenedor.recibir_interaccion(agua))

	########################################################
	# !dispensador && hay recipiente colocado => se delega
	########################################################

	var recipiente_acepta := build_recipiente_fake(true)
	contenedor.colocar(recipiente_acepta)
	assert_true(contenedor.recibir_interaccion(agua))
	assert_eq(recipiente_acepta.cantidad_liquido, 1.0)

	contenedor = build_contenedor()
	var recipiente_rechaza := build_recipiente_fake(false)
	contenedor.colocar(recipiente_rechaza)
	assert_false(contenedor.recibir_interaccion(agua))

	########################################################
	# dispensador => rechaza
	########################################################

	var dispensador := build_contenedor(true)
	var recipiente := Recipiente.new()
	autofree(recipiente)
	dispensador.marker.add_child(recipiente)
	assert_false(dispensador.recibir_interaccion(agua))


# Comprobar cuando se interactúa
# hay recipiente colocado => se delega
# no hay recipiente colocado => no hace nada
func test_5():
	var contenedor := build_contenedor()
	var agua := build_sustancia_fake("Agua", true)

	########################################################
	# no hay recipiente colocado => no hace nada
	########################################################

	contenedor.interactuar(agua)

	########################################################
	# hay recipiente colocado => se delega
	########################################################

	var destino := build_recipiente_fake(true)
	var origen := build_recipiente_fake(true)
	origen.cantidad_liquido = 1.0
	origen.sustancias = [{"sustancia": null, "nombre": "Agua", "veces": 1}]
	contenedor.colocar(origen)
	contenedor.interactuar(destino)
	assert_eq(destino.cantidad_liquido, 1.0)
	assert_true(origen.vacio())


# Comprobar que se dispensan los móviles
# !dispensador => null
# dispensador => instancia copia
func test_6():
	var escena := build_escena_movil("Reactivo")

	########################################################
	# !dispensador => null
	########################################################

	var contenedor := build_contenedor(false, escena)
	assert_null(contenedor.dispensar())
	assert_null(contenedor.objeto_dispensado)

	########################################################
	# dispensador => instancia copia
	########################################################

	var contenedor_dispensador := build_contenedor(true, escena)
	var copia := contenedor_dispensador.dispensar()
	autofree(copia)

	assert_ne(copia, null)
	assert_eq(copia.get_parent(), contenedor_dispensador.get_parent())
	assert_eq(copia.padre_original, contenedor_dispensador.get_parent())
	assert_eq(contenedor_dispensador.objeto_dispensado, copia)
	assert_eq(copia.global_transform, contenedor_dispensador.marker.global_transform)
