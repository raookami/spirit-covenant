class_name EnemyData
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export var tier: String = "keroco" # "keroco", "elite", "boss"
@export var element: String = "Neutral" # "Neutral", "Umbra", "Flare", "Tide", "Rime", "Veil"
@export var damage_type: String = "manifest" # "manifest" atau "phantasm"
@export var hp: int = 50
@export var speed: float = 80.0
@export var block_atk: int = 3
@export var manifest_def: int = 0
@export var phantasm_def: int = 0
@export var texture_path: String = ""