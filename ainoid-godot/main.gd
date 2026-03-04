extends Node2D

# Game constants
const SCREEN_WIDTH = 480
const SCREEN_HEIGHT = 800
const PADDLE_WIDTH = 80
const PADDLE_HEIGHT = 15
const BALL_RADIUS = 8
const BOSS_WIDTH = 100
const BOSS_HEIGHT = 20
const LASER_WIDTH = 4
const LASER_HEIGHT = 15
const ENEMY_LASER_WIDTH = 5
const ENEMY_LASER_HEIGHT = 10

# Colors
const COLOR_PADDLE = Color(0.0, 0.5, 1.0)  # Blue
const COLOR_BALL = Color(0.0, 0.8, 1.0)    # Cyan
const COLOR_BOSS = Color(0.0, 1.0, 0.0)    # Green
const COLOR_PLAYER_LASER = Color(1.0, 1.0, 0.0)  # Yellow
const COLOR_ENEMY_LASER = Color(1.0, 0.0, 0.0)   # Red

# Game variables
var paddle: CharacterBody2D
var ball: CharacterBody2D
var boss: CharacterBody2D
var lasers: Array = []
var enemy_lasers: Array = []
var ball_velocity: Vector2 = Vector2.ZERO
var ball_active = false
var game_state = "menu"  # menu, playing, gameover
var score = 0
var level = 1
var player_hp = 3
var max_boss_hp = 10
var boss_hp = 10
var can_shoot = true

# Boss AI
var boss_speed = 200.0
var enemy_laser_speed = 300.0
var shoot_interval = 1.0
var last_shot_time = 0.0

# Signals
signal score_changed(new_score)
signal hp_changed(new_hp)
signal level_changed(new_level)
signal boss_hp_changed(current, max)

func _ready():
	# Create background
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1)
	bg.size = Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)
	add_child(bg)
	
	# Show menu
	show_menu()

func show_menu():
	game_state = "menu"
	
	# Title
	var title = Label.new()
	title.text = "AInoid"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.0, 1.0, 0.5))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(SCREEN_WIDTH/2 - 100, 200)
	add_child(title)
	
	# Start button
	var start_btn = Label.new()
	start_btn.text = "TAP TO START"
	start_btn.add_theme_font_size_override("font_size", 24)
	start_btn.add_theme_color_override("font_color", Color.GREEN)
	start_btn.position = Vector2(SCREEN_WIDTH/2 - 80, 400)
	start_btn.name = "start_btn"
	add_child(start_btn)

func _input(event):
	if game_state == "menu":
		if event is InputEventKey and event.pressed:
			start_game()
	elif game_state == "playing":
		# Move paddle with arrow keys
		if event.is_action_pressed("move_left"):
			paddle.velocity.x = -400
		elif event.is_action_pressed("move_right"):
			paddle.velocity.x = 400
		elif event.is_action_released("move_left") or event.is_action_released("move_right"):
			paddle.velocity.x = 0
		
		# Shoot with space
		if event.is_action_pressed("shoot"):
			player_shoot()

func start_game():
	# Clear menu
	for child in get_children():
		if child.name == "start_btn" or child is Label and child.position.y < 300:
			child.queue_free()
	
	game_state = "playing"
	level = 1
	score = 0
	player_hp = 3
	
	setup_game()

func setup_game():
	setup_level_parameters()
	setup_paddle()
	setup_ball()
	setup_boss()
	
	# UI
	setup_ui()

func setup_level_parameters():
	max_boss_hp = 10 + (level - 1) * 10
	boss_hp = max_boss_hp
	boss_speed = 200 + level * 30
	enemy_laser_speed = 300 + level * 40
	shoot_interval = max(0.5, 1.0 - level * 0.05)
	
	emit_signal("boss_hp_changed", boss_hp, max_boss_hp)

func setup_paddle():
	paddle = CharacterBody2D.new()
	
	var rect = ColorRect.new()
	rect.color = COLOR_PADDLE
	rect.size = Vector2(PADDLE_WIDTH, PADDLE_HEIGHT)
	rect.position = Vector2(-PADDLE_WIDTH/2, -PADDLE_HEIGHT/2)
	paddle.add_child(rect)
	
	paddle.position = Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT - 100)
	paddle.collision_layer = 1
	paddle.collision_mask = 1
	add_child(paddle)

