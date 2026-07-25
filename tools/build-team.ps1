# ============================================================
# Shiverbug Studios - static team page generator
#
# Reads data/team.json and writes:
#   team/<slug>.html      one real, crawlable page per person
#   index.html            the team grids, between the BUILD markers
#   sitemap.xml           every team page listed
#
# Run from anywhere:  powershell -ExecutionPolicy Bypass -File tools/build-team.ps1
# ============================================================

$ErrorActionPreference = 'Stop'

$root    = Split-Path -Parent $PSScriptRoot
$dataFile = Join-Path $root 'data\team.json'
$teamDir = Join-Path $root 'team'
$baseUrl = 'https://olivernealdev.github.io/ShiverbugStudiosWebsite'

$data   = Get-Content $dataFile -Raw -Encoding UTF8 | ConvertFrom-Json
$team   = @($data.team)
$talent = @($data.talent)
$all    = @($team) + @($talent)

if (-not (Test-Path $teamDir)) { New-Item -ItemType Directory -Path $teamDir | Out-Null }

# ---------- helpers ----------

function HtmlEnc([string]$s) {
  if ([string]::IsNullOrEmpty($s)) { return '' }
  return $s.Replace('&', '&amp;').Replace('<', '&lt;').Replace('>', '&gt;').Replace('"', '&quot;')
}

function StripTags([string]$s) {
  if ([string]::IsNullOrEmpty($s)) { return '' }
  return ([regex]::Replace($s, '<[^>]+>', '')).Trim()
}

function Truncate([string]$s, [int]$max) {
  if ($s.Length -le $max) { return $s }
  $cut = $s.Substring(0, $max)
  $sp = $cut.LastIndexOf(' ')
  if ($sp -gt 40) { $cut = $cut.Substring(0, $sp) }
  return $cut.TrimEnd(',', '.', ';', ':') + '...'
}

function RoleDisplay($person) {
  # NB: keep this file pure ASCII - PowerShell 5.1 reads a BOM-less .ps1 as ANSI,
  # so a literal middot here would arrive mangled. Build it from its code point.
  $middot = [char]0x00B7
  return [regex]::Replace($person.role, '\s*' + $middot + '\s*Co-Founder', '', 'IgnoreCase')
}

function WriteFileUtf8([string]$path, [string]$text) {
  # UTF-8 without BOM, CRLF endings to match the rest of the working tree
  $text = $text.Replace("`r`n", "`n").Replace("`n", "`r`n")
  $enc = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $text, $enc)
}

# ---------- social icons (ported from the old js/member.js) ----------

$icons = @{
  'linkedin'   = '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.225 0z"/></svg>'
  'github'     = '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></svg>'
  'instagram'  = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4.2"/><circle cx="17.3" cy="6.7" r="1.2" fill="currentColor" stroke="none"/></svg>'
  'artstation' = '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M0 17.723l2.027 3.505a2.424 2.424 0 0 0 2.164 1.333h13.457l-2.792-4.838H0zm24-.025c0-.484-.143-.935-.388-1.314L15.728 2.728a2.424 2.424 0 0 0-2.142-1.289h-4.19l12.06 20.902 2.028-3.513c.388-.672.516-.973.516-1.13zm-11.35-10.85l-4.277 7.408h8.552l-4.275-7.408z"/></svg>'
  'bluesky'    = '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 10.8C10.913 8.686 7.954 4.747 5.202 2.805 2.566.944 1.561 1.266.902 1.565.139 1.908 0 3.08 0 3.768c0 .69.378 5.65.624 6.479.815 2.736 3.713 3.66 6.383 3.364-3.912.58-7.387 2.005-2.83 7.078 5.013 5.19 6.87-1.113 7.823-4.308.953 3.195 2.05 9.271 7.733 4.308 4.267-4.308 1.172-6.498-2.74-7.078 2.67.297 5.568-.628 6.383-3.364.246-.828.624-5.79.624-6.478 0-.69-.139-1.861-.902-2.206-.659-.298-1.664-.62-4.3 1.24C16.046 4.748 13.087 8.687 12 10.8Z"/></svg>'
  'itchio'     = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 12h.01M10 10v4M8 12h4"/><path d="M17.5 10.5h.01M15.5 13.5h.01"/><path d="M7.2 6h9.6c2.3 0 4.1 1.8 4.2 4.1l.4 5.2a3.6 3.6 0 0 1-6.3 2.7l-1-1.2a2.6 2.6 0 0 0-4.2 0l-1 1.2A3.6 3.6 0 0 1 2.6 15.3l.4-5.2C3.1 7.8 4.9 6 7.2 6z"/></svg>'
  'x'          = '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M18.901 1.153h3.68l-8.04 9.19L24 22.846h-7.406l-5.8-7.584-6.638 7.584H.474l8.6-9.83L0 1.154h7.594l5.243 6.932ZM17.61 20.644h2.039L6.486 3.24H4.298Z"/></svg>'
  'website'    = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><circle cx="12" cy="12" r="9"/><ellipse cx="12" cy="12" rx="4" ry="9"/><path d="M3.6 9h16.8M3.6 15h16.8"/></svg>'
}

