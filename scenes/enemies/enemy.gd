class_name Enemy
extends CharacterBody2D

enum State {
	CHASE,
	ATTACK,
	DEAD
}

@export var move_speed: float = 120.0
@export var health: int = 50
@export var attack_damage: int = 1
@export var attack_range: float = 10
@export var attack_cooldown: float = 1


var current_state: State = State.CHASE
var player: Node2D
var can_attack: bool = true


@onready var attack_timer = $AttackTimer
@onready var sprite = $sprite


func _ready():
	
	player = get_tree().get_first_node_in_group("player")
	attack_timer.wait_time = attack_cooldown
	attack_timer.timeout.connect(_on_attack_timer_timeout)

func _physics_process(delta):
	if !player or current_state == State.DEAD:
		return
	
	match current_state:
		State.CHASE:
			handle_chase_state(delta)
		State.ATTACK:
			handle_attack_state()

func handle_chase_state(delta):
	
	var direction = (player.global_position - global_position).normalized()
	
	
	velocity = direction * move_speed
	move_and_slide()
	
	
	sprite.flip_h = direction.x < 0
	
	
	if global_position.distance_to(player.global_position) <= attack_range:
		change_state(State.ATTACK)

func handle_attack_state():
	if can_attack:
		perform_attack()
		can_attack = false
		attack_timer.start()

func perform_attack():
	
	if player.has_method("take_damage"):
		player.take_damage(attack_damage)
	

	
	
	if global_position.distance_to(player.global_position) > attack_range * 1.2:
		change_state(State.CHASE)

func take_damage(damage: int):
	if current_state == State.DEAD:
		return
	
	health -= damage

	
	if health <= 0:
		die()

func die():
	change_state(State.DEAD)
	queue_free()

func change_state(new_state: State):
	if current_state != new_state:
		current_state = new_state
		

func _on_attack_timer_timeout():
	can_attack = true
