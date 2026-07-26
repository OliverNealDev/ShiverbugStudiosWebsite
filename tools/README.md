# tools

Two PowerShell scripts. No Node, no npm, no install step — they run on the
Windows PowerShell that's already on the machine.

## build-team.ps1

`data/team.json` is the single source of truth for everyone at the studio.
This script reads it and writes:

| Output | What it is |
| --- | --- |
| `team/<slug>.html` | One real, crawlable page per person |
| `team/index.html` | The team hub at `/team/` |
| `index.html` | Team grids, between the `BUILD:TEAM` / `BUILD:TALENT` markers |
| `index.html` | Structured data graph, between the `BUILD:SCHEMA` markers |
| `team-member.html` | Legacy `?p=` redirect map and no-JS fallback list |
| `llms.txt` | Curated plain-text site map for AI agents |
| `sitemap.xml` | Every indexable URL |

```powershell
powershell -ExecutionPolicy Bypass -File tools/build-team.ps1
```

**To add or change someone:** edit `data/team.json`, run the script, commit
the result. Never hand-edit anything in `team/`, or the `BUILD:` blocks in
`index.html` — the next build overwrites them.

Notes:
- Bio paragraphs may contain HTML. Links to other profiles are sibling-relative,
  e.g. `<a href='lewis-mennim.html'>Lewis</a>`, because they render inside `team/`.
- `role` keeps `· Co-Founder`; the badge shows it, the role line strips it.
- Keep this file **pure ASCII**. Windows PowerShell 5.1 reads a BOM-less `.ps1`
  as ANSI, so a literal `·` or `—` in the source arrives mangled. Use
  `[char]0x00B7` or an HTML entity instead.

## validate-site.ps1

Checks every `.html` in the repo and exits non-zero on failure, so CI can gate
on it:

- internal links and asset references resolve to real files
- exactly one `<h1>`, plus a title, description and `lang`
- canonical, `twitter:card` and `og:image` on every indexable page
- every JSON-LD block parses and has an `@type` or `@graph`
- sitemap URLs correspond to real files, and indexable pages are listed
- the analytics tag is present and not commented out

```powershell
powershell -ExecutionPolicy Bypass -File tools/validate-site.ps1
```

Both run automatically on push and PR via
`.github/workflows/build-and-validate.yml`, which also fails if the committed
output doesn't match a fresh build.

## Local preview

`.claude/serve.ps1` serves the site at <http://localhost:5173>, including
directory index files so `/team/` resolves the same way GitHub Pages does.
