extends GutTest


func build_instrumento(con_animation_player := false) -> Instrumento:
	var abuelo := Node3D.new(); abuelo.name = "Abuelo"
	var padre := Node3D.new(); padre.name = "Padre"
	var instrumento := Instrumento.new()

	var marker := Marker3D.new(); marker.name = "Marker3D"
	instrumento.add_child(marker)

	padre.add_child(instrumento)
	abuelo.add_child(padre)

	if con_animation_player:
		var animacion := AnimationPlayer.new()
		animacion.name = "AnimationPlayer"

		var lib := AnimationLibrary.new()
		lib.add_animation("Interaccion", Animation.new())
		animacion.add_animation_library("", lib)

		abuelo.add_child(animacion)
		instrumento.nombre_animacion = "Interaccion"

	add_child_autofree(abuelo)
	return instrumento


func build_movil_fake() -> Movil:
	var m := Movil.new()
	add_child_autofree(m)
	return m


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


# Comprobar cómo se colocan los móviles en el istrumento
# objeto == null => rechaza
# objeto != null => acepta
func test_1():
	var instrumento := build_instrumento()
	var objeto := build_movil_fake()

	########################################################
	# objeto == null => rechaza
	########################################################

	assert_false(instrumento.colocar(null))
	assert_eq(instrumento.marker.get_child_count(), 0)

	########################################################
	# objeto != null => acepta
	########################################################

	assert_true(instrumento.colocar(objeto))
	assert_eq(objeto.get_parent(), instrumento.marker)
	assert_eq(instrumento.marker.get_child_count(), 1)


# Comprobar cómo se obtiene el objeto
# marker vacio => null
# marker con objeto => lo devuelve
func test_2():
	var instrumento := build_instrumento()
	var objeto := build_movil_fake()

	assert_null(instrumento.obtener_objeto())

	instrumento.colocar(objeto)
	assert_eq(instrumento.obtener_objeto(), objeto)


# Comprobar cuando se recibe una iteracción vacía
# sin AnimationPlayer => rechaza
# con AnimationPlayer => acepta
func test_3():

	########################################################
	# sin AnimationPlayer => rechaza
	########################################################

	var instrumento_sin := build_instrumento(false)
	assert_false(await instrumento_sin.recibir_interaccion(null))
	assert_false(instrumento_sin.interaccionado)

	########################################################
	# con AnimationPlayer => acepta
	########################################################

	var instrumento_con := build_instrumento(true)
	assert_false(instrumento_con.interaccionado)
	assert_true(await instrumento_con.recibir_interaccion(null))
	assert_true(instrumento_con.interaccionado)
	assert_true(await instrumento_con.recibir_interaccion(null))
	assert_false(instrumento_con.interaccionado)
	await get_tree().process_frame


# Comprobar cuando se recibe una iteracción con un objeto
# sin móvil colocado => rechaza
# con móvil colocado => se delega
func test_4():
	var instrumento := build_instrumento()
	var agua := build_sustancia_fake("Agua", true)

	########################################################
	# sin móvil colocado => rechaza
	########################################################

	assert_false(await instrumento.recibir_interaccion(agua))

	########################################################
	# con móvil colocado => se delega
	########################################################

	var recipiente_acepta := build_recipiente_fake(true)
	instrumento.colocar(recipiente_acepta)
	assert_true(await instrumento.recibir_interaccion(agua))
	assert_eq(recipiente_acepta.cantidad_liquido, 1.0)

	instrumento = build_instrumento()
	var recipiente_rechaza := build_recipiente_fake(false)
	instrumento.colocar(recipiente_rechaza)
	assert_false(await instrumento.recibir_interaccion(agua))