function IconFor([string]$label) {
  $key = ([regex]::Replace($label.ToLower(), '[^a-z]', ''))
  if ($icons.ContainsKey($key)) { return $icons[$key] }
  return $icons['website']
}

# ---------- page template ----------

$template = @'
<!DOCTYPE html>
<html lang="en-GB">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{{NAME}} | Shiverbug Studios</title>
  <meta name="description" content="{{DESC}}">
  <link rel="canonical" href="{{CANONICAL}}">
  <meta property="og:title" content="{{NAME}} &#8212; {{ROLE}} | Shiverbug Studios">
  <meta property="og:description" content="{{DESC}}">
  <meta property="og:image" content="{{OGIMAGE}}">
  <meta property="og:url" content="{{CANONICAL}}">
  <meta property="og:type" content="profile">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="{{NAME}} &#8212; {{ROLE}} | Shiverbug Studios">
  <meta name="twitter:description" content="{{DESC}}">
  <meta name="twitter:image" content="{{OGIMAGE}}">
  <link rel="icon" type="image/png" href="../assets/img/favicon.png">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,400;12..96,600;12..96,700;12..96,800&family=Instrument+Sans:ital,wght@0,400;0,500;0,600;1,400&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="../css/style.css">
  <noscript><style>.reveal{opacity:1;transform:none}</style></noscript>
  <script type="application/ld+json">
{{JSONLD}}
  </script>
</head>
<body>

  <a class="skip-link" href="#top">Skip to content</a>

  <!-- ======= NAV ======= -->
  <header class="nav" id="nav">
    <div class="nav__inner">
      <a class="nav__brand" href="../index.html" aria-label="Shiverbug Studios, home">
        <img src="../assets/img/nav-logo.webp" alt="" class="nav__logo">
        <img src="../assets/img/nav-wordmark.webp" alt="" class="nav__wordmark">
      </a>
      <nav class="nav__links" id="navLinks" aria-label="Primary">
        <a href="../index.html#game">Out of Water</a>
        <a href="../co-dev.html">Co-Dev</a>
        <a href="../index.html#studio">Studio</a>
        <a href="../index.html#team">Team</a>
        <a href="../press.html">Press</a>
        <a class="nav__cta" href="mailto:contact@shiverbugstudios.com">Get in touch</a>
      </nav>
      <button class="nav__burger" id="navBurger" aria-label="Open menu" aria-expanded="false" aria-controls="navLinks">
        <span></span><span></span>
      </button>
    </div>
  </header>

  <main class="profile" id="top">
    <div class="container">
      <a class="profile__back" href="../index.html#team" id="backLink">&larr; Back</a>
      <div class="profile__inner">
        <figure class="profile__photo">{{PHOTO}}</figure>
        <div>
          <h1 class="profile__name">{{NAME}}</h1>
          <p class="kicker kicker--sea profile__role">{{ROLELINE}}</p>
          {{TAGLINE}}
          <div class="profile__badges">{{BADGES}}</div>
          <section class="profile__section">
            <h2>About</h2>
            {{ABOUT}}
          </section>
{{ASKME}}
          <section class="profile__section">
            <h2>Find me</h2>
            <div class="profile__socials">{{SOCIALS}}</div>
          </section>
        </div>
      </div>
      <nav class="profile__nav" aria-label="Team">
        <a href="{{PREVHREF}}">&larr; {{PREVNAME}}</a>
        <a class="is-back" href="../index.html#team">All shiverbugs</a>
        <a href="{{NEXTHREF}}">{{NEXTNAME}} &rarr;</a>
      </nav>
    </div>
  </main>

  <footer class="footer footer--mini">
    <div class="container">
      <div class="footer__meta">
        <p>&copy; <span id="year">2026</span> Shiverbug Studios Ltd &middot; North East England, UK &middot; <a class="footer__press" href="../press.html">Press kit</a> &middot; <a class="footer__press" href="../privacy.html">Privacy</a></p>
        <p class="footer__tag">Bringing family game night back to the sofa.</p>
      </div>
    </div>
  </footer>

  <script src="../js/main.js"></script>
  <script src="../js/profile.js"></script>
  <!-- Analytics (GoatCounter): create a free account at goatcounter.com with the code "shiverbug", then uncomment. Cookieless and GDPR-friendly, no banner needed. -->
  <!-- <script data-goatcounter="https://shiverbug.goatcounter.com/count" async src="https://gc.zgo.at/count.js"></script> -->
