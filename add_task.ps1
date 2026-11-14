# Script untuk Menambahkan Task Baru ke Kanban Godot
param (
    [Parameter(Mandatory=$true)]
    [string]$Title,
    
    [Parameter(Mandatory=$false)]
    [string]$Description = "Task dibuat otomatis via terminal."
)

$kanbanPath = "kanban_tasks_data.kanban"

if (-not (Test-Path $kanbanPath)) {
    Write-Host "Error: File kanban tidak ditemukan!" -ForegroundColor Red
    exit
}

try {
    $json = Get-Content $kanbanPath -Raw -Encoding UTF8 | ConvertFrom-Json
    
    # Generate UUID baru
    $newUuid = [guid]::NewGuid().ToString()
    
    # Buat objek task baru
    $newTask = [PSCustomObject]@{
        uuid = $newUuid
        title = $Title
        description = $Description
        category = $json.categories[0].uuid # Ambil ID kategori pertama
        steps = @()
    }
    
    # 1. Masukkan ke daftar tasks global
    $json.tasks += $newTask
    
    # 2. Masukkan UUID-nya ke kolom "Todo"
    foreach ($stage in $json.stages) {
        if ($stage.title -eq "Todo") {
            $stage.tasks += $newUuid
            break
        }
    }
    
    # Simpan kembali ke JSON
    $json | ConvertTo-Json -Depth 10 | Out-File $kanbanPath -Encoding UTF8
    
    Write-Host "SUKSES! Task '$Title' berhasil ditambahkan ke kolom Todo." -ForegroundColor Green
    Write-Host "Silakan buka Godot untuk melihatnya di Kanban." -ForegroundColor Cyan
} catch {
    Write-Host "Gagal menambahkan task. Cek format JSON Kanban." -ForegroundColor Red
}