$content = Get-Content 'y:\pwl\code\plugins\3.6.0.md' -Raw -Encoding UTF8
$lines = $content -split "`r?`n"

# Part A: Lines 1-481
$partA = $lines[0..480]

# Part B: Lines 2005-2072 (old F1.2 completion)
$partB = $lines[2004..2071]

# Part C: Lines 2073-3125 (old F1.3-F5)
$partC = $lines[2072..3124]

# Part D: Lines 482-2004 (new F5.2 completion + F6-F9 + chapters 4-11)
$partD = $lines[481..2003]

# Combine
$result = $partA + $partB + $partC + $partD

# Fix the duplicate if [[ in F5.2
$fixedResult = @()
$skipNext = $false
for ($i = 0; $i -lt $result.Count; $i++) {
    $line = $result[$i]
    if ($line -match '^\s*if \[\[$' -and ($i + 1) -lt $result.Count) {
        $nextLine = $result[$i + 1]
        if ($nextLine -match 'if \[\[.*increasing') {
            continue
        }
    }
    $fixedResult += $line
}

# Fix the corrupted last line of chapter 11
for ($i = 0; $i -lt $fixedResult.Count; $i++) {
    if ($fixedResult[$i] -match '-z \"\$is_allowed\"') {
        $fixedResult[$i] = $fixedResult[$i] -replace '-z \"\$is_allowed\" \]\]\; then', ''
        break
    }
}

# Write with UTF8 BOM
[System.IO.File]::WriteAllLines('y:\pwl\code\plugins\3.6.0.md', $fixedResult, [System.Text.UTF8Encoding]::new($true))

Write-Host "Done! Total lines: $($fixedResult.Count)"