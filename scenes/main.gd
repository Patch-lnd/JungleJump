extends Node
#Prelaod Obstacles
var stump_scene = preload("res://scenes/stump.tscn")
var stump2_scene = preload("res://scenes/stump2.tscn")
var stump3_scene = preload("res://scenes/stump3.tscn")
var obstacle_types:= [stump_scene, stump2_scene, stump3_scene]
var obstacles: Array
var bird_heights := [200, 300]


#game variables
const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var difficulty
const MAX_DIFFICULTY : int = 2
var score: int
var SCORE_MODIFIER: int = 10
var high_score: int 
var speed: float 
var SPEED_MODIFIER: int = 5000
const START_SPEED: float = 10.0
const Max_SPEED : int = 21
var screen_size : Vector2i
var ground_height : int
var game_running: bool 
var last_obs

func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	# Reset Variables
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	# Delete all obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	# Définir la position du sol et de la caméra
	$Ground.position = Vector2.ZERO
	$Camera2D.position = CAM_START_POS
	
	# Positionner le joueur légèrement derrière la caméra
	# dino_x_offset = distance derrière la caméra
	# dino_height_offset = hauteur par rapport au sol pour que le Dino ne tombe pas
	var dino_x_offset = 150
	var dino_height_offset = 50
	$Dino.position = Vector2($Camera2D.position.x - dino_x_offset, $Ground.position.y - dino_height_offset)
	$Dino.velocity = Vector2.ZERO  # réinitialiser la vélocité
	
	# Reset HUD (Heads Up Display) et écran Game Over
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()



func _process(delta):
	if game_running:
		#Speed up and adjust difficulty
		speed = START_SPEED + (score/SPEED_MODIFIER)
		#Genere les obstacles CORRECTION APPORT
		generate_obs()
		if speed > Max_SPEED: 
			speed = Max_SPEED
		adjust_difficulty()
		
		#Move Dino Camera
		$Dino.position.x += speed
		$Camera2D.position.x += speed
		
		#Update score 
		score += speed/2
		show_score()


		#Update the ground Position (advance half width)
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.3:
			$Ground.position.x += screen_size.x / 2
			
		#Remove the Obstacles off the screen once theve past
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_just_pressed("ui_accept"):
			game_running = true 
			$HUD.get_node("StartLabel").hide()
func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < $Camera2D.position.x + 400:  
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_scale = obs.get_node("Sprite2D").scale
			
			var obs_x : int = $Camera2D.position.x + screen_size.x + 50 + (i * 120)
			var obs_y : int = screen_size.y - ground_height - (obs_scale.y/2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		
		# Ajouter chance d'avoir un obstacle volant
		#Se sont les obstacles volant, a ajouter une fois que on a mis le mode descendre du Dino
		#if difficulty == MAX_DIFFICULTY:
		#	if (randi() % 2) == 0:
		#		obs = stump3_scene.instantiate()
		#		var obs_x: int = $Camera2D.position.x + screen_size.x + 50  # devant la caméra
		#		var obs_y: int = bird_heights[randi() % bird_heights.size()]
		#		add_obs(obs, obs_x, obs_y)


func add_obs(obs, x, y):
	obs.position = Vector2(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
	
func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body):
	if body.name == "Dino":
		game_over()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score/SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = " HIGH SCORE: " + str(high_score/SCORE_MODIFIER)


func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY
		
func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