func setup_ball():
	ball = CharacterBody2D.new()
	
	var circle = ColorRect.new()
	circle.color = COLOR_BALL
	circle.size = Vector2(BALL_RADIUS * 2, BALL_RADIUS * 2)
	circle.position = Vector2(-BALL_RADIUS, -BALL_RADIUS)
	ball.add_child(circle)
	
	ball.position = Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT - 150)
	ball.collision_layer = 1
	ball.collision_mask = 1
	add_child(ball)

func setup_boss():
	boss = CharacterBody2D.new()
	
	var rect = ColorRect.new()
	rect.color = COLOR_BOSS
	rect.size = Vector2(BOSS_WIDTH, BOSS_HEIGHT)
	rect.position = Vector2(-BOSS_WIDTH/2, -BOSS_HEIGHT/2)
	boss.add_child(rect)
	
	boss.position = Vector2(SCREEN_WIDTH/2, 80)
	boss.collision_layer = 1
	boss.collision_mask = 1
	add_child(boss)

func setup_ui():
	# Score label
	var score_label = Label.new()
	score_label.name = "score_label"
	score_label.text = "Score: 0"
	score_label.add_theme_font_size_override("font_size", 18)
	score_label.position = Vector2(10, 10)
	add_child(score_label)
	
	# Level label
	var level_label = Label.new()
	level_label.name = "level_label"
	level_label.text = "Lv: 1"
	level_label.add_theme_font_size_override("font_size", 18)
	level_label.position = Vector2(10, 35)
	add_child(level_label)
	
	# HP label
	var hp_label = Label.new()
	hp_label.name = "hp_label"
	hp_label.text = "HP: 3"
	hp_label.add_theme_font_size_override("font_size", 18)
	hp_label.position = Vector2(10, 60)
	add_child(hp_label)

func _physics_process(delta):
	if game_state != "playing":
		return
	
	# Move paddle
	paddle.move_and_slide()
	paddle.position.x = clamp(paddle.position.x, PADDLE_WIDTH/2, SCREEN_WIDTH - PADDLE_WIDTH/2)
	
	# Move ball
	if ball_active:
		ball.move_and_slide()
		handle_ball_collisions()
	
	# Boss AI
	update_boss_ai(delta)
	
	# Enemy shooting
	if Time.get_ticks_msec() / 1000.0 - last_shot_time > shoot_interval:
		enemy_shoot()
		last_shot_time = Time.get_ticks_msec() / 1000.0
	
	# Move lasers
	update_lasers(delta)
	
	# Check game conditions
	check_game_conditions()

func handle_ball_collisions():
	# Wall collisions
	if ball.position.x <= BALL_RADIUS or ball.position.x >= SCREEN_WIDTH - BALL_RADIUS:
		ball_velocity.x = -ball_velocity.x
		ball.position.x = clamp(ball.position.x, BALL_RADIUS, SCREEN_WIDTH - BALL_RADIUS)
	
	if ball.position.y <= BALL_RADIUS:
		ball_velocity.y = -ball_velocity.y
		ball.position.y = BALL_RADIUS
	
	# Ball falls below paddle
	if ball.position.y > SCREEN_HEIGHT:
		player_hit()
	
	# Paddle collision
	if ball.get_collision_count() > 0:
		for i in range(ball.get_collision_count()):
			var collider = ball.get_collider(i)
			if collider == paddle:
				ball_velocity.y = -abs(ball_velocity.y)
				# Add angle based on where ball hit paddle
				var hit_pos = (ball.position.x - paddle.position.x) / (PADDLE_WIDTH/2)
				ball_velocity.x += hit_pos * 100
				ball_velocity = ball_velocity.normalized() * 300
	
	# Boss collision
	if ball.get_collision_count() > 0:
		for i in range(ball.get_collision_count()):
			var collider = ball.get_collider(i)
			if collider == boss:
				ball_velocity.y = abs(ball_velocity.y)

func update_boss_ai(delta):
	# Simple AI: follow ball horizontally
	var target_x = ball.position.x
	
	# Add some prediction
	if ball_velocity.y < 0:  # Ball going up
		target_x += ball_velocity.x * 0.5
	
	if boss.position.x < target_x - 10:
		boss.position.x += boss_speed * delta
	elif boss.position.x > target_x + 10:
		boss.position.x -= boss_speed * delta
	
	boss.position.x = clamp(boss.position.x, BOSS_WIDTH/2, SCREEN_WIDTH - BOSS_WIDTH/2)

