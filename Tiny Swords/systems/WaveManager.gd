# WaveManager.gd
extends Node

@onready var wave_label: Label = $WaveLabel

@export var wave_duration: float = 30.0 # Duração de cada onda em segundos
@export var time_between_waves: float = 10.0 # Tempo entre ondas
@export var initial_wave_delay: float = 5.0 # Tempo antes da primeira onda começar

var current_wave: int = 0
var wave_timer: float = 0.0
var wave_active: bool = false

signal wave_started(wave: int)
signal wave_ended(wave: int)

func _ready():
	# Começar a primeira onda após um pequeno atraso
	await get_tree().create_timer(1.0).completed;
	start_wave()
	

func _process(delta: float):
	if wave_active:
		wave_timer -= delta
		if wave_timer <= 0:
			end_wave()

func start_wave():
	current_wave += 1
	wave_active = true
	wave_timer = wave_duration
	emit_signal("wave_started", current_wave)
	print("Wave %d started" % current_wave)

func end_wave():
	wave_active = false
	emit_signal("wave_ended", current_wave)
	print("Wave %d ended" % current_wave)
	# Começar a próxima onda após um pequeno atraso
	await get_tree().create_timer(1.5).completed;
	start_wave()
