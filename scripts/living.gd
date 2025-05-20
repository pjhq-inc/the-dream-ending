class_name Living
extends CharacterBody3D

@export_category("Living")
@export var max_health = 100


@onready var health = max_health


func damage(amount: float):
	health = clampf(health - amount, 0, max_health)
