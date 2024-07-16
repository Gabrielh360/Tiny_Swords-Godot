extends Node

@export var mob_spawner: MobSpawner
@export var initial_spawn_rate: float = 60.0
@export var spawn_rate_increase: float = 5.0
@export var wave_duration: float = 30.0
@export var pause_duration: float = 10.0
@export var boss_wave_interval: int = 10

var wave_timer: float = 0.0
var in_pause: bool = false

func _process(delta: float) -> void:
	if GameManager.is_game_over:
		return
	
	if in_pause:
		wave_timer += delta
		if wave_timer >= pause_duration:
			start_next_wave()
	else:
		wave_timer += delta
		if wave_timer >= wave_duration:
			end_wave()
		else:
			update_spawn_rate()

func update_spawn_rate() -> void:
	var base_spawn_rate = initial_spawn_rate + spawn_rate_increase * (GameManager.current_wave - 1)
	mob_spawner.mobs_por_minuts = base_spawn_rate

func start_next_wave() -> void:
	in_pause = false
	wave_timer = 0.0
	GameManager.current_wave += 1
	if GameManager.current_wave % boss_wave_interval == 0:
		spawn_boss()

func end_wave() -> void:
	in_pause = true
	wave_timer = 0.0
	# Aqui você pode adicionar lógica para upgrades ou loja

func spawn_boss() -> void:
	# Adicione a lógica de spawn de boss aqui
	pass
