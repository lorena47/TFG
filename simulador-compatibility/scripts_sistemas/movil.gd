class_name Movil
extends RigidBody3D
@export var info: Informacion

@export var rotacion_mano := Vector3.ZERO
@export var desplazamiento_mano := Vector3.ZERO
@export var escala_mano := Vector3.ONE
@export var altura_apoyo := 0.20

var transform_reposo : Transform3D
var escala_reposo : Vector3
var padre_original : Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	transform_reposo = global_transform
	escala_reposo = global_basis.get_scale()


func interactuar(objeto: Node3D = null):
	pass


func recibir_interaccion(objeto: Node3D = null) -> bool:
	return false


func coger(anclaje: Node):
	if padre_original == null:
		padre_original = get_parent()
			
	freeze = true
	$CollisionShape3D.disabled = true

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	cambiar_padre(anclaje)
	Gestor.pausar()
	await _animar_coger().finished
	Gestor.reanudar()


func soltar(posicion: Vector3):
	cambiar_padre(padre_original)
	global_position = posicion + Vector3.UP * altura_apoyo
	Gestor.pausar()
	await _animar_soltar().finished
	Gestor.reanudar()

	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	$CollisionShape3D.disabled = false
	freeze = false
	scale = Vector3.ONE


func cambiar_padre(nuevo_padre: Node):
	var t = global_transform
	get_parent().remove_child(self)
	nuevo_padre.add_child(self)
	global_transform = t


func escalar_original(escala: Vector3):
	scale = Vector3(
		escala_reposo.x / escala.x,
		escala_reposo.y / escala.y,
		escala_reposo.z / escala.z
	)
	position = Vector3.ZERO
	rotation = Vector3.ZERO


func _animar_coger():
 
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
 
	tween.parallel().tween_property(
		self,
		"position",
		desplazamiento_mano,
		0.25
	)
 
	tween.parallel().tween_property(
		self,
		"basis",
		Basis.from_euler(Vector3(
			deg_to_rad(rotacion_mano.x),
			deg_to_rad(rotacion_mano.y),
			deg_to_rad(rotacion_mano.z)
		)),
		0.25
	)
 
	tween.parallel().tween_property(
		self,
		"scale",
		escala_mano,
		0.25
	)
 
	return tween
 
 
func _animar_soltar() -> Tween:
 
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
 
	tween.parallel().tween_property(
		self,
		"global_basis",
		transform_reposo.basis,
		0.20
	)
 
	return tween


func texto_coger() -> String:
	return "Coger"


func texto_soltar() -> String:
	return "Soltar"


func texto_interaccion(objeto: Node3D = null) -> String:
	return ""


func puede_recibir(objeto: Node3D = null) -> bool:
	return false
