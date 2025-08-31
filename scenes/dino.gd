extends CharacterBody2D

const GRAVITY: int = 4200
const JUMP_SPEED: int = -1800

func _physics_process(delta: float) -> void:
	# Gravité
	velocity.y += GRAVITY * delta  

	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			$RunCol.disabled = false
			if Input.is_action_just_pressed("ui_accept"): # Saut
				velocity.y = JUMP_SPEED
				$JumpingSound.play()
			elif Input.is_action_pressed("ui_down"): # Accroupi
				$AnimatedSprite2D.play("duck")
				$RunCol.disabled = true
			else: # Course
				$AnimatedSprite2D.play("run")
	else: 
		# En l’air
		$AnimatedSprite2D.play("jump")
	
	# Déplacement avec collisions
	move_and_slide()
