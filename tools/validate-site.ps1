# ============================================================
# Shiverbug Studios - static site validator
#
# Checks, across every .html file in the repo:
#   - internal links and asset references resolve to real files
#   - each page has exactly one <h1>, a title, a description and a canonical
#   - every JSON-LD block is valid JSON with an @type
#   - sitemap URLs all correspond to files that exist
#   - no page accidentally lost its analytics tag
#
# Exits 1 if anything fails, so CI can gate on it.
#   powershell -ExecutionPolicy Bypass -File tools/validate-site.ps1
# ============================================================

$ErrorActionPreference = 'Stop'

$root    = Split-Path -Parent $PSScriptRoot
$baseUrl = 'https://olivernealdev.github.io/ShiverbugStudiosWebsite'
$errors  = New-Object System.Collections.ArrayList
$warns   = New-Object System.Collections.ArrayList

function Fail([string]$m) { [void]$errors.Add($m) }
function Warn([string]$m) { [void]$warns.Add($m) }

# Pages that are deliberately not indexed and so need no canonical.
$noIndex = @('404.html', 'team-member.html', 'privacy.html')

$htmlFiles = Get-ChildItem -Path $root -Filter *.html -Recurse |
             Where-Object { $_.FullName -notmatch '\\_originals\\' -and $_.FullName -notmatch '\\.git\\' }

Write-Host "Validating $($htmlFiles.Count) HTML files..." -ForegroundColor Cyan

foreach ($f in $htmlFiles) {
  $rel  = $f.FullName.Substring($root.Length + 1).Replace('\', '/')
  $html = Get-Content $f.FullName -Raw -Encoding UTF8
  $dir  = $f.Directory.FullName

  # ---- head essentials ----
  $h1Count = ([regex]::Matches($html, '<h1[\s>]')).Count
  if ($h1Count -ne 1) { Fail "$rel : expected exactly 1 <h1>, found $h1Count" }

  if ($html -notmatch '<title>[^<]{5,}</title>') { Fail "$rel : missing or empty <title>" }
  if ($html -notmatch 'name="description"\s+content="[^"]{30,}"') { Fail "$rel : missing or too-short meta description" }
  if ($html -notmatch 'lang="en-GB"') { Fail "$rel : <html> missing lang=en-GB" }

  $isNoIndex = ($noIndex -contains $rel) -or ($html -match 'name="robots"\s+content="noindex')
  if (-not $isNoIndex) {
    if ($html -notmatch 'rel="canonical"')            { Fail "$rel : missing rel=canonical" }
    if ($html -notmatch 'name="twitter:card"')        { Fail "$rel : missing twitter:card" }
    if ($html -notmatch 'property="og:image"')        { Fail "$rel : missing og:image" }
  }

  if ($html -notmatch 'goatcounter') { Warn "$rel : no analytics tag" }
  if ($html -match '<!--\s*<script data-goatcounter') { Fail "$rel : analytics tag is still commented out" }

  # ---- JSON-LD blocks parse ----
  foreach ($m in [regex]::Matches($html, '(?s)<script type="application/ld\+json">(.*?)</script>')) {
    $raw = $m.Groups[1].Value
    try {
      $obj = $raw | ConvertFrom-Json
      $hasType = $obj.PSObject.Properties.Name -contains '@type'
      $hasGraph = $obj.PSObject.Properties.Name -contains '@graph'
      if (-not ($hasType -or $hasGraph)) { Fail "$rel : JSON-LD block has neither @type nor @graph" }
    } catch {
      Fail "$rel : JSON-LD does not parse - $($_.Exception.Message)"
    }
  }

  # ---- internal links and assets resolve ----
  $refs = @()
  $refs += [regex]::Matches($html, '(?:href|src)="([^"#][^"]*)"') | ForEach-Object { $_.Groups[1].Value }
  foreach ($ref in ($refs | Sort-Object -Unique)) {
    if ($ref -match '^(https?:|mailto:|data:|//|#)') { continue }
    $clean = ($ref -split '[?#]')[0]
    if ([string]::IsNullOrWhiteSpace($clean)) { continue }
    $target = Join-Path $dir ($clean -replace '/', '\')
    if (Test-Path $target -PathType Container) { $target = Join-Path $target 'index.html' }
    if (-not (Test-Path $target)) { Fail "$rel : broken reference -> $ref" }
  }
}

# ---- sitemap points at real files ----
$sitemapPath = Join-Path $root 'sitemap.xml'
if (Test-Path $sitemapPath) {
  [xml]$sm = Get-Content $sitemapPath -Raw -Encoding UTF8
  $locs = @($sm.urlset.url.loc)
  Write-Host "Checking $($locs.Count) sitemap URLs..." -ForegroundColor Cyan
  foreach ($loc in $locs) {
    if (-not $loc.StartsWith($baseUrl)) { Fail "sitemap.xml : $loc is not under $baseUrl"; continue }
    $path = $loc.Substring($baseUrl.Length).TrimStart('/')
    if ($path -eq '' -or $path.EndsWith('/')) { $path = $path + 'index.html' }
    $target = Join-Path $root ($path -replace '/', '\')
    if (-not (Test-Path $target)) { Fail "sitemap.xml : $loc has no matching file ($path)" }
  }
  # every non-noindex page should be listed
  foreach ($f in $htmlFiles) {
    $rel = $f.FullName.Substring($root.Length + 1).Replace('\', '/')
    $html = Get-Content $f.FullName -Raw -Encoding UTF8
    if (($noIndex -contains $rel) -or ($html -match 'name="robots"\s+content="noindex')) { continue }
    $expect = "$baseUrl/" + ($rel -replace 'index\.html$', '')
    if ($locs -notcontains $expect -and $locs -notcontains "$baseUrl/$rel") {
      Warn "sitemap.xml : $rel is indexable but not listed"
    }
  }
} else {
  Fail "sitemap.xml is missing"
}

# ---- llms.txt sanity ----
$llmsPath = Join-Path $root 'llms.txt'
if (Test-Path $llmsPath) {
  $llms = Get-Content $llmsPath -Raw -Encoding UTF8
  if ($llms -notmatch '^# ')      { Fail 'llms.txt : missing top-level "# " heading' }
  if ($llms -notmatch '(?m)^> ')  { Fail 'llms.txt : missing "> " summary line' }
} else {
  Fail 'llms.txt is missing'
}

# ---- report ----
Write-Host ''
foreach ($w in $warns)  { Write-Host "WARN  $w" -ForegroundColor Yellow }
foreach ($e in $errors) { Write-Host "FAIL  $e" -ForegroundColor Red }
Write-Host ''
if ($errors.Count -eq 0) {
  Write-Host "PASS - $($htmlFiles.Count) pages, 0 errors, $($warns.Count) warnings" -ForegroundColor Green
  exit 0
} else {
  Write-Host "FAILED - $($errors.Count) errors, $($warns.Count) warnings" -ForegroundColor Red
  exit 1
}
