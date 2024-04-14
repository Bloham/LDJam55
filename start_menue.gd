extends Node2D

@onready var animation_player = $CanvasLayer/AnimationPlayer
@onready var info_screen = $CanvasLayer/InfoScreen
@onready var audio_stream_player_2d = $AudioStreamPlayer2D

func _on_play_texture_button_button_down():
	audio_stream_player_2d.play()
	get_tree().change_scene_to_file("res://game_scene.tscn")

func _on_info_texture_button_button_down():
	animation_player.play("fadeIn")
	info_screen.visible = true
	audio_stream_player_2d.play()
	