</body>
</html>
'@

# ---------- build one page per person ----------

$favourites = @{
  'turtle'  = @{ cls = 'badge--turtle';  text = 'Team Turtle' }
  'seagull' = @{ cls = 'badge--seagull'; text = 'Team Seagull' }
  'crab'    = @{ cls = 'badge--crab';    text = 'Team Crab (the army)' }
}

$written = @()

foreach ($list in @($team, $talent)) {
  $order = @($list)
  for ($i = 0; $i -lt $order.Count; $i++) {
    $p = $order[$i]
    $firstName = ($p.name -split ' ')[0]
    $roleDisp = RoleDisplay $p
    $canonical = "$baseUrl/team/$($p.slug).html"

    # --- description: role first, then the opening of the bio ---
    $desc = "$($p.name) - $roleDisp at Shiverbug Studios."
    if ($p.about -and @($p.about).Count -gt 0) {
      $desc = $desc + ' ' + (StripTags (@($p.about)[0]))
    } elseif ($p.tagline) {
      $desc = $desc + ' "' + $p.tagline + '"'
    } else {
      $desc = $desc + ' Shiverbug Studios is an indie game studio in North East England making couch co-op games.'
    }
    $desc = Truncate $desc 200

    # --- photo ---
    if ($p.photo) {
      $photo = '<img src="../' + $p.photo + '" alt="' + (HtmlEnc $p.name) + '" width="600" height="800">'
      $ogImage = "$baseUrl/$($p.photo)"
    } else {
      $photo = '<div class="profile__photo--empty"><span>' + (HtmlEnc $p.initials) + '</span></div>'
      $ogImage = "$baseUrl/assets/press/shiverbug-logo.png"
    }

    # --- role line ---
    $roleLine = HtmlEnc $roleDisp
    if ($p.pronouns) { $roleLine = $roleLine + ' &middot; ' + (HtmlEnc $p.pronouns) }

    # --- tagline ---
    if ($p.tagline) {
      $tagline = '<p class="profile__tagline">&ldquo;' + (HtmlEnc $p.tagline) + '&rdquo;</p>'
    } else {
      $tagline = '<p class="profile__tagline">' + (HtmlEnc $firstName) + " hasn't picked a tagline yet. We're on it.</p>"
    }

    # --- badges ---
    $badges = ''
    if ($p.role -match '(?i)co-founder') { $badges += '<span class="badge badge--founder">&#9733; Co-Founder</span>' }
    if ($p.favourite -and $favourites.ContainsKey($p.favourite)) {
      $f = $favourites[$p.favourite]
      $badges += '<span class="badge ' + $f.cls + '">' + $f.text + '</span>'
    } else {
      $badges += '<span class="badge">Turtle or seagull? Undecided.</span>'
    }
    if ($p.status -eq 'active') { $badges += '<span class="badge badge--active">Actively contributing</span>' }
    elseif ($p.status -eq 'former') { $badges += '<span class="badge badge--former">Former shiverbug</span>' }

    # --- about: always rendered in full, JS only adds the read-more clamp ---
    if ($p.about -and @($p.about).Count -gt 0) {
      $paras = (@($p.about) | ForEach-Object { '<p>' + $_ + '</p>' }) -join "`n            "
      $joined = (@($p.about) -join ' ')
      $clampAttr = ''
      if ($joined.Length -gt 600) { $clampAttr = ' data-clamp="true"' }
      $about = '<div class="profile__about" id="aboutText"' + $clampAttr + '>' + "`n            " + $paras + "`n            " + '</div>'
    } else {
      $about = '<p class="is-placeholder">We&rsquo;re still squeezing a bio out of ' + (HtmlEnc $firstName) + '. Check back soon.</p>'
    }

    # --- ask me about ---
    $askMe = ''
    if ($p.askMeAbout -and @($p.askMeAbout).Count -gt 0) {
      $chips = (@($p.askMeAbout) | ForEach-Object { '<span class="chip">' + (HtmlEnc $_) + '</span>' }) -join ''
      $askMe = @"
          <section class="profile__section">
            <h2>Ask me about</h2>
            <div class="profile__chips">$chips</div>
          </section>
"@
    }

    # --- socials ---
    if ($p.socials -and @($p.socials).Count -gt 0) {
      $socials = (@($p.socials) | ForEach-Object {
        '<a class="social" href="' + (HtmlEnc $_.url) + '" target="_blank" rel="noopener">' +
        '<span class="social__icon">' + (IconFor $_.label) + '</span>' +
        '<span class="social__label">' + (HtmlEnc $_.label) + '</span></a>'
      }) -join "`n            "
    } else {
      $socials = '<p class="is-placeholder" style="font-style:italic;color:#9a9284;">Links on the way.</p>'
    }

    # --- prev / next, wrapping inside this person's own list ---
    $prev = $order[(($i - 1 + $order.Count) % $order.Count)]
    $next = $order[(($i + 1) % $order.Count)]

    # --- JSON-LD ---
    $ld = [ordered]@{
      '@context'    = 'https://schema.org'
      '@type'       = 'Person'
      'name'        = $p.name
      'jobTitle'    = $roleDisp
      'url'         = $canonical
      'image'       = $ogImage
      'description' = (StripTags $desc)
      'worksFor'    = [ordered]@{
        '@type' = 'Organization'
        'name'  = 'Shiverbug Studios'
        'url'   = "$baseUrl/"
      }
    }
    if ($p.socials -and @($p.socials).Count -gt 0) {
      $ld['sameAs'] = @(@($p.socials) | ForEach-Object { $_.url })
    }
    $jsonld = ($ld | ConvertTo-Json -Depth 6).Replace('<', '<')

    $html = $template.
      Replace('{{NAME}}',      (HtmlEnc $p.name)).
      Replace('{{ROLE}}',      (HtmlEnc $roleDisp)).
      Replace('{{ROLELINE}}',  $roleLine).
      Replace('{{DESC}}',      (HtmlEnc (StripTags $desc))).
      Replace('{{CANONICAL}}', $canonical).
      Replace('{{OGIMAGE}}',   $ogImage).
      Replace('{{JSONLD}}',    $jsonld).
      Replace('{{PHOTO}}',     $photo).
      Replace('{{TAGLINE}}',   $tagline).
      Replace('{{BADGES}}',    $badges).
      Replace('{{ABOUT}}',     $about).
      Replace('{{ASKME}}',     $askMe).
      Replace('{{SOCIALS}}',   $socials).
      Replace('{{PREVHREF}}',  ($prev.slug + '.html')).
      Replace('{{PREVNAME}}',  (HtmlEnc (($prev.name -split ' ')[0]))).
      Replace('{{NEXTHREF}}',  ($next.slug + '.html')).
      Replace('{{NEXTNAME}}',  (HtmlEnc (($next.name -split ' ')[0])))

    WriteFileUtf8 (Join-Path $teamDir "$($p.slug).html") $html
    $written += $p.slug
  }
}

