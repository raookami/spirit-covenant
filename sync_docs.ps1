# ============================================================================
# sync_docs.ps1 (REVISI - Deterministik via roadmap_id)
# Sinkronisasi otomatis: Kanban (.kanban) + Git Log -> CURRENT_STATE.md + ROADMAP.md
# ============================================================================

param(
    [switch]$Watch
)

$ErrorActionPreference = "Stop"

$kanbanPath   = "kanban_tasks_data.kanban"
$statePath    = "docs/CURRENT_STATE.md"
$roadmapPath  = "docs/SPIRIT_COVENANT_ROADMAP.md"

# Util: stopword & tokenizer (HANYA dipakai untuk fitur REMINDER)
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
    $words = $clean -split '\s+' | Where-Object { $_.Length -gt 2 -and ($StopWords -notcontains $_) }
    return $words
}

function Get-MatchScore {
    param([string[]]$TokensA, [string[]]$TokensB)
    if ($TokensA.Count -eq 0 -or $TokensB.Count -eq 0) { return 0 }
    $setB = $TokensB | Select-Object -Unique
    return ($TokensA | Where-Object { $setB -contains $_ } | Select-Object -Unique).Count
}

# ----------------------------------------------------------------------------
# Baca file
# ----------------------------------------------------------------------------
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
    $lines = $RoadmapText -split "`r?`n"
    foreach ($line in $lines) {
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

# ----------------------------------------------------------------------------
# Proses utama: sinkronisasi
# ----------------------------------------------------------------------------
function Sync-Once {
    Write-Host "=== Sync Docs: mulai ===" -ForegroundColor Cyan

    $kanban = Read-KanbanData
    if (-not $kanban) { return }

    $doneTasks  = Get-TasksByStageName -KanbanData $kanban -StageName "Done"
    $todoTasks  = Get-TasksByStageName -KanbanData $kanban -StageName "Todo"
    $doingTasks = Get-TasksByStageName -KanbanData $kanban -StageName "Doing"

    if (-not (Test-Path $roadmapPath)) { return }
    $roadmapText = Get-Content $roadmapPath -Raw -Encoding UTF8
    $roadmapItems = Get-RoadmapItems -RoadmapText $roadmapText

    $newlyChecked = @()
    $unplanned    = @()
    $syncErrors   = @()

    # LOGIKA BARU: Murni berdasarkan roadmap_id, TIDAK pakai tebak kata
    foreach ($task in $doneTasks) {
        $targetId = if ($task.PSObject.Properties['roadmap_id']) { $task.roadmap_id } else { $null }

        if ([string]::IsNullOrWhiteSpace($targetId)) {
            # Task tidak punya roadmap_id -> masuk daftar "Di Luar Rencana"
            if ($roadmapText -notmatch [regex]::Escape($task.title)) {
                $unplanned += $task.title
            }
        } else {
            # Task punya roadmap_id -> Cari persis ID tersebut di roadmap
            $item = $roadmapItems | Where-Object { $_.Id -eq $targetId }
            if ($item) {
                if (-not $item.Done) {
                    $oldLine = $item.Line
                    $newLine = $oldLine -replace '^\s*-\s*\[ \]', '- [x]'
                    $roadmapText = $roadmapText.Replace($oldLine, $newLine)
                    $item.Done = $true
                    $newlyChecked += "$($task.title) -> $targetId"
                    Write-Host "  [MATCH] '$($task.title)' dicentang di roadmap ($targetId)" -ForegroundColor Green
                }
                # Jika item.Done sudah $true, biarkan saja (berarti sudah pernah disync)
            } else {
                # ID salah ketik atau tidak ada di roadmap
                $syncErrors += "Task '$($task.title)' punya roadmap_id '$targetId', tapi ID itu tidak ditemukan di roadmap."
            }
        }
    }

    # Tulis daftar unplanned ke section "Di Luar Rencana Awal"
    if ($unplanned.Count -gt 0) {
        $pattern = '(?s)<!--AUTO_UNPLANNED_START-->.*?<!--AUTO_UNPLANNED_END-->'
        $existingMatch = [regex]::Match($roadmapText, $pattern)
        if ($existingMatch.Success) {
            $existingContent = $existingMatch.Value
            $oldItems = [regex]::Matches($existingContent, '^- (.+)$', 'Multiline') | ForEach-Object { $_.Groups[1].Value }
            $combined = @($oldItems) + @($unplanned) | Select-Object -Unique
            $combinedBlock = ($combined | ForEach-Object { "- $_" }) -join "`n"
            $newBlock = "<!--AUTO_UNPLANNED_START-->`n$combinedBlock`n<!--AUTO_UNPLANNED_END-->"
            $roadmapText = $roadmapText.Replace($existingContent, $newBlock)
        }
    }

    Set-Content -Path $roadmapPath -Value $roadmapText -Encoding UTF8 -NoNewline
    Write-Host "Roadmap diupdate. Item dicentang: $($newlyChecked.Count), di luar rencana: $($unplanned.Count)" -ForegroundColor Cyan

    # ------------------------------------------------------------------------
    # REMINDER: Cari item roadmap yang belum Done DAN belum ada task kanban-nya
    # ------------------------------------------------------------------------
    $roadmapItemsFresh = Get-RoadmapItems -RoadmapText $roadmapText
    $allKanbanText = (@($doneTasks) + @($todoTasks) + @($doingTasks) | ForEach-Object { "$($_.title) $($_.description)" }) -join " "
    $allKanbanTokens = Get-Tokens $allKanbanText

    $orphanRoadmapItems = @()
    foreach ($item in ($roadmapItemsFresh | Where-Object { -not $_.Done })) {
        $itemTokens = Get-Tokens $item.Label
        $score = Get-MatchScore -TokensA $itemTokens -TokensB $allKanbanTokens
        if ($score -eq 0) {
            $orphanRoadmapItems += $item.Label
        }
    }

    # ------------------------------------------------------------------------
    # Tulis CURRENT_STATE.md
    # ------------------------------------------------------------------------
    $recentCommits = git log -3 --pretty=format:"- %s" 2>$null
    if (-not $recentCommits) { $recentCommits = "- Belum ada commit terbaru." }

    $nextTasksList = @()
    foreach ($t in @($doingTasks) + @($todoTasks)) {
        $nextTasksList += "- [ ] $($t.title.Trim())"
    }
    if ($nextTasksList.Count -eq 0) { $nextTasksList = @("- Semua kartu Done! Waktunya tambah task baru di Kanban.") }
    $nextTasksBlock = ($nextTasksList | Select-Object -First 5) -join "`n"

    $syncNoteBlock = "- (tidak ada perubahan baru dari sync terakhir)"
    if ($newlyChecked.Count -gt 0 -or $unplanned.Count -gt 0 -or $syncErrors.Count -gt 0) {
        $lines = @()
        foreach ($c in $newlyChecked) { $lines += "- [x] Roadmap auto-dicentang: $c" }
        foreach ($u in $unplanned) { $lines += "- [+] Dicatat sebagai 'di luar rencana': $u" }
        foreach ($e in $syncErrors) { $lines += "- [ERROR] $e" }
        $syncNoteBlock = $lines -join "`n"
    }

    $orphanBlock = "- (semua item roadmap aktif sudah punya task terkait di Kanban)"
    if ($orphanRoadmapItems.Count -gt 0) {
        $orphanBlock = ($orphanRoadmapItems | Select-Object -First 5 | ForEach-Object { "- $_" }) -join "`n"
    }

    $newState = @"
# CURRENT_STATE.md (Auto-Generated)
_Update terakhir: $(Get-Date -Format "dd MMM yyyy HH:mm")_

## [LOG] BARU SAJA DIKERJAKAN (Dari Git Log)
$recentCommits

## [NEXT] TASK AKTIF SEKARANG (Dari Kanban: Doing + Todo)
$nextTasksBlock

## [SYNC] HASIL SINKRONISASI TERAKHIR
$syncNoteBlock
- [AI SYNC] Mode: Deterministik (Explicit roadmap_id)

## [REMINDER] ITEM ROADMAP BELUM ADA TASK KANBAN-NYA
$orphanBlock

## [INFO] CATATAN PENTING
- (Tambahkan catatan manual di sini jika ada bug atau hal yang butuh perhatian khusus)
"@

    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText((Resolve-Path $statePath), $newState, $Utf8NoBomEncoding)

    Write-Host "=== Sync Docs: selesai ===" -ForegroundColor Green
}

# Mode Watch
function Start-WatchMode {
    Write-Host "Watch mode aktif. Ctrl+C untuk berhenti." -ForegroundColor Cyan
    if (-not (Test-Path $kanbanPath)) { return }
    $lastWriteTime = (Get-Item $kanbanPath).LastWriteTimeUtc
    Sync-Once

    while ($true) {
        Start-Sleep -Seconds 2
        if (-not (Test-Path $kanbanPath)) { continue }
        $currentWriteTime = (Get-Item $kanbanPath).LastWriteTimeUtc
        if ($currentWriteTime -ne $lastWriteTime) {
            $lastWriteTime = $currentWriteTime
            Start-Sleep -Milliseconds 300
            Write-Host "`n[Watch] Perubahan terdeteksi, sync ulang..." -ForegroundColor Magenta
            try { Sync-Once } catch { Write-Host "Sync error: $_" -ForegroundColor Red }
            $lastWriteTime = (Get-Item $kanbanPath).LastWriteTimeUtc
        }
    }
}

if ($Watch) { Start-WatchMode } else { Sync-Once }