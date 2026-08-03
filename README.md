# Shiverbug Studios website

The studio site for [Shiverbug Studios](https://shiverbugstudios.com/):
our debut game *Out of Water*, the team, and our co-development services.

Static HTML, CSS and vanilla JavaScript. No framework, no bundler, no
`node_modules`. It is served straight off GitHub Pages, and the tooling is
PowerShell that already ships with Windows.

## Read this before you change anything

**Do not hand-edit the generated files.** These are written by
`tools/build-team.ps1`, and CI fails if what you commit does not match what the
script produces:

| Generated | From |
| --- | --- |
| `team/*.html` (one page per person) | `data/team.json` |
| `team/index.html` (the roster hub) | `data/team.json` |
| The team grids in `index.html`, between the `BUILD:TEAM` / `BUILD:TALENT` markers | `data/team.json` |
| The structured-data block in `index.html`, between the `BUILD:SCHEMA` markers | `data/team.json` |
| The roster in `team-member.html`, between the `BUILD:REDIRECT-LIST` markers | `data/team.json` |
| `js/legacy-redirect.js` | `data/team.json` |
| `llms.txt` | `data/team.json` |
| `sitemap.xml` | the page list in the script, plus git history for `lastmod` |

`data/team.json` is the single source of truth for everyone on the site. Its
`_readme` key documents every field.

Everything else (`index.html` outside the markers, `co-dev.html`, `press.html`,
`privacy.html`, `accessibility.html`, `404.html`, the CSS and the JS) is written
by hand.

## Working on it

Run the build after touching `data/team.json`:

```bash
powershell -ExecutionPolicy Bypass -File tools/build-team.ps1
```

Then the validator, then commit the result:

```bash
powershell -ExecutionPolicy Bypass -File tools/validate-site.ps1
```

The validator checks every page for a single `<h1>`, a title, a description, a
canonical, a CSP tag, the Companies Act footer disclosure, valid JSON-LD, and
that every internal link and every `srcset` candidate resolves to a real file.
It exits non-zero, so CI gates on it.

If you added images, run the resizer first:

```bash
powershell -ExecutionPolicy Bypass -File tools/make-variants.ps1
```

That one is the exception to "no dependencies": it needs the .NET SDK, which it
uses to pull ImageSharp into a scratch project. It is a one-off asset step and
CI never runs it. Full order after adding art: **make-variants → build-team →
validate-site**. See `tools/README.md` for the detail.

To preview locally, use the dev server config in `.claude/launch.json`, or serve
the folder with anything that hands out static files.

## Things that will bite you

**Do not add a `.nojekyll` file without thinking.** GitHub Pages runs Jekyll on
this repo, and Jekyll skips any directory whose name starts with `_`. That is
load-bearing: it is what kept `_originals/` (full-resolution team photos and
art, around 145 MB) off the public site while it was still committed. It is
untracked now, so this is no longer a live hazard, but the same trap applies to
anything else parked under an underscore.

**Everything committed here is published.** Pages serves the whole repo at a
guessable URL, so a file dropped in "just to look at" goes public the moment it
is pushed. `.gitignore` blocks the usual suspects; the habit matters more.

**The repo path is hardcoded in two places.** `$baseUrl` in
`tools/build-team.ps1`, and every absolute reference in `404.html` (which Pages
serves for a missing path at *any* depth, so relative URLs there would resolve
against the wrong directory). Moving to a custom domain means updating both.

**`js/main.js` is one script scope.** It is a classic script, not a module, so a
top-level `const` collides with any other top-level `const` of the same name and
takes the whole file down with a `SyntaxError`. Check the name is free first.

**A profile with no `about` text is treated as unfinished.** Its tile stops being
a link, the page gets a `noindex`, it drops out of `sitemap.xml`, and the
prev/next chain steps over it. Fill in `about` in `data/team.json` and all of
that reverses itself on the next build.

## Accessibility

The site targets WCAG 2.2 Level AA and holds itself to the AAA 44×44 target size
throughout. `accessibility.html` is the public statement, including what is not
right yet. Keep it honest when you change behaviour.

## Licence

Code is free to learn from. The Shiverbug Studios name, logo, artwork,
screenshots and team photographs are not: they are © Shiverbug Studios Ltd and
are not licensed for reuse.
