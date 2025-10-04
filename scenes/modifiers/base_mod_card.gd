class_name WeaponModCard
extends Resource

@export var card_name: String = "Mod Card"
@export_multiline var description: String
@export var icon: Texture2D
@export var rarity: int = 1  # 1-Common, 2-Rare, 3-Epic, 4-Legendary

# Эффекты карточки (можно расширять)
@export var damage_bonus: float = 0.0
@export var crit_chance_bonus: float = 0.0
@export var crit_multiplier_bonus: float = 0.0
@export var fire_rate_bonus: float = 0.0
@export var multishot_bonus: int = 0
@export var spread_reduction: float = 0.0
@export var pierce_bonus: int = 0
@export var special_effect: String = ""

# Применение эффекта карточки к оружию
func apply_to_weapon(weapon: Node):
	if damage_bonus != 0:
		weapon.add_damage_modifier(damage_bonus)
	if crit_chance_bonus != 0:
		weapon.critical_chance += crit_chance_bonus
	if crit_multiplier_bonus != 0:
		weapon.critical_multiplier += crit_multiplier_bonus
	if fire_rate_bonus != 0:
		weapon.fire_rate += fire_rate_bonus
		weapon.fire_timer.wait_time = 1.0 / weapon.fire_rate
	if multishot_bonus != 0:
		weapon.multishot += multishot_bonus
	if spread_reduction != 0:
		weapon.spread_angle = max(0, weapon.spread_angle - spread_reduction)
	if pierce_bonus != 0:
		weapon.bullet_scene.pierce_count += pierce_bonus
	if !special_effect.is_empty():
		weapon.add_special_effect(special_effect)

# Отмена эффекта карточки
func remove_from_weapon(weapon: Node):
	if damage_bonus != 0:
		weapon.remove_damage_modifier(damage_bonus)
	if crit_chance_bonus != 0:
		weapon.critical_chance -= crit_chance_bonus
	if crit_multiplier_bonus != 0:
		weapon.critical_multiplier -= crit_multiplier_bonus
	if fire_rate_bonus != 0:
		weapon.fire_rate -= fire_rate_bonus
		weapon.fire_timer.wait_time = 1.0 / weapon.fire_rate
	if multishot_bonus != 0:
		weapon.multishot -= multishot_bonus
	if spread_reduction != 0:
		weapon.spread_angle += spread_reduction
	if pierce_bonus != 0:
		weapon.bullet_scene.pierce_count -= pierce_bonus
	if !special_effect.is_empty():
		weapon.remove_special_effect(special_effect)
