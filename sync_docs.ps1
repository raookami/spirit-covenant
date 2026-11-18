# ============================================================================
# sync_docs.ps1 (THE ULTIMATE NO-TOUCH VERSION)
# Kamu cuma sentuh Kanban. Skrip ini yang ngurus dokumen & roadmap.
# ============================================================================

param(
    [switch]$Watch
)

$ErrorActionPreference = "Stop"

$kanbanPath   = "kanban_tasks_data.kanban"
$statePath    = "docs/CURRENT_STATE.md"
$roadmapPath  = "docs/SPIRIT_COVENANT_ROADMAP.md"

# --- UTIL: Pembersih Kata ---
$StopWords = @(
    "dan","di","ke","dari","yang","untuk","dengan","sudah","belum","atau",
    "the","a","an","to","of","in","on","for","is","are","be","it","this","that",
    "saat","ini","itu","ada","bisa","akan","per","nya","kita","kamu","target",
    "langkah","pertama"
)

function Get-Tokens {
    param([string]$Text)
    if (-not $Text) { return @() }
    $clean = ($Text.ToLower() -replace '[^a-z0-9\s]', ' ')
    return $clean -split '\s+' | Where-Object { $_.Length -gt 2 -and ($StopWords -notcontains $_) }
}

function Get-MatchScore {
    param([string[]]$TokensA, [string[]]$TokensB)
    if ($TokensA.Count -eq 0 -or $TokensB.Count -eq 0) { return 0 }
    $setB = $TokensB | Select-Object -Unique
    return ($TokensA | Where-Object { $setB -contains $_ } | Select-Object -Unique).Count
}

# --- UTIL: Baca File ---
function Read-KanbanData {
    if (-not (Test-Path $kanbanPath)) { return $null }
    try { return Get-Content $kanbanPath -Raw -Encoding UTF8 | ConvertFrom-Json } catch { return $null }
}

function Get-TasksByStageName {
    param($KanbanData, [string]$StageName)
    $result = @()
    foreach ($stage in $KanbanData.stages) {
        if ($stage.title -eq $StageName) {
            foreach ($uuid in $stage.tasks) {
                $task = $KanbanData.tasks | Where-Object { $_.uuid -eq $uuid }
                if ($task) { $result += $task }
            }
        }
    }
    return $result
}

function Get-RoadmapItems {
    param([string]$RoadmapText)
    $items = @()
    foreach ($line in ($RoadmapText -split "`r?`n")) {
        if ($line -match '^\s*-\s*\[( |x|X)\]\s*(.+?)\s*<!--id:([a-zA-Z0-9_.]+)-->') {
            $items += [PSCustomObject]@{
                Id     = $matches[3]
                Label  = $matches[2]
                Done   = ($matches[1] -ne ' ')
                Line   = $line
            }
        }
    }
    return $items
}

# --- FITUR 1: ROADMAP -> KANBAN ---
function Sync-RoadmapToKanban {
    param($KanbanData, $RoadmapItems)
    $updated = $false
    $todoStage = $KanbanData.stages | Where-Object { $_.title -eq "Todo" }
    if (-not $todoStage) { return $false }
    
    $categoryUuid = $KanbanData.categories[0].uuid

    foreach ($item in ($RoadmapItems | Where-Object { -not $_.Done })) {
        # Jika task belum ada di Kanban sama sekali
        $exists = $KanbanData.tasks | Where-Object { $_.title -eq $item.Label }
        
        if (-not $exists) {
            $newUuid = [guid]::NewGuid().ToString()
            $newTask = [PSCustomObject]@{
                uuid = $newUuid
                title = $item.Label
                description = "Otomatis dari Roadmap. (ID: $($item.Id))"
                category = $categoryUuid
                steps = @()
            }
            $KanbanData.tasks += $newTask
            $todoStage.tasks += $newUuid
            $updated = $true
            Write-Host "  [KANBAN] + Task baru di Todo: $($item.Label)" -ForegroundColor Yellow
        }
    }
    return $updated
}

# --- FITUR 2: KANBAN -> ROADMAP (Pintar & Aman) ---
function Get-SafeMatch {
    param($Task, $AllRoadmapItems)
    $taskTokens = Get-Tokens "$($Task.title) $($Task.description)"
    $bestScore = 0
    $bestItem = $null

    # Cari kecocokan terhadap SEMUA item (baik yang [ ] maupun [x])
    foreach ($item in $AllRoadmapItems) {
        $score = Get-MatchScore -TokensA $taskTokens -TokensB (Get-Tokens $item.Label)
        if ($score -gt $bestScore) {
            $bestScore = $score
            $bestItem = $item
        }
    }

    # Minimal 2 kata kunci nyambung
    if ($bestScore -ge 2) {
        return $bestItem
    }
    return $null
}

