# ============================================================
# Shiverbug Studios - responsive image variants
#
# Writes assets/.../<name>-<width>.<ext> beside each source image. The site's
# srcset attributes are built from whatever this leaves on disk:
#   - tools/build-team.ps1 discovers the team thumbnails automatically
#   - the hand-written pages (index, co-dev, press) name their variants directly
#
# This is a ONE-OFF asset step, not part of the build. CI does not run it, and
# it is the only script in the repo that needs anything installed: the .NET SDK,
# which pulls SixLabors.ImageSharp from NuGet into a scratch project. Everything
# else here still runs on the PowerShell that's already on the machine.
#
#   powershell -ExecutionPolicy Bypass -File tools/make-variants.ps1
#   powershell -ExecutionPolicy Bypass -File tools/make-variants.ps1 -Only team-evan
#
# After adding art, run this, then build-team.ps1, then validate-site.ps1.
# validate-site.ps1 checks every srcset candidate resolves, so a missing variant
# fails the build rather than 404ing on one screen size in production.
# ============================================================

param(
  # substring filter, e.g. -Only codev-3d   (default: every source image)
  [string]$Only = '',
  # rebuild variants that already exist
  [switch]$Force
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
  throw "The .NET SDK is required for this script only. Install it from https://dotnet.microsoft.com/download, or ask whoever added the art to run it."
}

# Which widths each kind of image needs. Keep these in step with the `sizes`
# attributes: a width nothing can ask for is dead weight in the repo.
$groups = @(
  # Team portraits: 240-480 covers every grid tile. Two extra widths are added
  # per person below, only where something actually asks for them.
  @{ path = 'assets\img';      match = '^team-';    widths = @(240, 320, 480) },
  # The .jpg twins of these two exist only to be og:image targets, which social
  # scrapers fetch whole. Resizing them would just publish files nothing loads.
  @{ path = 'assets\img';      match = '^founders\.webp$'; widths = @(400, 600, 800, 1080) },
  # The Tranzfuser award photo in the "Part of" strip. Its .jpg twin is the
  # full-size file press.html links to, and is fetched whole like the two above.
  # Named "-founders", not "-2025": the variant guard below skips any stem ending
  # in a hyphen and 2-4 digits, so a year on the end reads as a width and the
  # source is passed over in silence. assets\press\shiverbug-team-brighton-2026
  # is already sitting in that trap - its variants had to be made by hand.
  @{ path = 'assets\img';      match = '^tranzfuser-founders\.webp$'; widths = @(400, 600, 800, 1080) },
  # The certificate shot that replaced the founders photo in the Recognition
  # band. Only 795px wide, because it is a crop out of the middle of a 1620px
  # frame - the three of them take up about half of it - so 600 is the last
  # useful step before the source itself. The founders photo above stays: the
  # press media grid still offers it, and still links its full-size .jpg.
  @{ path = 'assets\img';      match = '^tranzfuser-award\.webp$'; widths = @(400, 600) },
  @{ path = 'assets\img';      match = '^out-of-water-screenshot\.webp$'; widths = @(480, 760, 1100, 1520) },
  # The hero and footer marks used to be rasters resized here. They are now one
  # SVG (assets/img/logo.svg, trimmed from the 2026 brand pack), which has no
  # widths to generate.
  # Gallery tiles are ~450 CSS px at most; the full-size file is what the link
  # and the lightbox open, so nothing here needs to go near the original.
  #
  # The whole folder is WebP now, source included. At the same quality 82 a WebP
  # tile came out both smaller than the .jpg it replaced and closer to the
  # Lanczos-resized reference both were encoded from (codev-dev-gridlock-760:
  # 26KB/35.7dB as .jpg, 13KB/38.0dB as .webp), so the tiles cost nothing. The
  # full-size .webp was transcoded from the .jpg once at quality 90 (PSNR 37-46)
  # and those .jpg files now live in _originals/art, off the repo like every
  # other full-resolution source. Regenerating a tile from scratch needs them
  # back: this folder no longer holds anything the site did not already ship.
  @{ path = 'assets\img\art';  match = '^(?!codev-dev-cyberstation).*\.webp$'; widths = @(360, 560, 760) },
  # A <video poster> takes a single URL, so this one gets exactly one width.
  @{ path = 'assets\img\art';  match = '^codev-dev-cyberstation\.webp$'; widths = @(560) },
  # shiverbug-logo-hires.jpg ships inside the press zip and is never shown on a page.
  @{ path = 'assets\press';    match = '^(?!shiverbug-logo-hires).*\.jpg$'; widths = @(400, 640, 900) },
  # The two brand marks press.html actually displays. Their sources stay PNG -
  # that is the file the page offers for download and the one the zip ships in
  # logo-png/ - but nothing makes a reader pay 104KB to look at a 240px mark, so
  # the on-page variants come out as WebP. This used to be a blunt '\.png$' at
  # 240 and 480 across the whole folder, which generated exactly one extra file
  # nothing ever referenced (shiverbug-logo-240.png) and skipped the rest for
  # being no smaller than their source.
  @{ path = 'assets\press';    match = '^shiverbug-logo-mark\.png$';     widths = @(240, 480); ext = '.webp' },
  @{ path = 'assets\press';    match = '^shiverbug-wordmark-long\.png$'; widths = @(240);      ext = '.webp' }
)

