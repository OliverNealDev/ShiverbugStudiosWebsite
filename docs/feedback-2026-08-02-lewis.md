# Website Feedback — Lewis, weekend of 1–2 Aug 2026

Transcribed from Lewis Mennim's handwritten notes. Source: photo of notebook page,
handed over 2 Aug 2026.

Legend: **[code]** = fixable in this repo today · **[asset]** = blocked on someone
producing an image/render · **[decision]** = needs a call before anyone touches it.
Items marked **DONE** were actioned on 2 Aug 2026.

---

## Branding / logo

1. **Shiverbug text icon needs to be made bigger.** **[code/asset]**
   Believed to mean the wordmark in the header/nav.
2. **Shiverbug icon needs a transparent background, and to be larger.** **[asset]**
   `assets/img/logo.webp` and `logo-260.webp`. Transparency is an asset re-export,
   not a CSS fix. Sizing is `.hero__logo` / `.footer__logo` in `css/style.css`.
   Note the hero logo is currently preloaded at `index.html:31` — if the file is
   replaced, keep the preload and the `width`/`height` attributes in sync.

## Credibility / partner marks

3. **UK Games Fund and the others need logos over text.** **[decision]**
   Currently rendered as plain text in the "Part of" strip (`index.html:346–359`).
   The inline comment there records a deliberate choice: we don't hold usage rights
   to those marks. Actioning this means securing permission from UK Games Fund,
   Games Republic, Entrepreneurs Forum and Tranzfuser first.
4. **Public Vote Winner needs an image.** **[asset]**
   The Tranzfuser award currently shows as a text note (`index.html:353–356`).
   Needs a badge/photo — again subject to Tranzfuser brand permission.

## Services section

5. **Remove the "Pause the looping clips" button.** **[decision]** — **DONE**
   The objection was distance: the button sat under the section header, nowhere
   near the clips it governed. The global button is gone; each clip now carries
   its own 44px pause control in its bottom-right corner, opposite the artist
   credit chip. Still WCAG 2.2.2 conformant — the standard requires a mechanism,
   not a particular location, and putting it on the clip makes the relationship
   obvious. Only two clips on the whole page auto-play (the statue-key animation
   in Concept Art and the CyberStation clip in Design & Development); both were
   already fully suppressed under `prefers-reduced-motion`, and still are.
   The control is injected by `js/main.js` rather than written into the markup,
   following the same rule the gallery viewer uses: with no JS the clips never
   start, so a pause button would be a control over nothing.
   `accessibility.html` has been updated to describe the new control — it
   previously told visitors about a button that no longer exists.
6. **"01, 02, 03" — unclear what this is for.** **[code]** — **DONE**
   The `.svc__num` counters on the four service blocks. Removed from all four
   articles in `index.html`, and the `.svc__num` rule dropped from `css/style.css`.
   They were decoration with no referent, and nothing else on the page pointed at
   them. The coloured top border still distinguishes each service block.
7. **Stylized 3D Art: remove the WIP shots.** **[code]** — **DONE**
   Read as the two untextured-model slides: "Coral Quarters: Untextured Model"
   (Josh Cairns) and "Enchanted Witch's Hut: Untextured Model" (Martin Wilkinson).
   Gallery is now 3 slides. **Check this reading with Lewis** — if he meant
   something else in that gallery, the slides are recoverable from git.
8. **Connor: needs new renders of the Pip-Boy — remove until that happens.** **[asset]** — **removed**
   The "wrist device" slide is out of the Hard Surface gallery, which is now 3
   slides. The image files are still in `assets/img/art/codev-3d-wrist-device*`,
   so putting it back is one line once Connor supplies the new renders. He keeps
   his crew chip on the service — only the gallery piece went.
9. **Level design screenshots give nothing — remove.** **[code]** — **DONE**
   Removed the RebelX blockout and Lux Mortis layout slides from the Design &
   Development gallery, which is now 2 slides (CyberStation, Gridlock). Note this
   leaves Charlie Ashall with no gallery credit anywhere on the page.
10. **Engines & tools need images / logos.** **[asset]** — **wiring done, files needed**
    The chips (Unity, Unreal Engine 5, C#, Blender, ZBrush, Substance 3D,
    Photoshop) can now carry a mark. To add one:

    1. Drop the file at `assets/img/tools/<name>.svg` (or `.png`), square, ~40px.
    2. In the chip, put the image before the name:
       `<span class="tool"><img class="tool__logo" src="assets/img/tools/unity.svg" alt="" width="20" height="20">Unity</span>`

    Don't add `loading="lazy"` — these are 20px icons, and lazy-loading delays the
    missing-file fallback until the row scrolls into view.

    The name always stays alongside the mark. A row of seven bare vendor logos is
    unreadable to anyone who doesn't recognise all seven on sight, and the chips
    are there to answer "what do you work in", not to decorate.

    Missing files degrade safely: `js/main.js` strips any `.tool__logo` that fails
    to load, so the chip falls back to the plain name it has now. Verified by
    pointing a chip at a file that doesn't exist — the image was removed and the
    chip rendered identically to its neighbours.

    **No logo files are in the repo** — `assets/` contains only Shiverbug's own
    marks. These have to come from each vendor's brand page; they can't be drawn
    from scratch without producing something that's both wrong and still
    trademarked.