# --- PROSES UTAMA ---
function Sync-Once {
    Write-Host "=== Sync Docs: mulai ===" -ForegroundColor Cyan

    if (-not (Test-Path $roadmapPath)) { return }
    $roadmapText = Get-Content $roadmapPath -Raw -Encoding UTF8
    $roadmapItems = Get-RoadmapItems -RoadmapText $roadmapText
    $kanban = Read-KanbanData

    if (-not $kanban) { return }

    # 1. Tarik Roadmap ke Kanban
    if (Sync-RoadmapToKanban -KanbanData $kanban -RoadmapItems $roadmapItems) {
        $kanban | ConvertTo-Json -Depth 10 | Out-File $kanbanPath -Encoding UTF8
        $kanban = Read-KanbanData # Baca ulang
    }

    $doneTasks  = Get-TasksByStageName -KanbanData $kanban -StageName "Done"
    $todoTasks  = Get-TasksByStageName -KanbanData $kanban -StageName "Todo"
    $doingTasks = Get-TasksByStageName -KanbanData $kanban -StageName "Doing"

    $newlyChecked = @()
    $unplanned    = @()

    # 2. Tarik Kanban (Done) ke Roadmap
    foreach ($task in $doneTasks) {
        $matchedItem = Get-SafeMatch -Task $task -AllRoadmapItems $roadmapItems
        
        if ($matchedItem) {
            if (-not $matchedItem.Done) {
                # Centang jika belum selesai
                $newLine = $matchedItem.Line -replace '^\s*-\s*\[ \]', '- [x]'
                $roadmapText = $roadmapText.Replace($matchedItem.Line, $newLine)
                $matchedItem.Done = $true
                $newlyChecked += "$($task.title) -> $($matchedItem.Id)"
                Write-Host "  [MATCH] '$($task.title)' dicentang di Roadmap" -ForegroundColor Green
            }
            # Jika sudah Done, diamkan (jangan cari match lain).
        } else {
            # Jika tidak ada di roadmap, catat sebagai ide baru
            if ($roadmapText -notmatch [regex]::Escape($task.title)) {
                $unplanned += $task.title
            }
        }
    }

    # Tulis ide baru ke bagian "Di Luar Rencana"
    if ($unplanned.Count -gt 0) {
        $pattern = '(?s)<!--AUTO_UNPLANNED_START-->.*?<!--AUTO_UNPLANNED_END-->'
        $match = [regex]::Match($roadmapText, $pattern)
        if ($match.Success) {
            $oldItems = [regex]::Matches($match.Value, '^- (.+)$', 'Multiline') | ForEach-Object { $_.Groups[1].Value }
            $combined = @($oldItems) + @($unplanned) | Select-Object -Unique
            $newBlock = "<!--AUTO_UNPLANNED_START-->`n" + (($combined | ForEach-Object { "- $_" }) -join "`n") + "`n<!--AUTO_UNPLANNED_END-->"
            $roadmapText = $roadmapText.Replace($match.Value, $newBlock)
            Write-Host "  [UNPLANNED] Ide baru dicatat ke Roadmap." -ForegroundColor Magenta
        }
    }

    Set-Content -Path $roadmapPath -Value $roadmapText -Encoding UTF8 -NoNewline

    # 3. Update CURRENT_STATE.md
    $recentCommits = git log -3 --pretty=format:"- %s" 2>$null
    if (-not $recentCommits) { $recentCommits = "- Belum ada commit." }

    $nextTasksList = @()
    foreach ($t in @($doingTasks) + @($todoTasks)) { $nextTasksList += "- [ ] $($t.title.Trim())" }
    if ($nextTasksList.Count -eq 0) { $nextTasksList = @("- Semua kartu Done!") }

    $syncNote = "- (Tidak ada perubahan baru)"
    if ($newlyChecked.Count -gt 0 -or $unplanned.Count -gt 0) {
        $syncNote = (($newlyChecked | ForEach-Object { "- [x] Roadmap dicentang: $_" }) + ($unplanned | ForEach-Object { "- [+] Ide baru: $_" })) -join "`n"
    }

    $newState = @"
# CURRENT_STATE.md (Auto-Generated)
_Update: $(Get-Date -Format "dd MMM yyyy HH:mm")_

## [LOG] GIT TERAKHIR
$recentCommits

## [NEXT] TASK AKTIF
$($nextTasksList -join "`n")

## [SYNC] HASIL
$syncNote

## [INFO]
- (Catatan manual)
"@
    [System.IO.File]::WriteAllText((Resolve-Path $statePath), $newState, (New-Object System.Text.UTF8Encoding $false))
    Write-Host "=== Sync Selesai ===" -ForegroundColor Green
}

function Start-WatchMode {
    Write-Host "Watch mode aktif. Kamu tinggal drag & drop di Godot. (Ctrl+C untuk stop)" -ForegroundColor Cyan
    $lastWriteTime = (Get-Item $kanbanPath).LastWriteTimeUtc
    Sync-Once
    while ($true) {
        Start-Sleep -Seconds 2
        $currentWriteTime = (Get-Item $kanbanPath).LastWriteTimeUtc
        if ($currentWriteTime -ne $lastWriteTime) {
            $lastWriteTime = $currentWriteTime
            Start-Sleep -Milliseconds 300
            Write-Host "`n[Watch] Kanban berubah, update dokumen..." -ForegroundColor Magenta
            Sync-Once
            $lastWriteTime = (Get-Item $kanbanPath).LastWriteTimeUtc
        }
    }
}

if ($Watch) { Start-WatchMode } else { Sync-Once }