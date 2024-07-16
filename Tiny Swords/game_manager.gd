extends Node

signal game_over

var player: Player
var player_position: Vector2
var is_game_over: bool = false

var time_elapsed: float = 0.0
var time_elapsed_string: String
var meat_counter: int = 0
var monsters_defeated__counter: int = 0

var current_wave: int = 1
var wave_duration = 10.0  # Tempo de duração de cada wave (em segundos)
var wave_timer = 0.0

func _process(delta: float):
	# Update timer
	time_elapsed += delta
	var time_elapsed_in_seconds: int = floori(time_elapsed)
	var seconds: int = time_elapsed_in_seconds % 60
	var minutes: int = time_elapsed_in_seconds / 60
	time_elapsed_string = "%02d:%02d" % [minutes, seconds]


func end_game():
	if is_game_over: return
	is_game_over = true
	game_over.emit()

func reset():
	player = null
	player_position = Vector2.ZERO
	is_game_over = false
	current_wave = 1
	
	time_elapsed = 0.0
	time_elapsed_string = "00:00"
	meat_counter = 0
	monsters_defeated__counter = 0
	
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)
