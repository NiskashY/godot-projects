extends Node

signal update_health(health)

const kMaxHealth: int = 100
var health: int = kMaxHealth

func getter():
	return health

func setter(value: int):
	var previous_health: int = health
	health = min(kMaxHealth, value)
	health = max(0, health)
	
	if health != previous_health:
		emit_signal("update_health", health)
