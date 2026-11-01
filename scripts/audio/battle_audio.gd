class_name BattleAudio
extends Node

const BATTLE_MUSIC_PATH := "res://assets/audio/music/battle_theme.ogg"
const SFX_PATHS := {
	&"attack": "res://assets/audio/sfx/attack.wav",
	&"hit": "res://assets/audio/sfx/hit.wav",
	&"critical": "res://assets/audio/sfx/critical.wav",
	&"miss": "res://assets/audio/sfx/miss.wav",
	&"heal": "res://assets/audio/sfx/heal.wav",
	&"magic": "res://assets/audio/sfx/magic.wav",
	&"buff": "res://assets/audio/sfx/buff.wav",
	&"debuff": "res://assets/audio/sfx/debuff.wav",
	&"victory": "res://assets/audio/sfx/victory.wav",
	&"ui_confirm": "res://assets/audio/sfx/ui_confirm.wav",
	&"ui_cancel": "res://assets/audio/sfx/ui_cancel.wav",
}

@onready var _music_player: AudioStreamPlayer = $MusicPlayer
@onready var _sfx_player: AudioStreamPlayer = $SfxPlayer

func play_battle_music() -> void:
	var stream := _load_optional_audio(BATTLE_MUSIC_PATH)
	if stream == null:
		return

	_configure_music_loop(stream)
	_music_player.stream = stream
	if not _music_player.playing:
		_music_player.play()

func stop_battle_music() -> void:
	_music_player.stop()

func play_sfx(sfx_name: StringName) -> void:
	var path := String(SFX_PATHS.get(sfx_name, ""))
	var stream := _load_optional_audio(path)
	if stream == null:
		return

	_sfx_player.stream = stream
	_sfx_player.play()

func _load_optional_audio(path: String) -> AudioStream:
	if path.is_empty() or not ResourceLoader.exists(path):
		return null

	var resource := ResourceLoader.load(path)
	if resource is AudioStream:
		return resource
	return null

func _configure_music_loop(stream: AudioStream) -> void:
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	elif stream is AudioStreamMP3:
		stream.loop = true
	elif stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
