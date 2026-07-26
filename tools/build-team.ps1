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

# Topics for schema.org knowsAbout - this is what an AI agent reads to answer
# "who at this studio does X?". Derived from the role title only, so it stays
# truthful; add a "knowsAbout" array in team.json to override for anyone.
$disciplines = @(
  @{ match = 'gameplay programmer|programmer'; topics = @('Gameplay Programming', 'Game Programming') },
  @{ match = 'character concept artist';       topics = @('Concept Art', 'Character Design') },
  @{ match = 'concept artist';                 topics = @('Concept Art') },
  @{ match = 'character artist';               topics = @('Character Art', '3D Art') },
  @{ match = 'lead artist';                    topics = @('Art Direction', '3D Art') },
  @{ match = '3d artist';                      topics = @('3D Art', 'Environment Art') },
  @{ match = '3d animator|animator';           topics = @('3D Animation') },
  @{ match = 'level designer';                 topics = @('Level Design', 'Game Design') },
  @{ match = 'narrative designer';             topics = @('Narrative Design', 'Game Writing') },
  @{ match = 'sound designer';                 topics = @('Sound Design', 'Game Audio') },
  @{ match = 'social media';                   topics = @('Social Media Marketing') },
  @{ match = 'ceo|cfo';                        topics = @('Game Studio Management') }
)

