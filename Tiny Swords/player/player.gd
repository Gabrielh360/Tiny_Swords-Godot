class_name Player

extends CharacterBody2D

@export_category("Moviment")
@export var speed: float = 3
@export_category("Sword")
@export var sword_damage: int = 2
@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30
@export var ritual_scene: PackedScene 
@export_category("Life")
@export var health: int = 100
@export var max_health: int = 100
@export var deadth_prefab: PackedScene 

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer 
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var health_progress_bar: ProgressBar = $HealthProgressBar

var input_vector: Vector2 = Vector2(0, 0) 
var is_running: bool = false
var was_running: bool = false
var is_attacking: bool = false
var attack_cooldown: float = 0.0
var hitbox_cooldown: float = 0.0
var ritual_cooldown: float = 0.0
var combo: int = 0

signal meat_collected(value: int)


func _ready():
	GameManager.player = self
	meat_collected.connect(func(value: int): GameManager.meat_counter += 1)


func _process(delta: float) -> void:
	GameManager.player_position = position
	
	# Ler o Input
	read_input()
	
	# Processar o Ataque
	update_attack_cooldown(delta)
	if Input.is_action_just_pressed("attack"):
		attack()
	
	# Processar Animações e Rotação de Sprite
	play_run_idle_animation()
	if not is_attacking:
		rotate_sprite()
	
	# Processar Dano
	update_hitbox_ditection(delta)
	
	# Ritual
	update_ritual(delta)
	
	# Atualizar Health Bar
	health_progress_bar.max_value = max_health
	health_progress_bar.value = health


func _physics_process(delta: float) -> void:
	# Módificar a velocidade 
	if input_vector != Vector2.ZERO:
		var target_velocity = input_vector * speed * 100.0
		if is_attacking:
			target_velocity *= 0.25
		velocity = lerp(velocity, target_velocity, 0.05)
	else: 
		# Zerar a velocidade quando não há movimento
		velocity = lerp(velocity, Vector2.ZERO, 0.1)
	
	 # Move o personagem usando move_and_slide
	move_and_slide()


func update_attack_cooldown(delta: float):
	# Atualizar Temporizador do Ataque
	if is_attacking:
		attack_cooldown -= delta
		if attack_cooldown <= 0.0:
			is_attacking = false
			is_running = false
			animation_player.play("idle")


func update_ritual(delta: float) -> void:
	# Atualizar Tempporizador do Ataque
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	ritual_cooldown = ritual_interval
	
	# Criar o Ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)


func read_input() -> void:
	# Obter um Input Vector
	input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Apagar DeadZone do Input Vector
	var deadzone = 0.15
	if abs(input_vector.x) < 0.15:
		input_vector.x = 0.0
	if abs(input_vector.y) < 0.15:
		input_vector.y = 0.0
	
	# Atualizar o is_running
	was_running = is_running 
	is_running = not input_vector.is_zero_approx()


func play_run_idle_animation() -> void:
	# Tocar a Animação
	if not is_attacking:
		if was_running != is_running:
			if is_running: 
				animation_player.play("run")
			else:
				animation_player.play("idle")


func rotate_sprite() -> void:
	# Girar o Sprite
	if input_vector.x > 0:
		# Desmarcar o Flip_H do Sprite2D
		sprite.flip_h = false
	elif input_vector.x < 0:
		# Marcar o Flip_H do Sprite2D
		sprite.flip_h = true


func attack() -> void:
	if is_attacking:
		return
	
	# Tocar Animação
	attack_direction()
	#animation_player.play("attack_side_1")
	
	# Configurar Temporizador
	attack_cooldown = 0.6
	
	# Marcar Ataque
	is_attacking = true
	


# Combo e Mudar de Animaçãp de Atack conforme a direção.
func attack_direction():
	#if Input.is_action_pressed("move_up"):
			#if combo == 0:
				#animation_player.play("attack_up_1")
				#combo = 1
			#else:
				#animation_player.play("attack_up_2")
				#combo = 0
	#elif Input.is_action_pressed("move_down"):
			#if combo == 0:
				#animation_player.play("attack_down_1")
				#combo = 1
			#else:
				#animation_player.play("attack_down_2")
				#combo = 0
	if Input.is_action_pressed("attack"):
			if combo == 0:
				animation_player.play("attack_side_1")
				combo = 1
			else:
				animation_player.play("attack_side_2")
				combo = 0
				


func deal_damage_to_enemies() -> void:
	var bodies = sword_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			if sprite.flip_h:
				attack_direction = Vector2.LEFT
			else:
				attack_direction = Vector2.RIGHT
			var dot_product = direction_to_enemy.dot(attack_direction)
			if dot_product > 0.3:
				enemy.damage(sword_damage)


func update_hitbox_ditection(delta: float) -> void:
	# Temporizador
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0: return
	
	 # Frequência do Tempoorizador 
	hitbox_cooldown = 0.5
	
	# Detectar Inimigos
	var bodies = hitbox_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount)


func damage(amount: int) -> void:
	if health <= 0: return
	
	health -= amount
	print("Player recebeu um dano de ", amount, ". A vida total é de ", health)
	
	# Piscar Node
	modulate = Color.RED
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# Processar Morte
	if health <= 0:
		die()


func die() -> void:
	GameManager.end_game()
	
	if deadth_prefab:
		var death_object = deadth_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	print("Player Morreu!")
	queue_free()


func heal(amount: int) -> int:
	health += amount
	if health > max_health: 
		health = max_health
	print("Player recebeu cura de ", amount, ". A vida total é de ", health, " // ", max_health)
	return health