## Team

11. **Team headshots need centering.** **[code]** — **investigated, not changed**
    The mechanism already exists: `thumbClass: "is-zoomed"` and `thumbStyle` in
    `data/team.json`, tuned per photo with `--zx/--zy/--zs` (see the comment at
    `css/style.css:738`), then rebuilt with `tools/build-team.ps1`. All four
    founders carry zoom values; nobody in the studio row does, so they all sit at
    the flat `object-position: center 20%` default and read as more zoomed-out
    than the founders above them. That inconsistency is probably what Lewis saw.
    Two specific cases:
    - **Sarah Childs** — her face sits about 76% of the way across the frame. The
      tile is square and the source is 3:4, so `object-position` has no horizontal
      slack to pan with; centring her needs roughly a 2.1x zoom, which crops out
      the turtle and seagull mascots beside her. That's a judgement call.
    - **Charlie Ashall** — the photo is a full-length graduation shot, so his head
      is a tiny fraction of the frame. No crop rescues this; it's item 12.

    Left alone deliberately: picking per-photo zoom values is an eyeball job, and
    it wasn't possible to see the rendered grid this session.
12. **New headshot for Charlie Ashall.** **[asset]**
13. **Hollie: image added, plus a profile.** **[asset/code]**
    `team/hollie.html` exists; check `data/team.json` and re-run `tools/build-team.ps1`
    once the photo and bio land.

## Content / new material

14. **Access to the pitch deck — perhaps?** **[decision]** — **DONE, but see the warning**
    Built as a gated request rather than a public download: a "Request the pitch
    deck" button in the new For Publishers section on `games.html`. It reuses the
    existing `data-cta` plumbing, so the enquiry lands in the inbox with the
    subject "Pitch deck request" and the message box already opened with
    "I'd like the Out of Water pitch deck. Here's who I am:". Gated is what
    publishers expect, and it tells you who's asking.

    **This button promises a deck exists.** Nothing was checked about whether one
    does. If there isn't a deck ready to send, pull the button until there is —
    it's one line in `games.html`.
15. **Shiverbug press kit needs work.** **[code/asset]**
    `press.html` and `assets/press/`.

## Bugs

16. **Pressing "Get in touch" — the focus ring overwrites the underlined "a Hand".** **[code]** — **DONE**
    Confirmed and measured. The squiggle graphic hangs `.18em` below the heading's
    box, and the global focus ring sat at `outline-offset: 2px` — so at the
    heading's size the ring's bottom edge cut straight through the squiggle, in
    `--sand`, which is near enough the squiggle's own colour to read as a broken
    underline. Added `#contact:focus-visible` in `css/style.css` with
    `outline-offset: .3em` and a white ring. Because both the overhang and the
    offset are in `em`, the ring clears the squiggle by a constant `.12em` at
    every step of the heading's `clamp(2.1rem, 4.5vw, 3.4rem)`.

---

## Found while fixing the above (not from Lewis)

- **Unclosed `<div>` in the Hard Surface gallery.** **[code]** — **DONE**
  `.carousel__track` was never closed, so the "Scroll gallery forward" button was
  parsed *inside* the scrolling track instead of beside it — it would have scrolled
  away with the slides. The other three galleries close it correctly. Verified
  fixed: all four galleries now report zero buttons inside their track.

## Rough grouping for planning

| Done | Needs a file from someone | Needs a decision first |
| --- | --- | --- |
| 5 (per-clip pause controls), 6 (01/02/03), 7 (WIP shots), 8 (Pip-Boy pulled), 9 (level design shots), 16 (focus ring), plus the unclosed-div bug | 2 (logo re-export), 4, 10 (vendor marks — wiring ready), 11 (needs an eye on the grid), 12 (Charlie headshot), 13 (Hollie), 15 (press kit) | 3 (funder marks — permission), 14 (pitch deck) |

Item 1 is neither: the nav wordmark is already transparent and 316x138 native but
renders at 30px tall, so it can be enlarged in CSS with no new file.

## Open questions back to Lewis

- Item 1: is the "text icon" the nav wordmark, the footer logo, or both?
- Item 5: is the objection the button's presence, its wording, or its position? If
  the clips didn't autoplay, the button wouldn't be needed at all.
- Item 7: was "WIP shots" the two untextured-model slides? That's how it was read.
- Item 9: the screenshots are gone. Replace them with something else (annotated
  layouts, a flythrough), or leave Design & Development on two slides? As it
  stands Charlie Ashall has no work shown anywhere on the page.
- Item 14: who is the pitch deck for — publishers, or anyone who asks?
