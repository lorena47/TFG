class_name Evento
extends RefCounted


enum Tipo {
	COLOCAR,
	RETIRAR,
	INTERACTUAR,
	VERTER,
	DISPENSAR,
	VACIAR
}


var tipo: Tipo
var objeto: Node = null
var origen: Node = null
var destino: Node = null
var datos := {}


func nombre_tipo() -> String:
	match tipo:
		Tipo.COLOCAR:		return "COLOCAR"
		Tipo.RETIRAR:		return "RETIRAR"
		Tipo.INTERACTUAR:	return "INTERACTUAR"
		Tipo.VERTER:		return "VERTER"
		Tipo.DISPENSAR:		return "DISPENSAR"
		Tipo.VACIAR:		return "VACIAR"
	return "DESCONOCIDO"