# Two team widths are conditional, and both conditions live somewhere else. Read
# them from that somewhere else rather than keeping a second list in step by hand:
# an unused variant is dead weight that GitHub Pages still publishes.
$extraTeamWidths = @{}
function AddExtra([string]$photo, [int]$w) {
  $name = [System.IO.Path]::GetFileName($photo)
  if (-not $extraTeamWidths.ContainsKey($name)) { $extraTeamWidths[$name] = @() }
  if ($extraTeamWidths[$name] -notcontains $w) { $extraTeamWidths[$name] += $w }
}

# 640: only the .is-zoomed tiles, which CSS paints at up to 2.1x their box.
$team = Get-Content (Join-Path $root 'data\team.json') -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($p in (@($team.team) + @($team.talent))) {
  if ($p.photo -and $p.thumbClass -match 'is-zoomed') { AddExtra $p.photo 640 }
}

# 160: the avatar chips beside each co-dev service, 34px on a crew chip and 22px
# on a gallery credit. Only the people who actually appear there need one. These
# used to live on co-dev.html; that page folded into the home page, and reading
# the old file here would have silently stopped generating every 160px avatar.
$codev = Get-Content (Join-Path $root 'index.html') -Raw -Encoding UTF8
foreach ($m in [regex]::Matches($codev, 'assets/img/(team-[a-z\-]+?)(?:-\d{2,4})?\.(webp|jpg)')) {
  AddExtra ($m.Groups[1].Value + '.' + $m.Groups[2].Value) 160
}

# ---------- scratch project ----------

$proj = Join-Path ([System.IO.Path]::GetTempPath()) 'shiverbug-imgtool'
if (-not (Test-Path (Join-Path $proj 'imgtool.csproj'))) {
  Write-Host "Preparing the resizer (one-off NuGet restore)..." -ForegroundColor Cyan
  New-Item -ItemType Directory -Path $proj -Force | Out-Null
  Push-Location $proj
  try {
    & dotnet new console -o . --force | Out-Null
    & dotnet add package SixLabors.ImageSharp --version 3.1.12 | Out-Null
  } finally { Pop-Location }
}

$program = @'
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Formats.Jpeg;
using SixLabors.ImageSharp.Formats.Png;
using SixLabors.ImageSharp.Formats.Webp;
using SixLabors.ImageSharp.Processing;