Write-Host "Wrote $($written.Count) team pages to team/"

# ---------- index.html team grids ----------

function MemberTile($p, [bool]$withStatus) {
  $cls = 'member reveal'
  if (-not $p.photo) { $cls = 'member member--placeholder reveal' }
  $out = '          <a class="' + $cls + '" href="team/' + $p.slug + '.html">' + "`n"
  if ($withStatus -and $p.status) {
    $label = if ($p.status -eq 'active') { 'Active' } else { 'Former' }
    $out += '            <span class="member__status member__status--' + $p.status + '">' + $label + '</span>' + "`n"
  }
  if ($p.photo) {
    $imgCls = ''
    if ($p.thumbClass) { $imgCls = ' class="' + $p.thumbClass + '"' }
    $imgStyle = ''
    if ($p.thumbStyle) { $imgStyle = ' style="' + $p.thumbStyle + '"' }
    $out += '            <div class="member__photo"><img src="' + $p.photo + '" alt="" loading="lazy"' + $imgCls + $imgStyle + '></div>' + "`n"
  } else {
    $out += '            <div class="member__photo member__photo--empty" aria-hidden="true"><span>' + (HtmlEnc $p.initials) + '</span></div>' + "`n"
  }
  $out += '            <h3>' + (HtmlEnc $p.name) + '</h3><p>' + (HtmlEnc (RoleDisplay $p)) + '</p>' + "`n"
  $out += '          </a>'
  return $out
}

