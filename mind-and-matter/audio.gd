extends Node

func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton) and event.pressed:
		if $AmbientMusic.stream and not $AmbientMusic.playing:
			$AmbientMusic.play()

func play_phone() -> void:
	if $PhoneSFX.stream:
		$PhoneSFX.play()

func play_paper() -> void:
	if $PaperSFX.stream:
		$PaperSFX.play()

func play_unlock() -> void:
	if $UnlockSFX.stream:
		$UnlockSFX.play()

func play_error() -> void:
	if $ErrorSFX.stream:
		$ErrorSFX.play()