function KnowsAbout($person) {
  if ($person.knowsAbout -and @($person.knowsAbout).Count -gt 0) { return @($person.knowsAbout) }
  $topics = @('Video Game Development')
  foreach ($d in $disciplines) {
    if ($person.role -match ('(?i)' + $d.match)) { $topics += $d.topics; break }
  }
  return @($topics)
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
  <!-- Analytics: GoatCounter. Cookieless, no personal data, no consent banner needed. -->
  <script data-goatcounter="https://oliverneal04.goatcounter.com/count" async src="https://gc.zgo.at/count.js"></script>
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

    # --- JSON-LD: ProfilePage wrapping a Person, plus a breadcrumb trail.
    #     The @id refs let a crawler stitch person -> studio -> other people. ---
    $person = [ordered]@{
      '@type'       = 'Person'
      '@id'         = "$canonical#person"
      'name'        = $p.name
      'jobTitle'    = $roleDisp
      'url'         = $canonical
      'image'       = $ogImage
      'description' = (StripTags $desc)
      'knowsAbout'  = @(KnowsAbout $p)
      'worksFor'    = [ordered]@{
        '@type' = 'Organization'
        '@id'   = "$baseUrl/#studio"
        'name'  = 'Shiverbug Studios'
        'url'   = "$baseUrl/"
      }
    }
    if ($p.socials -and @($p.socials).Count -gt 0) {
      $person['sameAs'] = @(@($p.socials) | ForEach-Object { $_.url })
    }

    $crumbs = [ordered]@{
      '@type'           = 'BreadcrumbList'
      'itemListElement' = @(
        [ordered]@{ '@type' = 'ListItem'; 'position' = 1; 'name' = 'Shiverbug Studios'; 'item' = "$baseUrl/" },
        [ordered]@{ '@type' = 'ListItem'; 'position' = 2; 'name' = 'Team'; 'item' = "$baseUrl/team/" },
        [ordered]@{ '@type' = 'ListItem'; 'position' = 3; 'name' = $p.name }
      )
    }

    $ld = [ordered]@{
      '@context' = 'https://schema.org'
      '@graph'   = @(
        [ordered]@{
          '@type'      = 'ProfilePage'
          '@id'        = $canonical
          'url'        = $canonical
          'name'       = "$($p.name) | Shiverbug Studios"
          'mainEntity' = @{ '@id' = "$canonical#person" }
          'breadcrumb' = $crumbs
          'isPartOf'   = @{ '@id' = "$baseUrl/#website" }
        },
        $person
      )
    }
    $jsonld = ($ld | ConvertTo-Json -Depth 12).Replace('<', '<')

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

# ---------- team/index.html : a real hub page at a clean URL ----------

$teamIndexTemplate = @'
<!DOCTYPE html>
<html lang="en-GB">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>The Team | Shiverbug Studios</title>
  <meta name="description" content="{{DESC}}">
  <link rel="canonical" href="{{BASE}}/team/">
  <meta property="og:title" content="The Team | Shiverbug Studios">
  <meta property="og:description" content="{{DESC}}">
  <meta property="og:image" content="{{BASE}}/assets/img/founders.jpg">
  <meta property="og:url" content="{{BASE}}/team/">
  <meta property="og:type" content="website">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="The Team | Shiverbug Studios">
  <meta name="twitter:description" content="{{DESC}}">
  <meta name="twitter:image" content="{{BASE}}/assets/img/founders.jpg">
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
        <a href="index.html" aria-current="page">Team</a>
        <a href="../press.html">Press</a>
        <a class="nav__cta" href="mailto:contact@shiverbugstudios.com">Get in touch</a>
      </nav>
      <button class="nav__burger" id="navBurger" aria-label="Open menu" aria-expanded="false" aria-controls="navLinks">
        <span></span><span></span>
      </button>
    </div>
  </header>

  <main class="profile team" id="top">
    <div class="container">
      <header class="section__head">
        <p class="kicker kicker--leaf">The shiverbugs</p>
        <h1>Meet the <span class="underline-leaf">Team</span></h1>
        <p class="section__lede">
          {{LEDE}}
        </p>
      </header>

      <p class="team__label">Founders</p>
      <div class="team__grid team__grid--founders">
{{FOUNDERS}}
      </div>

      <p class="team__label">The studio</p>
      <div class="team__grid">
{{CORE}}
      </div>

      <header class="section__head team__pool-head">
        <p class="kicker kicker--sea">The talent pool</p>
        <h2>Friends of the <span class="underline-sea">Studio</span></h2>
        <p class="section__lede">Brilliant people who've helped shape our games, from guest contributors to former shiverbugs.</p>
      </header>

      <div class="team__grid">
{{TALENT}}
      </div>
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
  <!-- Analytics: GoatCounter. Cookieless, no personal data, no consent banner needed. -->
  <script data-goatcounter="https://oliverneal04.goatcounter.com/count" async src="https://gc.zgo.at/count.js"></script>
</body>
</html>
'@

$teamCount = @($team).Count
$talentCount = @($talent).Count
$hubDesc = "The $teamCount designers, artists and programmers building Out of Water at Shiverbug Studios in North East England, plus $talentCount friends of the studio. Every profile lists their discipline, portfolio and contact links."
$hubLede = "Everyone who makes Shiverbug work. Click anyone to read their story, see their portfolio and find them elsewhere."

# ItemList of every person, so one fetch of /team/ gives a crawler the whole roster
$listItems = @()
$pos = 0
foreach ($p in $all) {
  $pos++
  $listItems += [ordered]@{
    '@type'    = 'ListItem'
    'position' = $pos
    'item'     = [ordered]@{
      '@type'    = 'Person'
      '@id'      = "$baseUrl/team/$($p.slug).html#person"
      'name'     = $p.name
      'jobTitle' = (RoleDisplay $p)
      'url'      = "$baseUrl/team/$($p.slug).html"
    }
  }
}
$hubLd = [ordered]@{
  '@context'   = 'https://schema.org'
  '@type'      = 'CollectionPage'
  '@id'        = "$baseUrl/team/"
  'url'        = "$baseUrl/team/"
  'name'       = 'The Team | Shiverbug Studios'
  'description' = $hubDesc
  'isPartOf'   = @{ '@id' = "$baseUrl/#website" }
  'about'      = @{ '@id' = "$baseUrl/#studio" }
  'mainEntity' = [ordered]@{
    '@type'           = 'ItemList'
    'numberOfItems'   = $all.Count
    'itemListElement' = $listItems
  }
}

$hubHtml = $teamIndexTemplate.
  Replace('{{BASE}}',   $baseUrl).
  Replace('{{DESC}}',   (HtmlEnc $hubDesc)).
  Replace('{{LEDE}}',   (HtmlEnc $hubLede)).
  Replace('{{JSONLD}}', (($hubLd | ConvertTo-Json -Depth 12).Replace('<', '<'))).
  Replace('{{FOUNDERS}}', (@($founders | ForEach-Object { MemberTile $_ $false }) -join "`n")).
  Replace('{{CORE}}',     (@($rest     | ForEach-Object { MemberTile $_ $false }) -join "`n")).
  Replace('{{TALENT}}',   (@($talent   | ForEach-Object { MemberTile $_ $true  }) -join "`n"))

# MemberTile emits root-relative paths for index.html; inside team/ they need one level up
$hubHtml = $hubHtml.Replace('href="team/', 'href="').Replace('src="assets/', 'src="../assets/')
WriteFileUtf8 (Join-Path $teamDir 'index.html') $hubHtml
Write-Host "Wrote the team hub page at team/index.html"

# ---------- llms.txt : a curated map for AI agents ----------

$llms = @()
$llms += '# Shiverbug Studios'
$llms += ''
$llms += '> Independent video game studio in North East England, founded early 2025. Building Out of Water, a 2-player split-screen collectathon platformer, and taking on co-development and work-for-hire: concept art, 3D art, level design and gameplay programming.'
$llms += ''
$llms += ("Team of {0} people plus a talent pool of {1} regular collaborators. Contact: contact@shiverbugstudios.com" -f $teamCount, $talentCount)
$llms += ''
$llms += '## Studio'
$llms += ''
$llms += ("- [Home]({0}/): studio overview, Out of Water, the team" -f $baseUrl)
$llms += ("- [Co-development and work-for-hire]({0}/co-dev.html): services, process, rates approach, FAQ" -f $baseUrl)
$llms += ("- [Press kit]({0}/press.html): fact sheet, logos, screenshots, trailer" -f $baseUrl)
$llms += ("- [Privacy policy]({0}/privacy.html)" -f $baseUrl)
$llms += ''
$llms += '## Team'
$llms += ''
$llms += ("- [All {0} team members]({1}/team/): the full roster" -f $all.Count, $baseUrl)
foreach ($p in $team) {
  $bio = ''
  if ($p.about -and @($p.about).Count -gt 0) { $bio = ': ' + (Truncate (StripTags (@($p.about)[0])) 150) }
  $llms += ("- [{0} - {1}]({2}/team/{3}.html){4}" -f $p.name, (RoleDisplay $p), $baseUrl, $p.slug, $bio)
}
$llms += ''
$llms += '## Talent pool'
$llms += ''
foreach ($p in $talent) {
  $state = if ($p.status -eq 'former') { 'former shiverbug' } else { 'active contributor' }
  $bio = ''
  if ($p.about -and @($p.about).Count -gt 0) { $bio = ': ' + (Truncate (StripTags (@($p.about)[0])) 150) }
  $llms += ("- [{0} - {1}]({2}/team/{3}.html) ({4}){5}" -f $p.name, (RoleDisplay $p), $baseUrl, $p.slug, $state, $bio)
}
$llms += ''
WriteFileUtf8 (Join-Path $root 'llms.txt') (($llms -join "`n") + "`n")
Write-Host "Wrote llms.txt"

# ---------- index.html structured data graph ----------

$employees = @()
foreach ($p in $team) {
  $employees += [ordered]@{
    '@type'    = 'Person'
    '@id'      = "$baseUrl/team/$($p.slug).html#person"
    'name'     = $p.name
    'jobTitle' = (RoleDisplay $p)
    'url'      = "$baseUrl/team/$($p.slug).html"
  }
}
$foundersLd = @()
foreach ($p in $founders) {
  $foundersLd += @{ '@id' = "$baseUrl/team/$($p.slug).html#person" }
}

$siteLd = [ordered]@{
  '@context' = 'https://schema.org'
  '@graph'   = @(
    [ordered]@{
      '@type'       = 'Organization'
      '@id'         = "$baseUrl/#studio"
      'name'        = 'Shiverbug Studios'
      'legalName'   = 'Shiverbug Studios Ltd'
      'url'         = "$baseUrl/"
      'logo'        = "$baseUrl/assets/press/shiverbug-logo.png"
      'image'       = "$baseUrl/assets/img/out-of-water-screenshot.jpg"
      'email'       = 'contact@shiverbugstudios.com'
      'foundingDate' = '2025'
      'description' = 'Indie game development studio in North East England making couch co-op games, including debut title Out of Water, and offering co-development services: concept art, 3D art, level design and gameplay programming.'
      'address'     = [ordered]@{ '@type' = 'PostalAddress'; 'addressRegion' = 'North East England'; 'addressCountry' = 'GB' }
      'numberOfEmployees' = [ordered]@{ '@type' = 'QuantitativeValue'; 'value' = $teamCount }
      'knowsAbout'  = @('Video Game Development', 'Concept Art', '3D Art', 'Level Design', 'Gameplay Programming', 'Unity', 'Unreal Engine', 'Co-development')
      'founder'     = $foundersLd
      'employee'    = $employees
      'sameAs'      = @('https://linktr.ee/shiverbugstudios')
    },
    [ordered]@{
      '@type'       = 'WebSite'
      '@id'         = "$baseUrl/#website"
      'url'         = "$baseUrl/"
      'name'        = 'Shiverbug Studios'
      'publisher'   = @{ '@id' = "$baseUrl/#studio" }
      'inLanguage'  = 'en-GB'
    },
    [ordered]@{
      '@type'       = 'VideoGame'
      '@id'         = "$baseUrl/#out-of-water"
      'name'        = 'Out of Water'
      'url'         = "$baseUrl/#game"
      'description' = 'A 2-player split-screen collectathon platformer. One player is a turtle, the other a seagull, exploring a colourful world full of charm, clever challenges and an army of crabs.'
      'image'       = "$baseUrl/assets/img/out-of-water-screenshot.jpg"
      'genre'       = @('Platform game', 'Collectathon', 'Cooperative video game')
      'playMode'    = 'CoOp'
      'numberOfPlayers' = [ordered]@{ '@type' = 'QuantitativeValue'; 'minValue' = 2; 'maxValue' = 2 }
      'author'      = @{ '@id' = "$baseUrl/#studio" }
      'publisher'   = @{ '@id' = "$baseUrl/#studio" }
      'inLanguage'  = 'en'
    }
  )
}
$siteLdJson = ($siteLd | ConvertTo-Json -Depth 12).Replace('<', '<')

$index = Get-Content $indexPath -Raw -Encoding UTF8
$index = ReplaceBlock $index 'SCHEMA' ('  <script type="application/ld+json">' + "`n" + $siteLdJson + "`n" + '  </script>')
WriteFileUtf8 $indexPath $index
Write-Host "Updated the structured data graph in index.html"

# ---------- sitemap ----------

$pages = @(
  @{ loc = "$baseUrl/";              pri = '1.0' },
  @{ loc = "$baseUrl/co-dev.html";   pri = '0.9' },
  @{ loc = "$baseUrl/team/";         pri = '0.8' },
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
