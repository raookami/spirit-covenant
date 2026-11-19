class_name SpiritData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var main_class: String = "Pursuer" # "Pursuer", "Sentinel", "Lurker", "Channeler", "Seer"
@export var element: String = "Umbra" # "Umbra", "Flare", "Tide", "Rime", "Veil"
@export var damage_type: String = "manifest" # "manifest" atau "phantasm"
@export var unit_type: String = "melee" # "melee" atau "ranged"
@export var is_aoe: bool = false
@export var cp_gen_amount: int = 0
@export var cp_gen_interval: float = 0.0
@export var cp_cost: int = 10
@export var block: int = 1
@export var hp: int = 500
@export var atk: int = 50
@export var manifest_def: int = 10
@export var phantasm_def: int = 10
@export var atk_spd: float = 1.0
@export var texture_path: String = ""
@export var attack_patterns: Dictionary = {}