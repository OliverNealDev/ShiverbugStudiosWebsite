# ============================================================
# Shiverbug Studios - press bundle builder
#
# Writes the three downloadable archives in assets/press/ from files already
# in the repo:
#
#   shiverbug-press-kit.zip     everything: brand, screenshots, studio, trailer
#   shiverbug-screenshots.zip   imagery only
#   shiverbug-logos.zip         brand only
#
# These used to be assembled by hand, which is how all three ended up shipping
# a README pointing at https://olivernealdev.github.io/ShiverbugStudiosWebsite/
# - dead since the move to the custom domain - and how the two narrower bundles
# ended up carrying the full kit's contents list, describing folders they do
# not contain. Anything a journalist reads has to come from one place, and this
# is it.
#
#   powershell -ExecutionPolicy Bypass -File tools/build-press-kit.ps1
#
# Run it after changing a logo, a screenshot or the blurb below. Nothing else
# regenerates these, and tools/validate-site.ps1 will fail the build if a zip
# drifts back out of spec.
# ============================================================

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$root    = Split-Path -Parent $PSScriptRoot
$outDir  = Join-Path $root 'assets\press'
$baseUrl = 'https://shiverbugstudios.com'

# Every entry gets the same timestamp so that rebuilding without changing an
# input produces a byte-identical archive. These are binary blobs in git: if
# the mtime rode along, every run would show three multi-megabyte files as
# modified and nobody would be able to tell a real change from a rebuild.
$stamp = [datetimeoffset]::new(2026, 1, 1, 0, 0, 0, [timespan]::Zero)

# ------------------------------------------------------------
# README blocks
# ------------------------------------------------------------

function Header {
@"
SHIVERBUG STUDIOS - PRESS KIT
=============================

Shiverbug Studios Ltd
North East England, United Kingdom
Registered in England and Wales, company no. 16485763

Press contact : contact@shiverbugstudios.com
Web           : $baseUrl/
Press kit     : $baseUrl/press.html
Socials       : https://linktr.ee/shiverbugstudios

"@
}

# The brand folder is described identically wherever it appears; only its path
# differs between the full kit (nested) and the logos bundle (top level).
function BrandContents([string]$prefix) {
@"
$prefix
  logo-svg-rgb/    Primary lockup as vector, for screen. Use these by default.
  logo-svg-cmyk/   The same lockups with CMYK colour values, for print.
  logo-png/        Raster fallbacks at 1711px, plus the icon and wordmark on
                   their own.

  Naming: "-white" and "-black" are the transparent lockups, named for the
  colour of the artwork. Use -white on dark backgrounds, -black on light ones.
  "on-black", "on-white" and "on-blue" have the background baked in.

  Brand colours and typefaces, and the rules for using the logo, are set out on
  the press kit page linked above.
"@
}

function Permissions {
@"

PERMISSIONS
-----------

You have permission to use anything in this kit in articles, videos, streams
and other coverage of Shiverbug Studios and our games, including monetised
coverage, without asking us first and without paying us anything.

Please don't stretch, rotate, recolour, outline or add effects to the logo, and
please don't use it in a way that implies we endorse or are involved in a
product we aren't.

Screenshots are from a build in development and do not represent the finished
game.

Need something that isn't here - a specific shot, an interview, an asset at a
particular size? Email contact@shiverbugstudios.com and we'll sort it.
"@
}

# ------------------------------------------------------------
# What goes where
#
# Left of the arrow is the path inside the archive, right is the file in the
# repo. Spelling the mapping out beats globbing a directory: it is the only
# record of which of the several logo variants is the one press should reach
# for, and a missing source stops the build instead of silently shrinking the
# download.
# ------------------------------------------------------------

