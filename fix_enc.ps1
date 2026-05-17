$content = [System.IO.File]::ReadAllText('y:\pwl\code\plugins\3.6.0.md', [System.Text.UTF8Encoding]::new($false))
[System.IO.File]::WriteAllText('y:\pwl\code\plugins\3.6.0.md', $content, [System.Text.UTF8Encoding]::new($true))
Write-Host "Encoding fixed"