Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root "icons"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

$ink       = [System.Drawing.Color]::FromArgb(255, 13, 15, 20)
$panel     = [System.Drawing.Color]::FromArgb(255, 41, 45, 54)
$screenCol = [System.Drawing.Color]::FromArgb(255, 10, 11, 16)
$accent    = [System.Drawing.Color]::FromArgb(255, 239, 69, 101)
$accentDim = [System.Drawing.Color]::FromArgb(255, 138, 47, 66)
$gold      = [System.Drawing.Color]::FromArgb(255, 76, 195, 196)

function Add-RoundRect {
  param($path, $x, $y, $w, $h, $r)
  $d = $r * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $path.CloseFigure()
}

function New-Icon {
  param([int]$size, [double]$padFrac, [string]$outPath)

  $bmp = New-Object System.Drawing.Bitmap($size, $size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

  # background
  $bgPath = New-Object System.Drawing.Drawing2D.GraphicsPath
  Add-RoundRect $bgPath 0 0 $size $size ($size * 0.22)
  $g.FillPath((New-Object System.Drawing.SolidBrush($ink)), $bgPath)

  $pad = $size * $padFrac
  $bodyX = $pad
  $bodyY = $pad + $size * 0.02
  $bodyW = $size - $pad * 2
  $bodyH = $size - $pad * 2 - $size * 0.09
  $cx = $bodyX + $bodyW / 2

  # antennae
  $penDim = New-Object System.Drawing.Pen($accentDim, [Math]::Max(1.5, $size * 0.016))
  $penDim.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $penDim.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $g.DrawLine($penDim, $cx, $bodyY, ($cx - $bodyW * 0.22), ($bodyY - $bodyH * 0.16))
  $g.DrawLine($penDim, $cx, $bodyY, ($cx + $bodyW * 0.22), ($bodyY - $bodyH * 0.16))

  # TV body
  $bodyPath = New-Object System.Drawing.Drawing2D.GraphicsPath
  Add-RoundRect $bodyPath $bodyX $bodyY $bodyW $bodyH ($bodyW * 0.14)
  $g.FillPath((New-Object System.Drawing.SolidBrush($panel)), $bodyPath)
  $g.DrawPath((New-Object System.Drawing.Pen($accentDim, [Math]::Max(1.5, $size * 0.012))), $bodyPath)

  # screen
  $sPad = $bodyW * 0.10
  $scrX = $bodyX + $sPad
  $scrY = $bodyY + $sPad
  $scrW = $bodyW - $sPad * 2
  $scrH = $bodyH - $sPad * 2.4
  $scrPath = New-Object System.Drawing.Drawing2D.GraphicsPath
  Add-RoundRect $scrPath $scrX $scrY $scrW $scrH ($scrW * 0.08)
  $g.FillPath((New-Object System.Drawing.SolidBrush($screenCol)), $scrPath)
  $g.DrawPath((New-Object System.Drawing.Pen($accent, [Math]::Max(1.5, $size * 0.016))), $scrPath)

  # "A" glyph
  $fontSize = [Math]::Max(6, [int]($scrH * 0.58))
  $font = New-Object System.Drawing.Font("Arial", $fontSize, [System.Drawing.FontStyle]::Bold)
  $accentBrush = New-Object System.Drawing.SolidBrush($accent)
  $sf = New-Object System.Drawing.StringFormat
  $sf.Alignment = [System.Drawing.StringAlignment]::Center
  $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
  $g.DrawString("A", $font, $accentBrush, (New-Object System.Drawing.PointF(($scrX + $scrW / 2), ($scrY + $scrH / 2))), $sf)

  # base stand
  $standW = $bodyW * 0.3
  $standH = [Math]::Max(2, $bodyH * 0.05)
  $standPath = New-Object System.Drawing.Drawing2D.GraphicsPath
  Add-RoundRect $standPath ($cx - $standW / 2) ($bodyY + $bodyH) $standW $standH ($standH * 0.4)
  $g.FillPath((New-Object System.Drawing.SolidBrush($panel)), $standPath)

  # gold dial dot
  $dotR = [Math]::Max(1.5, $size * 0.014)
  $dotX = $bodyX + $bodyW - $sPad * 0.6
  $dotY = $scrY + $scrH + $sPad * 0.5
  $g.FillEllipse((New-Object System.Drawing.SolidBrush($gold)), ($dotX - $dotR), ($dotY - $dotR), ($dotR * 2), ($dotR * 2))

  $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
  $g.Dispose()
  $bmp.Dispose()
}

New-Icon -size 512 -padFrac 0.10 -outPath (Join-Path $outDir "icon-512.png")
New-Icon -size 192 -padFrac 0.10 -outPath (Join-Path $outDir "icon-192.png")
New-Icon -size 512 -padFrac 0.19 -outPath (Join-Path $outDir "icon-maskable-512.png")
New-Icon -size 180 -padFrac 0.10 -outPath (Join-Path $outDir "apple-touch-icon.png")
New-Icon -size 32  -padFrac 0.08 -outPath (Join-Path $outDir "favicon-32.png")

Write-Host "Icons written to $outDir"
