extends GutTest


func build_sustancia(fluido := false) -> Sustancia:
	var s := Sustancia.new()
	s.fluido = fluido
	var modelo := Node3D.new(); modelo.name = "modelo"
	var cuerpo := Node3D.new(); cuerpo.name = "cuerpo"
	var tapa := Node3D.new(); tapa.name = "tapa"
	cuerpo.add_child(tapa)
	modelo.add_child(cuerpo)
	s.add_child(modelo)
	add_child_autofree(s)
	return s


# Comprobar al recibir una interacción con la mano vacía,
# la sólida la acepta y se abre y la líquida no
func test_1():
	var solida := build_sustancia()
	var liquida := build_sustancia(true)

	assert_false(solida.abierta)
	assert_false(liquida.abierta)
	assert_true(solida.recibir_interaccion(null))
	assert_false(liquida.recibir_interaccion(null))
	assert_true(solida.abierta)
	assert_false(liquida.abierta)


# Comprobar que con algún objeto en la mano la líquida 
# acepta la interacción aún cerrada
func test_2():
	var liquida := build_sustancia(true)
	var objeto = autofree(Utensilio.new())
	
	assert_false(liquida.abierta)
	assert_true(liquida.recibir_interaccion(objeto))


# Comprobar que con un objeto en la mano la sólida
# acepta si está abierta
# rechaza si está cerrada
func test_3():
	var solida := build_sustancia()
	var objeto = autofree(Utensilio.new())

	assert_false(solida.abierta)
	assert_false(solida.recibir_interaccion(objeto))
	assert_true(solida.recibir_interaccion(null))
	assert_true(solida.abierta)
	assert_true(solida.recibir_interaccion(objeto))
