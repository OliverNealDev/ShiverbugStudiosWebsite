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
  @{ path = 'assets\img';      match = '^out-of-water-screenshot\.webp$'; widths = @(480, 760, 1100, 1520) },
  # 260 is the footer mark; the source itself (400px) is the hero logo, which is
  # why the hero paints it at 400 CSS px and no wider. Nothing bigger exists in
  # webp - assets/press/shiverbug-logo-mark.png is 600px if it ever needs to be.
  @{ path = 'assets\img';      match = '^logo\.webp$';     widths = @(260) },
  # Gallery tiles are ~450 CSS px at most; the full-size file is what the link
  # and the lightbox open, so nothing here needs to go near the original.
  @{ path = 'assets\img\art';  match = '^(?!codev-dev-cyberstation).*\.jpg$'; widths = @(360, 560, 760) },
  # A <video poster> takes a single URL, so this one gets exactly one width.
  @{ path = 'assets\img\art';  match = '^codev-dev-cyberstation\.jpg$'; widths = @(560) },
  # shiverbug-logo-hires.jpg ships inside the press zip and is never shown on a page.
  @{ path = 'assets\press';    match = '^(?!shiverbug-logo-hires).*\.jpg$'; widths = @(400, 640, 900) },
  @{ path = 'assets\press';    match = '\.png$';    widths = @(240, 480) }
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
var ext = Path.GetExtension(path).ToLowerInvariant();
Console.WriteLine($"{Path.GetFileName(path)} {img.Width}x{img.Height}");
foreach (var w in widths)
{
    if (w >= img.Width) continue;
    var h = (int)Math.Round(img.Height * (double)w / img.Width);
    using var c = img.Clone(x => x.Resize(new ResizeOptions {
        Size = new Size(w, h), Mode = ResizeMode.Stretch, Sampler = KnownResamplers.Lanczos3 }));
    var outPath = Path.Combine(dir, $"{stem}-{w}{ext}");
    if (ext == ".webp") c.Save(outPath, new WebpEncoder { Quality = 82, Method = WebpEncodingMethod.BestQuality });
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
    $stem = $_.BaseName; $ext = $_.Extension; $d = $_.DirectoryName
    $widths = @($g.widths)
    if ($extraTeamWidths.ContainsKey($_.Name)) { $widths += $extraTeamWidths[$_.Name] }
    $missing = @($widths | Sort-Object -Unique | Where-Object { $Force -or -not (Test-Path (Join-Path $d "$stem-$_$ext")) })
    if ($missing.Count -eq 0) { return }
    & $exe $_.FullName ($missing -join ',')
    $made++
  }
}

Write-Host ""
Write-Host "Processed $made source images. Now run build-team.ps1, then validate-site.ps1." -ForegroundColor Green
