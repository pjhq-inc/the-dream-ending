extends Node3D


@export var damage: float = 1
@export var max_ammo: int = 6
@export var anim: AnimationPlayer


@onready var ammo: int = max_ammo

var reloading := false
var can_shoot := true

func _ready():
	visibility_changed.connect(on_visibility_changed)

func _input(event: InputEvent) -> void:
	if !visible: return
	if Input.is_action_just_pressed("shoot") and ammo > 0 and can_shoot:
		can_shoot = false
		ammo -= 1
		
		anim.play("shoot")
		get_tree().create_timer(anim.current_animation_length+0.02).timeout.connect(func(): can_shoot = true)
		
		var plr = Global.get_player()
		var n = 0
		for i in plr.hit_area.get_overlapping_bodies():
			if i.is_in_group("Living"):
				i.damage(damage - (n*5))
				n += 1

	if Input.is_action_just_pressed("reload") and ammo != max_ammo and !reloading:
		reloading = true
		reload()

func reload():
	anim.play("reload")
	await anim.animation_finished
	finish_reloading()

func on_visibility_changed():
	anim.play("idle")
	reloading = false

func finish_reloading():
	if reloading:
		anim.play("reload-end")
		await anim.animation_finished
		reloading = false
		if visible:
			ammo = max_ammo
		anim.play("idle")
