extends CharacterBody2D

var max_hp: int = 20
var current_hp: int = max_hp
var max_speed: float = 300


func _process(delta: float) -> void:
	player_movement()



func player_movement():
	var direction:Vector2
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	
	velocity = max_speed * direction.normalized()
	
	move_and_slide()

func player_dash():
	pass