$founders = @($team | Where-Object { $_.role -match '(?i)co-founder' })
$rest     = @($team | Where-Object { $_.role -notmatch '(?i)co-founder' })

$teamBlock = @()
$teamBlock += '        <p class="team__label reveal">Founders</p>'
$teamBlock += '        <div class="team__grid team__grid--founders">'
$teamBlock += (@($founders | ForEach-Object { MemberTile $_ $false }) -join "`n")
$teamBlock += '        </div>'
$teamBlock += ''
$teamBlock += '        <div class="team__grid">'
$teamBlock += (@($rest | ForEach-Object { MemberTile $_ $false }) -join "`n")
$teamBlock += '        </div>'
$teamHtml = $teamBlock -join "`n"

$talentHtml = @(
  '        <div class="team__grid">',
  (@($talent | ForEach-Object { MemberTile $_ $true }) -join "`n"),
  '        </div>'
) -join "`n"

$indexPath = Join-Path $root 'index.html'
$index = Get-Content $indexPath -Raw -Encoding UTF8

function ReplaceBlock([string]$text, [string]$marker, [string]$body) {
  $pattern = '(?s)(<!-- BUILD:' + $marker + ':START -->).*?(<!-- BUILD:' + $marker + ':END -->)'
  if ($text -notmatch $pattern) {
    throw "Marker BUILD:$marker not found in index.html - add <!-- BUILD:$marker`:START --> / <!-- BUILD:$marker`:END --> around the block."
  }
  return [regex]::Replace($text, $pattern, { param($m) $m.Groups[1].Value + "`n" + $body + "`n        " + $m.Groups[2].Value })
}

$index = ReplaceBlock $index 'TEAM' $teamHtml
$index = ReplaceBlock $index 'TALENT' $talentHtml
WriteFileUtf8 $indexPath $index
Write-Host "Updated the team grids in index.html"

# ---------- legacy ?p= redirect shim ----------

$mapLines = (@($all | ForEach-Object { "      '" + $_.id + "': '" + $_.slug + "'" }) -join ",`n")
$listHtml = @(
  '      <div class="team__grid">',
  (@($all | ForEach-Object { MemberTile $_ $false }) -join "`n"),
  '      </div>'
) -join "`n"

$shimPath = Join-Path $root 'team-member.html'
$shim = Get-Content $shimPath -Raw -Encoding UTF8

function ReplaceIn([string]$text, [string]$marker, [string]$body, [string]$indent) {
  $pattern = '(?s)(<!-- BUILD:' + $marker + ':START -->).*?(<!-- BUILD:' + $marker + ':END -->)'
  if ($text -notmatch $pattern) { throw "Marker BUILD:$marker not found in team-member.html" }
  return [regex]::Replace($text, $pattern, { param($m) $m.Groups[1].Value + "`n" + $body + "`n" + $indent + $m.Groups[2].Value })
}

$shim = ReplaceIn $shim 'REDIRECT-MAP' $mapLines '      '
$shim = ReplaceIn $shim 'REDIRECT-LIST' $listHtml '      '
WriteFileUtf8 $shimPath $shim
Write-Host "Updated the legacy ?p= redirect map in team-member.html"

# ---------- sitemap ----------

$pages = @(
  @{ loc = "$baseUrl/";              pri = '1.0' },
  @{ loc = "$baseUrl/co-dev.html";   pri = '0.9' },
  @{ loc = "$baseUrl/press.html";    pri = '0.7' }
)
foreach ($p in $all) { $pages += @{ loc = "$baseUrl/team/$($p.slug).html"; pri = '0.5' } }

$today = (Get-Date).ToString('yyyy-MM-dd')
$sm = @('<?xml version="1.0" encoding="UTF-8"?>', '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">')
foreach ($pg in $pages) {
  $sm += '  <url>'
  $sm += '    <loc>' + $pg.loc + '</loc>'
  $sm += '    <lastmod>' + $today + '</lastmod>'
  $sm += '    <priority>' + $pg.pri + '</priority>'
  $sm += '  </url>'
}
$sm += '</urlset>'
WriteFileUtf8 (Join-Path $root 'sitemap.xml') (($sm -join "`n") + "`n")
Write-Host "Updated sitemap.xml with $($pages.Count) URLs"

Write-Host ""
Write-Host "Done."
