# ============================================================================
# sync_docs.ps1
# Sinkronisasi otomatis: Kanban (.kanban) + Git Log -> CURRENT_STATE.md + ROADMAP.md
#
# Cara pakai:
#   .\sync_docs.ps1                  -> jalan sekali, mode fallback (tanpa AI)
#   .\sync_docs.ps1 -UseGroq         -> coba pakai Groq API dulu untuk matching pintar,
#                                        otomatis fallback ke keyword-matching kalau gagal
#   .\sync_docs.ps1 -Watch           -> jalan terus di background, auto-trigger
#                                        begitu file kanban berubah (drag card, dsb)
#
# Env var opsional (kalau -UseGroq dipakai):
#   $env:GROQ_API_KEY = "gsk_xxx..."
# ============================================================================

param(
    [switch]$UseGroq,
    [switch]$Watch,
    [string]$GroqModel = "llama-3.1-8b-instant"
)

$ErrorActionPreference = "Stop"

$kanbanPath   = "kanban_tasks_data.kanban"
$statePath    = "docs/CURRENT_STATE.md"
$roadmapPath  = "docs/SPIRIT_COVENANT_ROADMAP.md"

# ----------------------------------------------------------------------------
# Util: stopword & tokenizer sederhana untuk keyword matching (mode fallback)
# ----------------------------------------------------------------------------
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
    $overlap = ($TokensA | Where-Object { $setB -contains $_ } | Select-Object -Unique).Count
    return $overlap
}