func player_shoot():
	if not can_shoot:
		return
	
	can_shoot = false
	
	var laser = CharacterBody2D.new()
	var rect = ColorRect.new()
	rect.color = COLOR_PLAYER_LASER
	rect.size = Vector2(LASER_WIDTH, LASER_HEIGHT)
	rect.position = Vector2(-LASER_WIDTH/2, -LASER_HEIGHT)
	laser.add_child(rect)
	
	laser.position = paddle.position + Vector2(0, PADDLE_HEIGHT/2)
	laser.velocity = Vector2(0, -600)
	add_child(laser)
	lasers.append(laser)
	
	# Cooldown
	await get_tree().create_timer(0.3).timeout
	can_shoot = true

func enemy_shoot():
	var laser = CharacterBody2D.new()
	var rect = ColorRect.new()
	rect.color = COLOR_ENEMY_LASER
	rect.size = Vector2(ENEMY_LASER_WIDTH, ENEMY_LASER_HEIGHT)
	rect.position = Vector2(-ENEMY_LASER_WIDTH/2, 0)
	laser.add_child(rect)
	
	laser.position = boss.position - Vector2(0, BOSS_HEIGHT/2)
	laser.velocity = Vector2(0, enemy_laser_speed)
	add_child(laser)
	enemy_lasers.append(laser)

func update_lasers(delta):
	# Player lasers
	for i in range(lasers.size() - 1, -1, -1):
		var laser = lasers[i]
		laser.move_and_slide()
		
		# Check boss collision
		if laser.get_collision_count() > 0:
			for j in range(laser.get_collision_count()):
				if laser.get_collider(j) == boss:
					boss_hp -= 1
					emit_signal("boss_hp_changed", boss_hp, max_boss_hp)
					score += 5
					update_score_label()
					laser.queue_free()
					lasers.remove_at(i)
					break
			continue
		
		# Remove if off screen
		if laser.position.y < 0:
			laser.queue_free()
			lasers.remove_at(i)
	
	# Enemy lasers
	for i in range(enemy_lasers.size() - 1, -1, -1):
		var laser = enemy_lasers[i]
		laser.move_and_slide()
		
		# Check paddle collision
		if laser.get_collision_count() > 0:
			for j in range(laser.get_collision_count()):
				if laser.get_collider(j) == paddle:
					player_hit()
					laser.queue_free()
					enemy_lasers.remove_at(i)
					break
			continue
		
		# Remove if off screen
		if laser.position.y > SCREEN_HEIGHT:
			laser.queue_free()
			enemy_lasers.remove_at(i)

func player_hit():
	player_hp -= 1
	update_hp_label()
	
	if player_hp <= 0:
		game_over()
	else:
		reset_ball()

func reset_ball():
	ball_active = false
	ball.position = Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT - 150)
	ball_velocity = Vector2.ZERO
	
	await get_tree().create_timer(1.0).timeout
	start_ball()

func start_ball():
	var angle = randf_range(-PI/4, PI/4)
	ball_velocity = Vector2(cos(angle), sin(angle)) * 300
	ball_active = true

func check_game_conditions():
	# Win: boss HP = 0
	if boss_hp <= 0:
		level_up()
	
	# Lose handled in player_hit()

func level_up():
	level += 1
	score += 100
	update_level_label()
	update_score_label()
	
	# Clear lasers
	for laser in lasers:
		laser.queue_free()
	lasers.clear()
	
	for laser in enemy_lasers:
		laser.queue_free()
	enemy_lasers.clear()
	
	# Setup new level
	setup_level_parameters()
	
	# Reset positions
	ball.position = Vector2(SCREEN_WIDTH/2, SCREEN_HEIGHT - 150)
	ball_velocity = Vector2.ZERO
	ball_active = false
	boss.position = Vector2(SCREEN_WIDTH/2, 80)
	
	await get_tree().create_timer(1.0).timeout
	start_ball()

func game_over():
	game_state = "gameover"
	
	# Show game over text
	var go_label = Label.new()
	go_label.text = "GAME OVER\nScore: \(score)\nTap to restart"
	go_label.add_theme_font_size_override("font_size", 32)
	go_label.add_theme_color_override("font_color", Color.RED)
	go_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_label.position = Vector2(SCREEN_WIDTH/2 - 100, SCREEN_HEIGHT/2 - 50)
	go_label.name = "game_over"
	add_child(go_label)

func update_score_label():
	var label = get_node_or_null("score_label")
	if label:
		label.text = "Score: \(score)"

func update_level_label():
	var label = get_node_or_null("level_label")
	if label:
		label.text = "Lv: \(level)"

func update_hp_label():
	var label = get_node_or_null("hp_label")
	if label:
		label.text = "HP: \(player_hp)"
