class_name SpiritData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var unit_type: String = "melee" # "melee" atau "ranged"
@export var cost: int = 10
@export var block: int = 1
@export var hp: int = 500
@export var atk: int = 50
@export var phys_def: int = 10
@export var magic_def: int = 10
@export var atk_spd: float = 1.0
@export var texture_path: String = ""
@export var attack_patterns: Dictionary = {}