class_name StageConfig
extends Resource

# ============================================================
# STAGE CONFIG — data satu stage, dipisah dari hardcode battle.gd
# Cara pakai: buat file .tres baru di /data/, set class_name ini,
# isi field lewat Inspector Godot, lalu load() dari battle.gd
# ============================================================

## Nama/label stage yang muncul di UI (misal "Stage 1 - Hutan Pembuka")
@export var stage_name: String = "Untitled Stage"

## Layout grid map. 0=PATH 1=GROUND 2=HIGH 3=BLOCKED
## Array of Array — tiap row adalah Array[int] sepanjang grid_cols
@export var map_layout: Array = []

## Urutan waypoint musuh, format [[col,row], [col,row], ...]
@export var enemy_path: Array = []

## Jumlah kolom & baris grid (harus konsisten dengan map_layout)
@export var grid_cols: int = 10
@export var grid_rows: int = 5

## HP awal Crystal of Covenant untuk stage ini
@export var crystal_max_hp: int = 10

## Jeda antar spawn musuh (detik)
@export var spawn_interval: float = 3.0

## Total musuh yang akan spawn di stage ini (sinkron dengan jumlah wave)
@export var max_enemies: int = 9

## Data gelombang musuh. Format: [{"type": "grunt", "count": 3}]
## type: string ID yang cocok dengan EnemyData.id ("grunt", "sprinter", "brute")
@export var waves: Array[Dictionary] = []

## CP (Covenant Point) awal saat battle dimulai
@export var cp_start: int = 10

## CP maksimum yang bisa ditampung
@export var cp_max: int = 99

## CP yang regen per detik
@export var cp_regen_rate: float = 1.0