$brand = [ordered]@{
  'logo-svg-rgb/shiverbug-logo-black-rgb.svg'      = 'assets/press/brand/shiverbug-logo-black-rgb.svg'
  'logo-svg-rgb/shiverbug-logo-on-black-rgb.svg'   = 'assets/press/brand/shiverbug-logo-on-black-rgb.svg'
  'logo-svg-rgb/shiverbug-logo-on-blue-rgb.svg'    = 'assets/press/brand/shiverbug-logo-on-blue-rgb.svg'
  'logo-svg-rgb/shiverbug-logo-on-white-rgb.svg'   = 'assets/press/brand/shiverbug-logo-on-white-rgb.svg'
  'logo-svg-rgb/shiverbug-logo-white-rgb.svg'      = 'assets/press/brand/shiverbug-logo-white-rgb.svg'
  'logo-svg-cmyk/shiverbug-logo-black-cmyk.svg'    = 'assets/press/brand/shiverbug-logo-black-cmyk.svg'
  'logo-svg-cmyk/shiverbug-logo-on-black-cmyk.svg' = 'assets/press/brand/shiverbug-logo-on-black-cmyk.svg'
  'logo-svg-cmyk/shiverbug-logo-on-blue-cmyk.svg'  = 'assets/press/brand/shiverbug-logo-on-blue-cmyk.svg'
  'logo-svg-cmyk/shiverbug-logo-on-white-cmyk.svg' = 'assets/press/brand/shiverbug-logo-on-white-cmyk.svg'
  'logo-svg-cmyk/shiverbug-logo-white-cmyk.svg'    = 'assets/press/brand/shiverbug-logo-white-cmyk.svg'
  'logo-png/shiverbug-logo.png'                    = 'assets/press/shiverbug-logo.png'
  'logo-png/shiverbug-logo-black.png'              = 'assets/press/brand/shiverbug-logo-black.png'
  'logo-png/shiverbug-logo-white.png'              = 'assets/press/brand/shiverbug-logo-white.png'
  'logo-png/shiverbug-logo-on-black.png'           = 'assets/press/brand/shiverbug-logo-on-black.png'
  'logo-png/shiverbug-logo-on-blue.png'            = 'assets/press/brand/shiverbug-logo-on-blue.png'
  'logo-png/shiverbug-logo-on-white.png'           = 'assets/press/brand/shiverbug-logo-on-white.png'
  'logo-png/shiverbug-logo-mark.png'               = 'assets/press/shiverbug-logo-mark.png'
  'logo-png/shiverbug-wordmark.png'                = 'assets/press/shiverbug-wordmark.png'
  'logo-png/shiverbug-wordmark-long.png'           = 'assets/press/shiverbug-wordmark-long.png'
  'logo-png/shiverbug-logo-hires.jpg'              = 'assets/press/shiverbug-logo-hires.jpg'
}

# The three game shots and four studio photographs the press page's own gallery
# shows. The bundles used to lag that gallery: the Tranzfuser pair reached the
# full kit but never the screenshots bundle, and the beach shot - the first
# image on the page, and the one every og:image points at - was in neither.
$imagery = [ordered]@{
  'screenshots/oow-screenshot-beach.jpg'                  = 'assets/img/out-of-water-screenshot.jpg'
  'screenshots/oow-screenshot-cove.jpg'                   = 'assets/press/oow-screenshot-cove.jpg'
  'screenshots/oow-screenshot-characters.jpg'             = 'assets/press/oow-screenshot-characters.jpg'
  'studio/shiverbug-team-brighton-2026.jpg'               = 'assets/press/shiverbug-team-brighton-2026.jpg'
  'studio/shiverbug-team-develop-brighton-2026-seafront.jpg' = 'assets/img/founders.jpg'
  'studio/shiverbug-tranzfuser-2025-founders.jpg'         = 'assets/img/tranzfuser-founders.jpg'
  'studio/shiverbug-tranzfuser-2025-award.jpg'            = 'assets/press/shiverbug-tranzfuser-2025-award.jpg'
}

$video = [ordered]@{
  'video/out-of-water-trailer.mp4' = 'assets/video/out-of-water-trailer.mp4'
}

