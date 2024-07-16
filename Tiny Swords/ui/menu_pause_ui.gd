extends CanvasLayer

@onready var resume_button = $Background/MenuHolderContainer/ResumeButton
@onready var quit_button = $Background/MenuHolderContainer/QuitButton2
@onready var animation_player = $AnimationPlayer

func _ready():
	visible = false


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		visible = true
		animation_player.play("pause_game")
		get_tree().paused = true
		resume_button.grab_focus()
		print("Pause Funcionando!")


func _on_resume_button_pressed():
	animation_player.play("resume_game")
	get_tree().paused = false
	await animation_player.animation_finished
	visible = false


func _on_quit_button_pressed():
	get_tree().quit()
