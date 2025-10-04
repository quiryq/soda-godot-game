extends Node2D

# Параметры
var speed: float
var base_damage: int
var is_critical: bool
var critical_multiplier: float
var direction: Vector2
var pierce_count: int = 0
var current_pierce: int = 0

# Системные
var lifetime_timer: Timer

func _ready():
	lifetime_timer = Timer.new()
	lifetime_timer.wait_time = 2.0
	lifetime_timer.one_shot = true
	add_child(lifetime_timer)
	lifetime_timer.start()
	lifetime_timer.timeout.connect(_on_lifetime_timeout)
	
	# Визуальное оформление крита
	if is_critical:
		$Sprite2D.modulate = Color(1.5, 0.8, 0.8)  # Красноватый оттенок
		

func setup_bullet(dir: Vector2, spd: float, dmg: int, critical: bool, crit_mult: float):
	direction = dir.normalized()
	speed = spd
	base_damage = dmg
	is_critical = critical
	critical_multiplier = crit_mult
	rotation = dir.angle()

func _physics_process(delta):
	position += direction * speed * delta
	
#func xx_on_body_entered(body):
	#if body.has_method("take_damage"):
		## Расчёт финального урона с учётом крита
		#var final_damage = base_damage
		#if is_critical:
			#final_damage = int(base_damage * critical_multiplier)
		#
		#body.take_damage(final_damage)
		#
		## Обработка пробивания
		#if pierce_count > 0:
			#current_pierce += 1
			#if current_pierce >= pierce_count:
				#destroy_bullet()
		#else:
			#destroy_bullet()
	#else:
		#destroy_bullet()

func destroy_bullet():
	# Эффект попадания
	queue_free()


func _on_lifetime_timeout():
	destroy_bullet()





func _on_area_2d_body_entered(body: Node2D) -> void:
	print("HELLO")
	if body.has_method("take_damage"):
		# Расчёт финального урона с учётом крита
		var final_damage = base_damage
		if is_critical:
			final_damage = int(base_damage * critical_multiplier)
		
		body.take_damage(final_damage)
		
		# Обработка пробивания
		if pierce_count > 0:
			current_pierce += 1
			if current_pierce >= pierce_count:
				destroy_bullet()
		else:
			destroy_bullet()
	else:
		destroy_bullet()