# ----------------------------------------------------------------------------
# 1. Baca Kanban
# ----------------------------------------------------------------------------
function Read-KanbanData {
    if (-not (Test-Path $kanbanPath)) {
        Write-Host "Error: file kanban tidak ditemukan di $kanbanPath" -ForegroundColor Red
        return $null
    }
    try {
        return Get-Content $kanbanPath -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        Write-Host "Error: gagal parse JSON kanban. $_" -ForegroundColor Red
        return $null
    }
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

# ----------------------------------------------------------------------------
# 2. Baca Roadmap, ekstrak semua checklist item + ID-nya
# ----------------------------------------------------------------------------
function Get-RoadmapItems {
    param([string]$RoadmapText)
    $items = @()
    $lines = $RoadmapText -split "`r?`n"
    foreach ($line in $lines) {
        if ($line -match '^\s*-\s*\[( |x|X)\]\s*(.+?)\s*<!--id:([a-zA-Z0-9_.]+)-->') {
            $isDone = $matches[1] -ne ' '
            $label  = $matches[2]
            $id     = $matches[3]
            $items += [PSCustomObject]@{
                Id     = $id
                Label  = $label
                Done   = $isDone
                Line   = $line
            }
        }
    }
    return $items
}

# ----------------------------------------------------------------------------
# 3. Matching: coba Groq dulu (kalau -UseGroq), fallback ke keyword matching
# ----------------------------------------------------------------------------
function Invoke-GroqMatch {
    param(
        [string]$TaskTitle,
        [string]$TaskDescription,
        [array]$RoadmapItems
    )
    # Hanya kirim item yang BELUM done, supaya hemat token & relevan
    $pending = $RoadmapItems | Where-Object { -not $_.Done }
    if ($pending.Count -eq 0) { return $null }

    $apiKey = $env:GROQ_API_KEY
    if (-not $apiKey) {
        Write-Host "  [AI] GROQ_API_KEY tidak diset, skip ke fallback." -ForegroundColor Yellow
        return $null
    }

    $itemListText = ($pending | ForEach-Object { "$($_.Id): $($_.Label)" }) -join "`n"

    $systemPrompt = "Kamu membantu mencocokkan task development game yang sudah selesai ke item roadmap yang paling sesuai. Balas HANYA dengan id item roadmap yang paling cocok (contoh: fase1.enemy_types), atau balas persis kata NONE kalau tidak ada yang cocok sama sekali. Jangan beri penjelasan tambahan apapun."
    $userPrompt = "Task selesai:`nJudul: $TaskTitle`nDeskripsi: $TaskDescription`n`nDaftar item roadmap yang belum selesai:`n$itemListText`n`nID mana yang paling cocok?"

    $body = @{
        model = $GroqModel
        messages = @(
            @{ role = "system"; content = $systemPrompt },
            @{ role = "user"; content = $userPrompt }
        )
        temperature = 0
        max_tokens = 30
    } | ConvertTo-Json -Depth 5

    try {
        $response = Invoke-RestMethod -Uri "https://api.groq.com/openai/v1/chat/completions" `
            -Method Post `
            -Headers @{ "Authorization" = "Bearer $apiKey"; "Content-Type" = "application/json" } `
            -Body $body `
            -TimeoutSec 10

        $answer = $response.choices[0].message.content.Trim()
        if ($answer -eq "NONE" -or [string]::IsNullOrWhiteSpace($answer)) { return $null }

        $matchedItem = $pending | Where-Object { $_.Id -eq $answer }
        if ($matchedItem) {
            Write-Host "  [AI] Groq cocokkan ke: $answer" -ForegroundColor Green
            return $answer
        }
        return $null
    } catch {
        Write-Host "  [AI] Groq API gagal/timeout ($($_.Exception.Message)) -> fallback keyword matching." -ForegroundColor Yellow
        return $null
    }
}

function Invoke-KeywordMatch {
    param(
        [string]$TaskTitle,
        [string]$TaskDescription,
        [array]$RoadmapItems
    )
    $pending = $RoadmapItems | Where-Object { -not $_.Done }
    if ($pending.Count -eq 0) { return $null }

    $taskTokens = (Get-Tokens "$TaskTitle $TaskDescription")
    $bestId = $null
    $bestScore = 0

    foreach ($item in $pending) {
        $itemTokens = Get-Tokens $item.Label
        $score = Get-MatchScore -TokensA $taskTokens -TokensB $itemTokens
        if ($score -gt $bestScore) {
            $bestScore = $score
            $bestId = $item.Id
        }
    }

    # Minimal 2 kata yang nyambung biar tidak asal cocok
    if ($bestScore -ge 2) {
        return $bestId
    }
    return $null
}

# ----------------------------------------------------------------------------
# 4. Proses utama: sinkronisasi
# ----------------------------------------------------------------------------
function Sync-Once {
    Write-Host "=== Sync Docs: mulai ===" -ForegroundColor Cyan

    $kanban = Read-KanbanData
    if (-not $kanban) { return }

    $doneTasks  = Get-TasksByStageName -KanbanData $kanban -StageName "Done"
    $todoTasks  = Get-TasksByStageName -KanbanData $kanban -StageName "Todo"
    $doingTasks = Get-TasksByStageName -KanbanData $kanban -StageName "Doing"

    if (-not (Test-Path $roadmapPath)) {
        Write-Host "Error: $roadmapPath tidak ditemukan." -ForegroundColor Red
        return
    }
    $roadmapText = Get-Content $roadmapPath -Raw -Encoding UTF8
    $roadmapItems = Get-RoadmapItems -RoadmapText $roadmapText

    $newlyChecked = @()
    $unplanned    = @()
    $aiAvailable  = $true

    foreach ($task in $doneTasks) {
        $matchedId = $null

        if ($UseGroq) {
            $matchedId = Invoke-GroqMatch -TaskTitle $task.title -TaskDescription $task.description -RoadmapItems $roadmapItems
            if ($null -eq $matchedId -and -not $env:GROQ_API_KEY) { $aiAvailable = $false }
        }

        if (-not $matchedId) {
            $matchedId = Invoke-KeywordMatch -TaskTitle $task.title -TaskDescription $task.description -RoadmapItems $roadmapItems
        }

        if ($matchedId) {
            $item = $roadmapItems | Where-Object { $_.Id -eq $matchedId }
            if ($item -and -not $item.Done) {
                $oldLine = $item.Line
                $newLine = $oldLine -replace '^\s*-\s*\[ \]', '- [x]'
                $roadmapText = $roadmapText.Replace($oldLine, $newLine)
                $item.Done = $true
                $newlyChecked += "$($task.title) -> $matchedId"
                Write-Host "  [MATCH] '$($task.title)' dicentang di roadmap ($matchedId)" -ForegroundColor Green
            }
        } else {
            # Cek apakah task ini sudah pernah dicatat sebagai unplanned sebelumnya
            if ($roadmapText -notmatch [regex]::Escape($task.title)) {
                $unplanned += $task.title
            }
        }
    }

    # Tulis daftar unplanned ke section "Di Luar Rencana Awal"
    if ($unplanned.Count -gt 0) {
        $unplannedBlock = ($unplanned | ForEach-Object { "- $_" }) -join "`n"
        $pattern = '(?s)<!--AUTO_UNPLANNED_START-->.*?<!--AUTO_UNPLANNED_END-->'
        $existingMatch = [regex]::Match($roadmapText, $pattern)
        if ($existingMatch.Success) {
            $existingContent = $existingMatch.Value
            # Ambil daftar lama (kalau ada), gabung dengan yang baru tanpa duplikat
            $oldItems = [regex]::Matches($existingContent, '^- (.+)$', 'Multiline') | ForEach-Object { $_.Groups[1].Value }
            $combined = @($oldItems) + @($unplanned) | Select-Object -Unique
            $combinedBlock = ($combined | ForEach-Object { "- $_" }) -join "`n"
            $newBlock = "<!--AUTO_UNPLANNED_START-->`n$combinedBlock`n<!--AUTO_UNPLANNED_END-->"
            $roadmapText = $roadmapText.Replace($existingContent, $newBlock)
        }
    }

    Set-Content -Path $roadmapPath -Value $roadmapText -Encoding UTF8 -NoNewline
    Write-Host "Roadmap diupdate. Item baru dicentang: $($newlyChecked.Count), item di luar rencana baru: $($unplanned.Count)" -ForegroundColor Cyan

    # ------------------------------------------------------------------------
    # Cari item roadmap yang belum Done DAN belum ada task kanban yang cocok
    # (dipakai untuk "reminder" di CURRENT_STATE, bukan auto-create task)
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
    # 5. Tulis CURRENT_STATE.md
    # ------------------------------------------------------------------------
    $recentCommits = git log -3 --pretty=format:"- %s" 2>$null
    if (-not $recentCommits) { $recentCommits = "- Belum ada commit terbaru." }

    $nextTasksList = @()
    foreach ($t in @($doingTasks) + @($todoTasks)) {
        $nextTasksList += "- [ ] $($t.title.Trim())"
    }
    if ($nextTasksList.Count -eq 0) {
        $nextTasksList = @("- Semua kartu Done! Waktunya tambah task baru di Kanban.")
    }
    $nextTasksBlock = ($nextTasksList | Select-Object -First 5) -join "`n"

    $syncNoteBlock = "- (tidak ada perubahan baru dari sync terakhir)"
    if ($newlyChecked.Count -gt 0 -or $unplanned.Count -gt 0) {
        $lines = @()
        foreach ($c in $newlyChecked) { $lines += "- [x] Roadmap auto-dicentang: $c" }
        foreach ($u in $unplanned) { $lines += "- [+] Dicatat sebagai 'di luar rencana': $u" }
        $syncNoteBlock = $lines -join "`n"
    }

    $orphanBlock = "- (semua item roadmap aktif sudah punya task terkait di Kanban)"
    if ($orphanRoadmapItems.Count -gt 0) {
        $orphanBlock = ($orphanRoadmapItems | Select-Object -First 5 | ForEach-Object { "- $_" }) -join "`n"
    }

    $aiStatusLine = "- [AI SYNC] Mode: keyword-matching (tanpa AI)"
    if ($UseGroq) {
        if ($aiAvailable -and $env:GROQ_API_KEY) {
            $aiStatusLine = "- [AI SYNC] Mode: Groq AI aktif"
        } else {
            $aiStatusLine = "- [AI SYNC] Mode: fallback (Groq tidak merespons/API key kosong) - cek manual disarankan"
        }
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
$aiStatusLine

## [REMINDER] ITEM ROADMAP BELUM ADA TASK KANBAN-NYA
$orphanBlock

## [INFO] CATATAN PENTING
- (Tambahkan catatan manual di sini jika ada bug atau hal yang butuh perhatian khusus)
"@

    $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText((Resolve-Path $statePath), $newState, $Utf8NoBomEncoding)

    Write-Host "=== Sync Docs: selesai ===" -ForegroundColor Green
}

# ----------------------------------------------------------------------------
# 6. Mode -Watch: pantau perubahan file kanban secara terus-menerus
#
# Catatan desain: dipakai polling (cek tiap 2 detik), BUKAN FileSystemWatcher +
# event. FileSystemWatcher dengan Register-ObjectEvent jalan di runspace
# terpisah, jadi pemanggilan fungsi script (Sync-Once) dari dalamnya sering
# gagal diam-diam di berbagai versi PowerShell. Polling lebih lambat sedikit
# tapi jauh lebih bisa diandalkan untuk kasus "drag kartu di Godot" yang tidak
# butuh reaksi instan milidetik.
# ----------------------------------------------------------------------------
function Start-WatchMode {
    Write-Host "Watch mode aktif. Mengecek $kanbanPath tiap 2 detik ..." -ForegroundColor Cyan
    Write-Host "Tekan Ctrl+C untuk berhenti." -ForegroundColor Cyan

    if (-not (Test-Path $kanbanPath)) {
        Write-Host "Error: file kanban tidak ditemukan di $kanbanPath" -ForegroundColor Red
        return
    }

    $lastWriteTime = (Get-Item $kanbanPath).LastWriteTimeUtc

    # Jalankan sekali di awal
    Sync-Once

    while ($true) {
        Start-Sleep -Seconds 2
        if (-not (Test-Path $kanbanPath)) { continue }

        $currentWriteTime = (Get-Item $kanbanPath).LastWriteTimeUtc
        if ($currentWriteTime -ne $lastWriteTime) {
            $lastWriteTime = $currentWriteTime
            Start-Sleep -Milliseconds 300  # beri jeda sedikit, pastikan file selesai ditulis
            Write-Host "`n[Watch] Perubahan terdeteksi di kanban, sync ulang..." -ForegroundColor Magenta
            try {
                Sync-Once
                $lastWriteTime = (Get-Item $kanbanPath).LastWriteTimeUtc
            } catch {
                Write-Host "Sync error: $_" -ForegroundColor Red
            }
        }
    }
}

# ----------------------------------------------------------------------------
# Entry point
# ----------------------------------------------------------------------------
if ($Watch) {
    Start-WatchMode
} else {
    Sync-Once
}
