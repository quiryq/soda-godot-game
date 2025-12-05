extends Node2D



# Основные параметры оружия
@export var base_damage: int = 10
@export var critical_chance: float = 1  # 10% шанс крита
@export var critical_multiplier: float = 1.5
@export var fire_rate: float = 2.0  # Выстрелов в секунду
@export var multishot: int = 1  # Количество пуль за выстрел
@export var bullet_speed: float = 700.0
@export var spread_angle: float = 5.0  # Разброс в градусах
@export var bullet_scene: PackedScene
@export var is_automatic: bool = true

const MOD_SLOTS_COUNT: int = 8
var mod_slots: Array = []  # Будет хранить установленные карточки
var special_effects: Dictionary = {}  # Для хранения специальных эффектов


# Системные переменные
var can_fire: bool = true
var fire_timer: Timer
var character: Node2D
var damage_modifiers: Array = []  # Для временных баффов/дебаффов

func _ready():
	# Создание таймера для скорострельности
	fire_timer = Timer.new()
	fire_timer.wait_time = 1.0 / fire_rate
	fire_timer.one_shot = true
	add_child(fire_timer)
	fire_timer.timeout.connect(_on_fire_cooldown)
	# Инициализация слотов модификаций
	mod_slots.resize(MOD_SLOTS_COUNT)
	for i in range(MOD_SLOTS_COUNT):
		mod_slots[i] = null

func _process(delta: float) -> void:
	look_at(get_global_mouse_position())
	
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1
		
	if Input.is_action_pressed("left_click"):
		attempt_fire()


func setup_weapon(owner_character: Node2D):
	character = owner_character

func attempt_fire() -> bool:
	if can_fire:
		fire()
		return true
	return false

func fire():
	can_fire = false
	fire_timer.start()
	
	# Расчёт модифицированного урона с учётом всех баффов
	var modified_damage = calculate_modified_damage()
	
	# Спавн пуль с учётом мультивыстрела
	for i in range(multishot):
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		
		# Направление с разбросом
		var fire_direction = (get_global_mouse_position() - global_position).normalized()
		if spread_angle > 0:
			var angle = deg_to_rad(spread_angle)
			var random_angle = randf_range(-angle, angle)
			fire_direction = fire_direction.rotated(random_angle)
		
		# Настройка пули с передачей параметров крита
		var is_critical = randf() < critical_chance
		bullet.setup_bullet(
			fire_direction, 
			bullet_speed, 
			modified_damage,
			is_critical,
			critical_multiplier
		)
		bullet.global_position = global_position
		#bullet.add_collision_exception_with(character)
	
	#play_fire_effects()

func calculate_modified_damage() -> int:
	var damage = base_damage
	
	# Применение всех модификаторов урона
	for modifier in damage_modifiers:
		damage = modifier.apply(damage)
	
	return int(damage)

func _on_fire_cooldown():
	can_fire = true

#func play_fire_effects():
	## Визуальные и звуковые эффекты
	#if $MuzzleFlash:
		#$MuzzleFlash.restart()
		#$MuzzleFlash.emitting = true
	#if $FireSound:
		#$FireSound.play()

# Методы для улучшений и временных эффектов
#func add_damage_modifier(modifier: DamageModifier):
	#damage_modifiers.append(modifier)
#
#func remove_damage_modifier(modifier: DamageModifier):
	#damage_modifiers.erase(modifier)

func upgrade(upgrade_type: String, value):
	match upgrade_type:
		"damage":
			base_damage += value
		"critical_chance":
			critical_chance = min(critical_chance + value, 1.0)  # Ограничение до 100%
		"critical_multiplier":
			critical_multiplier += value
		"fire_rate":
			fire_rate += value
			fire_timer.wait_time = 1.0 / fire_rate
		"multishot":
			multishot += value
		"spread":
			spread_angle = max(0, spread_angle - value)  # Уменьшение разброса


func install_mod_card(card: WeaponModCard, slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= MOD_SLOTS_COUNT:
		push_error("Invalid mod slot index")
		return false
	
	# Если слот уже занят, сначала снимаем старую карточку
	if mod_slots[slot_index] != null:
		uninstall_mod_card(slot_index)
	
	# Устанавливаем новую карточку
	mod_slots[slot_index] = card
	card.apply_to_weapon(self)

	return true
func uninstall_mod_card(slot_index: int) -> WeaponModCard:
	if slot_index < 0 or slot_index >= MOD_SLOTS_COUNT:
		push_error("Invalid mod slot index")
		return null
	
	var card = mod_slots[slot_index]
	if card != null:
		card.remove_from_weapon(self)
		mod_slots[slot_index] = null

	
	return card


func get_mod_card(slot_index: int) -> WeaponModCard:
	if slot_index < 0 or slot_index >= MOD_SLOTS_COUNT:
		return null
	return mod_slots[slot_index]
