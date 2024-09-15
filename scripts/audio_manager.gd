extends Node2D

@onready var engine_audio: AudioStreamPlayer = $EngineAudio
@onready var gun_audio: AudioStreamPlayer = $MachineGunAudio
@onready var hit_audio: AudioStreamPlayer = $HitAudio
@onready var bg_audio: AudioStreamPlayer = $BackgroundMusic

const MENU_MUSIC = preload("res://assets/audio/Alexander Ehlers - Doomed.mp3")
const GARAGE_MUSIC = preload("res://assets/audio/Mech Game.mp3")
const LEVEL_MUSIC = preload("res://assets/audio/3HR.MT_.3.mp3")

const MACHINE_GUN_SHOTS = [
	preload("res://assets/audio/machine_gun/Machine Gun Shot 1.wav"),
	preload("res://assets/audio/machine_gun/Machine Gun Shot 2.wav"),
	preload("res://assets/audio/machine_gun/Machine Gun Shot 3.wav"),
	preload("res://assets/audio/machine_gun/Machine Gun Shot 4.wav"),
	preload("res://assets/audio/machine_gun/Machine Gun Shot 5.wav"),
	preload("res://assets/audio/machine_gun/Machine Gun Shot 6.wav"),
]

const ENEMY_HITS = [
	preload("res://assets/audio/enemy_hit/Body Flesh 1.wav"),
	preload("res://assets/audio/enemy_hit/Body Flesh 2.wav"),
	preload("res://assets/audio/enemy_hit/Body Flesh 3.wav"),
	preload("res://assets/audio/enemy_hit/Body Flesh 4.wav"),
	preload("res://assets/audio/enemy_hit/Body Flesh 5.wav"),
	preload("res://assets/audio/enemy_hit/Body Flesh 6.wav"),
	preload("res://assets/audio/enemy_hit/Body Flesh 7.wav"),
	preload("res://assets/audio/enemy_hit/Body Flesh 8.wav"),
	preload("res://assets/audio/enemy_hit/Body Flesh 9.wav"),
	preload("res://assets/audio/enemy_hit/Body Flesh 10.wav")
]

func play_menu():
	bg_audio.stream = MENU_MUSIC
	bg_audio.play()

func play_garage():
	bg_audio.stream = GARAGE_MUSIC
	bg_audio.play()

func play_level_music():
	bg_audio.stream = LEVEL_MUSIC
	bg_audio.play()

func play_engine():
	engine_audio.play()

func stop_engine():
	engine_audio.stop()

func play_gun():
	gun_audio.stream = MACHINE_GUN_SHOTS.pick_random()
	gun_audio.play()

func play_hit():
	hit_audio.stream = ENEMY_HITS.pick_random()
	hit_audio.play()
