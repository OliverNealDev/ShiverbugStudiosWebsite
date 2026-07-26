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
# '/ShiverbugStudiosWebsite' - the path every site-absolute reference must carry
# while we're on a project Pages site. Becomes '' on a custom domain.
$sitePrefix = ([uri]$baseUrl).AbsolutePath.TrimEnd('/')
$errors  = New-Object System.Collections.ArrayList
$warns   = New-Object System.Collections.ArrayList

function Fail([string]$m) { [void]$errors.Add($m) }
function Warn([string]$m) { [void]$warns.Add($m) }

# Pages that are deliberately not indexed and so need no canonical.
$noIndex = @('404.html', 'team-member.html')

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

  # ---- security + legal boilerplate that must not drift between pages ----
  if ($html -notmatch 'http-equiv="Content-Security-Policy"') {
    Fail "$rel : missing the Content-Security-Policy meta tag"
  }
  if ($html -notmatch 'company no\. 16485763') {
    Fail "$rel : missing the Companies Act trading disclosure in the footer"
  }
  # An inline <script> would be blocked by our own CSP. JSON-LD is data, not script,
  # and is left alone.
  foreach ($m in [regex]::Matches($html, '(?s)<script(?![^>]*\ssrc=)([^>]*)>(.*?)</script>')) {
    if ($m.Groups[1].Value -notmatch 'application/ld\+json') {
      Fail "$rel : inline <script> will be blocked by the page's own CSP - move it to a .js file"
    }
  }

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
    if ($clean.StartsWith('/')) {
      # Site-absolute, as used by 404.html (which GitHub Pages serves at any depth).
      # Resolve from the repo root, and insist the project prefix is present.
      if ($sitePrefix -and -not $clean.StartsWith("$sitePrefix/")) {
        Fail "$rel : site-absolute reference is missing the $sitePrefix prefix -> $ref"
        continue
      }
      $rootRel = $clean.Substring($sitePrefix.Length).TrimStart('/')
      if ($rootRel -eq '') { $rootRel = 'index.html' }
      $target = Join-Path $root ($rootRel -replace '/', '\')
    } else {
      $target = Join-Path $dir ($clean -replace '/', '\')
    }
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
