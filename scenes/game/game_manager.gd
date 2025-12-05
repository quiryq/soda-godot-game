extends Node2D
class_name GameManager

@export var arena_center: Vector2 = Vector2.ZERO
@export var arena_radius: float = 500.0  # Для совместимости, если нужно
@export var min_dist_to_player: float = 150.0

@onready var spawner: MobSpawner = $MobSpawner
@onready var round_label: Label = $CanvasLayer/RoundLabel
@onready var time_label: Label = $CanvasLayer/TimeLabel
@onready var hp_bar: ProgressBar = $CanvasLayer/HPBar

var round_timer: Timer
var current_round: int = 0  # Старт с 0
var round_duration: float = 10.0
var is_round_active: bool = false

func _ready():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.8, 0.2, 0.2)  # Красный базовый
	$CanvasLayer/HPBar.add_theme_stylebox_override("fill", style)
	round_timer = Timer.new()
	round_timer.wait_time = round_duration
	round_timer.one_shot = true
	round_timer.timeout.connect(_on_round_end)
	add_child(round_timer)
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_signal("hp_changed"):
		player.hp_changed.connect(_on_player_hp_changed)
		
	if hp_bar:
		hp_bar.max_value = player.max_hp if player else 100
		hp_bar.value = player.hp if player else 100
	# Подписка (убрали mob_died)
	if spawner:
		spawner.round_cleared.connect(_on_round_cleared)  # Оставляем для паузы, если нужно
	
	start_new_round()

func start_new_round():
	current_round += 1
	is_round_active = true
	round_timer.start()
	
	# Только частота спавна растёт (меньше = чаще)
	var spawn_interval = max(0.3, 2.0 - 0.3 * current_round)  # 2s → 1.92 → ... → 0.3s
	spawner.set_spawn_interval(spawn_interval)  # Новый метод!
	
	spawner.start_spawning()  # Запуск бесконечного спавна
	
	update_ui()
	print("Round ", current_round, " started! Invterval spawner: ", "%.2f" % spawn_interval, "s")

func _on_round_end():
	is_round_active = false
	spawner.stop_spawning()
	round_label.text = "Round " + str(current_round) + " end!\nJust wait..."
	print("Round ", current_round, " end.")
	await get_tree().create_timer(5).timeout
	start_new_round()

func _on_player_hp_changed(new_hp: float, max_hp: float):
	if hp_bar:
		hp_bar.value = new_hp
		_update_hp_bar_color(new_hp / max_hp)  # Градиент!

func _update_hp_bar_color(ratio: float):  # 1.0=зелёный, 0=красный
	var style = StyleBoxFlat.new()
	var color = Color.RED.lerp(Color.GREEN, ratio)  # Линейный градиент
	style.bg_color = color
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color.WHITE
	hp_bar.add_theme_stylebox_override("fill", style)

func _on_round_cleared():  # Опционально, если хочешь ранний переход (все мобы мертвы — маловероятно)
	pass  # Пока пусто, т.к. бесконечно

func update_ui():
	round_label.text = "Round: " + str(current_round)

func _process(delta):
	if is_round_active:
		time_label.text = str(int(round_timer.time_left)) + "s"
		
