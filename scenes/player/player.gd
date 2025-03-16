extends CharacterBody2D
class_name Character


enum State {
	IDLE,
	MOVE,
	SPECIAL,
	HURT,
	DEAD
}




@export var speed: float = 300.0
@export var max_hp: float = 100.0
@export var hp: float = max_hp
@export var armor: float = 0.0
@export var health_regeneration: float = 0.5
@export var level: int = 1
@export var harvesting: float = 1.0

@onready var sprite = $AnimatedSprite2D

signal hp_changed(current_hp, max_hp)
signal level_changed(new_level)
signal died()
signal state_changed(new_state)
signal stats_changed()


var current_state: int = State.IDLE
var previous_state: int = State.IDLE
var is_alive: bool = true
var experience: int = 0
var experience_to_next_level: int = 100

var stat_modifiers: Dictionary = {
	"speed": 0.0,
	"max_hp": 0.0,
	"armor": 0.0,
	"health_regeneration": 0.0,
	"harvesting": 0.0,
	"damage": 0.0,
	"attack_speed": 0.0,
	"critical_chance": 0.0,
	"critical_multiplier": 0.0
}


var special_ability_cooldown: float = 0.0
var special_ability_max_cooldown: float = 5.0
var state_timer: float = 0.0
var attack_cooldown: float = 0.0




func _ready():
	hp = max_hp
	change_state(State.IDLE)
	emit_signal("hp_changed", hp, max_hp)

func _physics_process(delta):
	state_timer -= delta
	if special_ability_cooldown > 0:
		special_ability_cooldown -= delta
	
	
	if is_alive and hp < max_hp:
		regenerate_health(delta)
	
	
	match current_state:
		State.IDLE:
			process_idle_state()
		State.MOVE:
			process_move_state()
		State.SPECIAL:
			process_special_state()
		State.HURT:
			process_hurt_state()
		State.DEAD:
			process_dead_state()
	
	
	if is_alive and current_state != State.HURT and current_state != State.DEAD:
		handle_input()


func process_idle_state():
	velocity = Vector2.ZERO
	sprite_flip()
	var direction = get_movement_input()
	if direction != Vector2.ZERO:
		change_state(State.MOVE)

func process_move_state():
	var direction = get_movement_input()
	if direction == Vector2.ZERO:
		change_state(State.IDLE)
		return
	sprite_flip()
	velocity = direction * (speed + stat_modifiers["speed"])
	move_and_slide()



func process_special_state():
	if state_timer <= 0:
		change_state(State.IDLE)

func process_hurt_state():
	if state_timer <= 0:
		if hp <= 0:
			change_state(State.DEAD)
		else:
			change_state(State.IDLE)

func process_dead_state():
	velocity = Vector2.ZERO
	queue_free()


func get_movement_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func sprite_flip():
	var flip_position = get_global_mouse_position() - global_position
	if flip_position.x >= 0:
		sprite.flip_h = false
	else: 
		sprite.flip_h = true

func handle_input():
	if Input.is_action_just_pressed("right_click") and special_ability_cooldown <= 0:
		use_special_ability()



func change_state(new_state):
	previous_state = current_state
	current_state = new_state
	
	match new_state:
		State.IDLE:
			pass
		State.MOVE:
			pass
		State.SPECIAL:
			state_timer = 1.0 
			special_ability_cooldown = special_ability_max_cooldown
			pass
		State.HURT:
			pass
		State.DEAD:
			pass
	
	emit_signal("state_changed", current_state)




func regenerate_health(delta):
	var regen_amount = (health_regeneration + stat_modifiers["health_regeneration"]) * delta
	var new_hp = min(hp + regen_amount, max_hp + stat_modifiers["max_hp"])
	if new_hp != hp:
		hp = new_hp
		emit_signal("hp_changed", hp, max_hp + stat_modifiers["max_hp"])


func take_damage(damage_amount):
	if not is_alive or current_state == State.DEAD:
		return
	
	var total_armor = armor + stat_modifiers["armor"]
	var actual_damage = max(1, damage_amount * (1 - total_armor / 100))
	hp -= actual_damage
	
	emit_signal("hp_changed", hp, max_hp + stat_modifiers["max_hp"])
	
	change_state(State.HURT)
	
	if hp <= 0:
		die()


func die():
	is_alive = false
	hp = 0
	change_state(State.DEAD)
	emit_signal("died")


func heal(amount):
	if not is_alive or current_state == State.DEAD:
		return
	
	var max_health = max_hp + stat_modifiers["max_hp"]
	hp = min(hp + amount, max_health)
	emit_signal("hp_changed", hp, max_health)


func add_experience(amount):
	if not is_alive:
		return
		
	experience += amount
	if experience >= experience_to_next_level:
		level_up()


func level_up():
	level += 1
	experience -= experience_to_next_level
	experience_to_next_level = int(experience_to_next_level * 1.2)  
	
	
	max_hp += 2
	hp = max_hp + stat_modifiers["max_hp"]
	
	emit_signal("level_changed", level)
	emit_signal("stats_changed")
	
	
	if experience >= experience_to_next_level:
		level_up()



func use_special_ability():
	change_state(State.SPECIAL)



func update_stats_with_modifiers():
	var new_max_hp = max_hp + stat_modifiers["max_hp"]
	if hp > new_max_hp:
		hp = new_max_hp
	
	emit_signal("hp_changed", hp, new_max_hp)

func upgrade_stat(stat_name, amount):
	match stat_name:
		"speed":
			speed += amount
		"max_hp":
			max_hp += amount
			hp += amount
			emit_signal("hp_changed", hp, max_hp + stat_modifiers["max_hp"])
		"armor":
			armor += amount
		"health_regeneration":
			health_regeneration += amount
		"harvesting":
			harvesting += amount
	
	emit_signal("stats_changed")


func get_stat(stat_name):
	match stat_name:
		"speed":
			return speed + stat_modifiers["speed"]
		"max_hp":
			return max_hp + stat_modifiers["max_hp"]
		"hp":
			return hp
		"armor":
			return armor + stat_modifiers["armor"]
		"health_regeneration":
			return health_regeneration + stat_modifiers["health_regeneration"]
		"harvesting":
			return harvesting + stat_modifiers["harvesting"]
	
	return 0
