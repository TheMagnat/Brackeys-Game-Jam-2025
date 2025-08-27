@tool class_name Sphere extends Node2D

@export var radius := 16.0

func _ready(): queue_redraw()
func _draw(): draw_circle(Vector2(), radius, Color(1, 1, 1))