# Prefix the brand map into logos-and-brand/ for the full kit.
$brandNested = [ordered]@{}
foreach ($k in $brand.Keys) { $brandNested["logos-and-brand/$k"] = $brand[$k] }

$imageryContents = @"
screenshots/        Out of Water, full resolution. From a build in development.
studio/             Team photography: Develop:Brighton 2026, and Tranzfuser
                    2025 at ProtoPlay, where Out of Water won the public vote.
"@

$bundles = @(
  @{
    Name  = 'shiverbug-press-kit.zip'
    Files = ($brandNested + $imagery + $video)
    Body  = (BrandContents 'logos-and-brand/') + "`n`n" + $imageryContents + @"

video/              Out of Water trailer (from the ProtoPlay build; a new one
                    is in production).
"@
  },
  @{
    Name  = 'shiverbug-screenshots.zip'
    Files = $imagery
    Body  = $imageryContents + @"


Logos and the brand pack are a separate download, on the press kit page linked
above. The trailer is there too.
"@
  },
  @{
    Name  = 'shiverbug-logos.zip'
    Files = $brand
    Body  = (BrandContents 'logo folders, at the top level of this archive:') + @"


Screenshots, studio photography and the trailer are separate downloads, on the
press kit page linked above.
"@
  }
)

# ------------------------------------------------------------
# Write them
# ------------------------------------------------------------

foreach ($b in $bundles) {
  $zipPath = Join-Path $outDir $b.Name
  $readme  = (Header) + "`nWHAT'S IN HERE`n--------------`n`n" + $b.Body + "`n" + (Permissions)
  # CRLF: the likeliest reader is Notepad on Windows, and a lone LF still shows
  # there as one run-on line on older builds.
  $readme  = ($readme -replace "`r`n", "`n") -replace "`n", "`r`n"

  if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
  $fs  = [IO.File]::Open($zipPath, [IO.FileMode]::CreateNew)
  $zip = New-Object IO.Compression.ZipArchive($fs, [IO.Compression.ZipArchiveMode]::Create)

  try {
    # Entry names are written by hand rather than through CreateFromDirectory
    # or CreateEntryFromFile, both of which stamp the *platform* separator into
    # the archive on Windows PowerShell. The ZIP spec (APPNOTE 4.4.17.1) says
    # forward slash, always. Every previous build of these three used
    # backslashes, so Windows unpacked them correctly and macOS Archive Utility
    # and Linux unzip - most of games press - saw no folders at all, just a
    # flat heap of files literally named "logos-and-brand\logo-png\...".
    $entry  = $zip.CreateEntry('README.txt', [IO.Compression.CompressionLevel]::Optimal)
    $entry.LastWriteTime = $stamp
    $writer = New-Object IO.StreamWriter($entry.Open(), (New-Object Text.UTF8Encoding($false)))
    $writer.Write($readme)
    $writer.Dispose()

    foreach ($name in $b.Files.Keys) {
      $src = Join-Path $root ($b.Files[$name] -replace '/', '\')
      if (-not (Test-Path $src)) { throw "$($b.Name): source missing for $name -> $($b.Files[$name])" }
      if ($name -match '\\') { throw "$($b.Name): entry name contains a backslash -> $name" }

      $entry = $zip.CreateEntry($name, [IO.Compression.CompressionLevel]::Optimal)
      $entry.LastWriteTime = $stamp
      $dst = $entry.Open()
      $in  = [IO.File]::OpenRead($src)
      try { $in.CopyTo($dst) } finally { $in.Dispose(); $dst.Dispose() }
    }
  } finally {
    $zip.Dispose()
    $fs.Dispose()
  }

  $kb = [math]::Round((Get-Item $zipPath).Length / 1KB)
  Write-Host ("  {0,-30} {1,4} files, {2} KB" -f $b.Name, ($b.Files.Count + 1), $kb) -ForegroundColor Green
}

Write-Host ''
Write-Host 'Press bundles rebuilt.' -ForegroundColor Cyan
