extends Node2D
class_name MobSpawner

signal round_cleared  # Оставляем на всякий

@export var enemy_scene: PackedScene  # Enemy.tscn
@export var spawn_area: Rect2 = Rect2(-400, -300, 800, 600)  # Твоя коробка!
@export var spawn_chance: float = 0.9  # 90% шанс спавна каждый тик (для разнообразия)

var spawn_timer: Timer
var player: Node2D

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_try_spawn)
	add_child(spawn_timer)
	stop_spawning()
	
	player = get_tree().get_first_node_in_group("player")
	if not player:
		print("WARNING: Player не в группе 'player'!")

func set_spawn_interval(new_interval: float):
	spawn_timer.wait_time = new_interval

func start_spawning():
	spawn_timer.start()

func stop_spawning():
	spawn_timer.stop()

func _try_spawn():
	if not get_parent().is_round_active:
		return
	if randf() < spawn_chance:  # Шанс (убери =1.0 для 100%)
		spawn_mob()
	spawn_timer.start()  # Авто-перезапуск

func spawn_mob():
	var attempts = 50  # Больше попыток для надёжности
	while attempts > 0:
		var pos = get_random_pos()
		if player and player.global_position.distance_to(pos) > get_parent().min_dist_to_player:
			var mob = enemy_scene.instantiate()
			mob.global_position = pos
			get_tree().current_scene.add_child(mob)
			# НЕ считаем current_mobs — бесконечно!
			print("Моб заспавнен в раунде ", get_parent().current_round)  # Для дебага
			return
		attempts -= 1
	print("Не удалось найти позицию для спавна!")  # Редко

func get_random_pos() -> Vector2:
	var x = randf_range(spawn_area.position.x, spawn_area.position.x + spawn_area.size.x)
	var y = randf_range(spawn_area.position.y, spawn_area.position.y + spawn_area.size.y)
	return Vector2(x, y)
