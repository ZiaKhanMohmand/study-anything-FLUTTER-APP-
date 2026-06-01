$outDir = Join-Path $PSScriptRoot "..\playstore\assets"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

Add-Type -AssemblyName System.Drawing

function Create-Image($path, $width, $height, $bgColor, $title, $subtitle) {
    $bmp = New-Object System.Drawing.Bitmap $width, $height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::FromName($bgColor)  )
    # Draw title
    $fontTitle = New-Object System.Drawing.Font("Arial", 72, [System.Drawing.FontStyle]::Bold)
    $fontSub = New-Object System.Drawing.Font("Arial", 36)
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.DrawString($title, $fontTitle, $brush, 40, 120)
    $g.DrawString($subtitle, $fontSub, $brush, 40, 220)
    # Draw placeholder card
    $cardW = [int]($width * 0.9)
    $cardH = [int]($height * 0.45)
    $cardX = [int](($width - $cardW) / 2)
    $cardY = [int]($height * 0.4)
    $rectBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.FillRectangle($rectBrush, $cardX, $cardY, $cardW, $cardH)
    $blackBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    $g.DrawString("Screenshot Placeholder", $fontSub, $blackBrush, $cardX + 20, $cardY + 20)
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
}

# Create three phone screenshots
Create-Image (Join-Path $outDir 'screenshot_placeholder_1.png') 1080 1920 'SteelBlue' 'Study Anything' 'Summaries & Quizzes'
Create-Image (Join-Path $outDir 'screenshot_placeholder_2.png') 1080 1920 'DarkCyan' 'AI Summaries' 'Instant article summaries'
Create-Image (Join-Path $outDir 'screenshot_placeholder_3.png') 1080 1920 'DarkMagenta' 'Practice Quizzes' 'Learn by testing yourself'

# Create feature graphic (1024x500)
$fgPath = Join-Path $outDir 'feature_graphic.png'
$fgW = 1024; $fgH = 500
$fgBmp = New-Object System.Drawing.Bitmap $fgW, $fgH
$g2 = [System.Drawing.Graphics]::FromImage($fgBmp)
$g2.Clear([System.Drawing.Color]::FromArgb(240,90,40))
$fontTitle = New-Object System.Drawing.Font("Arial", 56, [System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font("Arial", 24)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$g2.DrawString('Study Anything', $fontTitle, $brush, 40, 140)
$g2.DrawString('AI summaries, quizzes & flashcards', $fontSub, $brush, 40, 220)
$fgBmp.Save($fgPath, [System.Drawing.Imaging.ImageFormat]::Png)
$g2.Dispose()
$fgBmp.Dispose()

Write-Host "Created placeholders in $outDir"