var path = args[0];
var widths = args[1].Split(',', StringSplitOptions.RemoveEmptyEntries).Select(int.Parse);
using var img = Image.Load(path);
var dir = Path.GetDirectoryName(path)!;
var stem = Path.GetFileNameWithoutExtension(path);
// Variants normally keep their source's format. A group can override that when
// the source has to stay in a format the page should not be shipping: the press
// logos are downloadable PNGs, so the marks shown on the page are WebP off the
// same file. Lossless, because a lossy logo rings around its own edges.
var ext = args.Length > 2 ? args[2] : Path.GetExtension(path).ToLowerInvariant();
Console.WriteLine($"{Path.GetFileName(path)} {img.Width}x{img.Height}");
foreach (var w in widths)
{
    if (w >= img.Width) continue;
    var h = (int)Math.Round(img.Height * (double)w / img.Width);
    using var c = img.Clone(x => x.Resize(new ResizeOptions {
        Size = new Size(w, h), Mode = ResizeMode.Stretch, Sampler = KnownResamplers.Lanczos3 }));
    var outPath = Path.Combine(dir, $"{stem}-{w}{ext}");
    if (ext == ".webp" && Path.GetExtension(path).ToLowerInvariant() == ".png")
        c.Save(outPath, new WebpEncoder { FileFormat = WebpFileFormatType.Lossless, Quality = 100, Method = WebpEncodingMethod.BestQuality });
    else if (ext == ".webp") c.Save(outPath, new WebpEncoder { Quality = 82, Method = WebpEncodingMethod.BestQuality });
    else if (ext == ".png") c.Save(outPath, new PngEncoder { CompressionLevel = PngCompressionLevel.BestCompression });
    else c.Save(outPath, new JpegEncoder { Quality = 82 });
    // A variant no smaller than its source is worse than not having it: the
    // browser would pick it on narrow screens and download more, not less.
    if (new FileInfo(outPath).Length >= new FileInfo(path).Length * 0.9) {
        File.Delete(outPath);
        Console.WriteLine($"  -{w} skipped (no smaller than the original)");
    } else {
        Console.WriteLine($"  -{w} {new FileInfo(outPath).Length / 1024}KB");
    }
}
'@
Set-Content -Path (Join-Path $proj 'Program.cs') -Value $program -Encoding UTF8
& dotnet build $proj -c Release -v q --nologo | Out-Null
# `dotnet new console` names the assembly after the folder, and the target
# framework moves with the SDK, so find the binary rather than guessing at it.
$exe = @(Get-ChildItem (Join-Path $proj 'bin\Release') -Filter '*.exe' -Recurse -ErrorAction SilentlyContinue |
         Select-Object -First 1 -ExpandProperty FullName)
if (-not $exe) { throw "The resizer did not build. Run 'dotnet build' in $proj to see why." }
$exe = $exe[0]

# ---------- run ----------

$made = 0
foreach ($g in $groups) {
  $dir = Join-Path $root $g.path
  if (-not (Test-Path $dir)) { continue }
  Get-ChildItem $dir -File | Where-Object {
    $_.Name -match $g.match -and
    $_.BaseName -notmatch '-\d{2,4}$' -and           # never resize a variant
    $_.Extension -match '\.(webp|jpg|png)$' -and
    ($Only -eq '' -or $_.Name -like "*$Only*")
  } | ForEach-Object {
    $stem = $_.BaseName; $d = $_.DirectoryName
    # A group may ask for its variants in a different format than the source.
    $ext = if ($g.ContainsKey('ext')) { $g.ext } else { $_.Extension }
    $widths = @($g.widths)
    if ($extraTeamWidths.ContainsKey($_.Name)) { $widths += $extraTeamWidths[$_.Name] }
    $missing = @($widths | Sort-Object -Unique | Where-Object { $Force -or -not (Test-Path (Join-Path $d "$stem-$_$ext")) })
    if ($missing.Count -eq 0) { return }
    & $exe $_.FullName ($missing -join ',') $ext
    $made++
  }
}

Write-Host ""
Write-Host "Processed $made source images. Now run build-team.ps1, then validate-site.ps1." -ForegroundColor Green
