// Shiverbug Studios site interactions

// This file is pure ASCII. It is a classic script with no charset of its own, so
// it inherits whatever encoding the page was decoded as; a literal curly quote
// here is only ever as safe as the last <meta charset> to reference it. Every
// apostrophe that reaches the page is built from its code point instead.
const RSQUO = String.fromCharCode(8217);

// ----- nav: scrolled state + mobile menu -----
// Guarded because co-dev.html is a bare meta-refresh stub with no header at all.
// Reaching for the burger there threw before anything else in this file ran,
// which cost that page its footer year and its click tracking.
(() => {
  const nav = document.getElementById('nav');
  const burger = document.getElementById('navBurger');
  const navLinks = document.getElementById('navLinks');
  if (!nav) return;

  window.addEventListener('scroll', () => {
    nav.classList.toggle('is-scrolled', window.scrollY > 10);
  }, { passive: true });

  if (!burger || !navLinks) return;

  // Below the breakpoint the open menu covers the page, so the rest of it goes
  // inert while it is up: no tabbing behind it, and screen readers skip it. The
  // same bargain the gallery viewer makes. On desktop the links are just part of
  // the header, nothing is covered, and none of this applies.
  const isOverlay = () => getComputedStyle(burger).display !== 'none';

  let inerted = [];
  const setBackgroundInert = (on) => {
    inerted.forEach((el) => { el.inert = false; });
    inerted = [];
    if (!on) return;
    inerted = [...document.body.children].filter((el) => el !== nav && !el.inert);
    inerted.forEach((el) => { el.inert = true; });
  };

  const setMenu = (open) => {
    nav.classList.toggle('is-open', open);
    burger.setAttribute('aria-expanded', String(open));
    setBackgroundInert(open && isOverlay());
  };

  burger.addEventListener('click', () => setMenu(!nav.classList.contains('is-open')));

  navLinks.addEventListener('click', (e) => {
    if (e.target.closest('a')) setMenu(false);
  });

  // The menu overlays the page, so it has to be dismissable without hunting for
  // the burger again: Escape (focus goes back to the button that opened it), or a
  // tap anywhere outside it.
  document.addEventListener('keydown', (e) => {
    if (!nav.classList.contains('is-open')) return;
    if (e.key === 'Escape') {
      setMenu(false);
      burger.focus();
    } else if (e.key === 'Tab' && isOverlay()) {
      // keep focus looping through the burger and the links it opened
      const els = [burger, ...navLinks.querySelectorAll('a[href]')];
      const first = els[0], last = els[els.length - 1];
      if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
      else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
    }
  });

  document.addEventListener('pointerdown', (e) => {
    if (nav.classList.contains('is-open') && !nav.contains(e.target)) setMenu(false);
  });

  // Widening past the breakpoint turns the overlay back into a plain header row.
  // Leaving it "open" would strand the inert flag on everything else on the page.
  window.addEventListener('resize', () => {
    if (nav.classList.contains('is-open') && !isOverlay()) setMenu(false);
  });
})();

// ----- tool chips: fall back to the plain name if a logo is missing -----
// The marks are supplied per vendor and some of them we don't hold yet. A chip
// with no logo file should look like the chip always did, not like a broken
// image, and checking naturalWidth covers the ones that already failed before
// this file ran.
document.querySelectorAll('.tool__logo').forEach((img) => {
  const drop = () => img.remove();
  if (img.complete && img.naturalWidth === 0) drop();
  else img.addEventListener('error', drop);
});

// The trailer player lived here. It's a still image while the new trailer is cut;
// restore this block from git history when the video goes back in.

// ----- reveal on scroll -----
const revealEls = document.querySelectorAll('.reveal');
if ('IntersectionObserver' in window) {
  const io = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('is-visible');
        io.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12, rootMargin: '0px 0px -40px 0px' });
  revealEls.forEach((el) => io.observe(el));
} else {
  revealEls.forEach((el) => el.classList.add('is-visible'));
}

// ----- tiles for people whose profile isn't written yet -----
// The build emits these as plain <div>/<span>, never links, so there is no dead
// end to walk into with or without JS. Here we upgrade them into real buttons
// that reveal a short note, the same bargain the gallery viewer makes: the
// affordance only appears once something is behind it.
(() => {
  let n = 0;
  const wire = (el, note) => {
    note.id = note.id || ('soon-' + (++n));
    el.setAttribute('role', 'button');
    el.setAttribute('tabindex', '0');
    el.setAttribute('aria-expanded', 'false');
    el.setAttribute('aria-controls', note.id);
    const toggle = () => {
      const open = note.hidden;
      note.hidden = !open;
      el.setAttribute('aria-expanded', String(open));
    };
    el.addEventListener('click', toggle);
    el.addEventListener('keydown', (e) => {
      if (e.key !== 'Enter' && e.key !== ' ') return;
      e.preventDefault();   // stop Space scrolling the page out from under it
      toggle();
    });
  };

  // team grids: the note is already in the markup, under the name and role
  document.querySelectorAll('.member--unfinished').forEach((tile) => {
    const note = tile.querySelector('.member__soon');
    if (note) wire(tile, note);
  });

  // co-dev crew chips: a chip is too small to hold the note, so each crew row
  // gets one shared line beneath it. Several chips share that one note, so this
  // can't use the plain toggle above: clicking a second person has to swap the
  // note over to them, not close it.
  document.querySelectorAll('.svc__crew').forEach((row) => {
    const chips = [...row.querySelectorAll('.person--unfinished')];
    if (!chips.length) return;
    const note = document.createElement('p');
    note.className = 'member__soon svc__crew-note';
    note.hidden = true;
    note.id = 'crew-soon-' + (++n);
    row.insertAdjacentElement('afterend', note);

    let openChip = null;
    const setOpen = (chip) => {
      openChip = chip;
      chips.forEach((c) => c.setAttribute('aria-expanded', String(c === chip)));
      note.hidden = !chip;
      if (chip) {
        const first = chip.querySelector('strong').textContent.trim().split(' ')[0];
        note.textContent = 'We haven' + RSQUO + 't written up ' + first + RSQUO +
                           's profile yet. Check back soon.';
      }
    };

    chips.forEach((chip) => {
      chip.setAttribute('role', 'button');
      chip.setAttribute('tabindex', '0');
      chip.setAttribute('aria-expanded', 'false');
      chip.setAttribute('aria-controls', note.id);
      const activate = () => setOpen(openChip === chip ? null : chip);
      chip.addEventListener('click', activate);
      chip.addEventListener('keydown', (e) => {
        if (e.key !== 'Enter' && e.key !== ' ') return;
        e.preventDefault();
        activate();
      });
    });
  });
})();

// ----- FAQ: one answer open at a time -----
// <details name="faq"> already does this natively - grouped like radio buttons,
// no script involved. Older browsers ignore the attribute and let every answer
// sit open at once, so only those get the hand-rolled version. Running both
// would mean two things racing to close the same panel.
if (!('name' in document.createElement('details'))) {
  document.querySelectorAll('details[name]').forEach((d) => {
    d.addEventListener('toggle', () => {
      if (!d.open) return;
      const group = d.getAttribute('name');
      document.querySelectorAll('details[name="' + group + '"]').forEach((other) => {
        if (other !== d) other.open = false;
      });
    });
  });
}

// ----- gallery carousels: arrows, drag-to-flick -----
document.querySelectorAll('.carousel').forEach((carousel) => {
  const track = carousel.querySelector('.carousel__track');
  if (!track || track.children.length === 0) return;
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const behavior = reduceMotion ? 'auto' : 'smooth';

  // looping clips only load and play while on screen (and never with reduced motion)
  const vids = track.querySelectorAll('video');
  if (vids.length && !reduceMotion && 'IntersectionObserver' in window) {
    const vio = new IntersectionObserver((entries) => {
      entries.forEach(({ isIntersecting, target }) => {
        // remembered so the pause control knows which clips to resume
        target.dataset.onScreen = String(isIntersecting);
        if (isIntersecting && target.dataset.userPaused !== 'true') target.play().catch(() => {});
        else target.pause();
      });
    }, { threshold: 0.25 });
    vids.forEach((v) => vio.observe(v));
  }

  // 2.2.2 Pause, Stop, Hide. The clips start on their own and loop well past five
  // seconds, so each one carries its own control, sitting on the clip it governs
  // instead of in a single strip further up the page where it read as unrelated
  // furniture. Built here rather than in the markup for the same reason the
  // viewer's role/tabindex are: with no JS nothing ever starts playing, and a
  // pause button over a still frame is a control for nothing.
  // Deliberately not persisted: remembering it would mean writing to the
  // visitor's device, and the privacy policy promises we store nothing.
  if (!reduceMotion) {
    vids.forEach((v) => {
      const slot = v.closest('.carousel__slot');
      if (!slot) return;
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'clip-toggle';
      btn.innerHTML =
        '<svg class="icon-pause" viewBox="0 0 16 16" aria-hidden="true"><rect x="3" y="2" width="4" height="12" rx="1" fill="currentColor"/><rect x="9" y="2" width="4" height="12" rx="1" fill="currentColor"/></svg>' +
        '<svg class="icon-play" viewBox="0 0 16 16" aria-hidden="true"><path d="M4 2.5v11l9-5.5z" fill="currentColor"/></svg>';
      // aria-pressed carries the state to assistive tech and swaps the icon in
      // CSS, so the two can't drift apart the way a separate class would.
      const sync = () => {
        const paused = v.dataset.userPaused === 'true';
        btn.setAttribute('aria-pressed', String(paused));
        btn.setAttribute('aria-label', paused ? 'Resume this clip' : 'Pause this clip');
      };
      btn.addEventListener('click', () => {
        const paused = v.dataset.userPaused !== 'true';
        v.dataset.userPaused = String(paused);
        if (paused) v.pause();
        else if (v.dataset.onScreen === 'true') v.play().catch(() => {});
        sync();
      });
      sync();
      slot.appendChild(btn);
    });
  }

  const step = () => Math.max(track.clientWidth * 0.8, 200);
  const prevBtn = carousel.querySelector('.carousel__btn--prev');
  const nextBtn = carousel.querySelector('.carousel__btn--next');
  prevBtn?.addEventListener('click', () => track.scrollBy({ left: -step(), behavior }));
  nextBtn?.addEventListener('click', () => track.scrollBy({ left: step(), behavior }));

  // grey out the arrows at either end of the strip
  const updateBtns = () => {
    const max = track.scrollWidth - track.clientWidth - 1;
    if (prevBtn) prevBtn.disabled = track.scrollLeft <= 1;
    if (nextBtn) nextBtn.disabled = track.scrollLeft >= max;
  };
  updateBtns();
  track.addEventListener('scroll', updateBtns, { passive: true });
  window.addEventListener('resize', updateBtns);

  // drag to flick through with a mouse (touch already scrolls natively)
  let dragging = false, dragged = false, startX = 0, startScroll = 0;
  track.addEventListener('pointerdown', (e) => {
    if (e.pointerType !== 'mouse') return;
    dragging = true; dragged = false;
    startX = e.clientX; startScroll = track.scrollLeft;
    track.classList.add('is-dragging');
  });
  window.addEventListener('pointermove', (e) => {
    if (!dragging) return;
    const dx = e.clientX - startX;
    if (Math.abs(dx) > 5) dragged = true;
    track.scrollLeft = startScroll - dx;
  });
  window.addEventListener('pointerup', () => {
    if (!dragging) return;
    dragging = false;
    track.classList.remove('is-dragging');
  });
  // a drag shouldn't count as a click on the artwork link
  track.addEventListener('click', (e) => {
    if (dragged) { e.preventDefault(); e.stopPropagation(); dragged = false; }
  }, true);
});

// ----- lightbox: click gallery art to view large, arrows to browse -----
(() => {
  const carousels = document.querySelectorAll('.carousel');
  if (!carousels.length) return;

  const overlay = document.createElement('div');
  overlay.className = 'lightbox';
  overlay.setAttribute('role', 'dialog');
  overlay.setAttribute('aria-modal', 'true');
  overlay.setAttribute('aria-label', 'Gallery viewer');
  overlay.innerHTML = `
    <button class="lightbox__close" type="button" aria-label="Close viewer">&times;</button>
    <button class="lightbox__btn lightbox__btn--prev" type="button" aria-label="Previous piece">&lsaquo;</button>
    <figure class="lightbox__figure">
      <!-- No src or href until there is something to put in them: an empty one
           is not "nothing", it resolves to the page's own URL and fetches it. -->
      <img class="lightbox__img" alt="">
      <video class="lightbox__video" controls loop playsinline hidden></video>
      <figcaption class="lightbox__caption"><strong class="lightbox__cap-title" hidden></strong><span class="lightbox__cap-text"></span><a class="lightbox__credit" hidden></a></figcaption>
    </figure>
    <button class="lightbox__btn lightbox__btn--next" type="button" aria-label="Next piece">&rsaquo;</button>`;
  document.body.appendChild(overlay);

  const imgEl = overlay.querySelector('.lightbox__img');
  const vidEl = overlay.querySelector('.lightbox__video');
  const capEl = overlay.querySelector('.lightbox__cap-text');
  const titleEl = overlay.querySelector('.lightbox__cap-title');
  const creditEl = overlay.querySelector('.lightbox__credit');
  let items = [], index = 0, lastFocus = null;

  const show = (i) => {
    index = (i + items.length) % items.length;
    const item = items[index];
    if (item.video) {
      imgEl.hidden = true; imgEl.removeAttribute('src');
      if (vidEl.getAttribute('src') !== item.video) vidEl.src = item.video;
      vidEl.hidden = false;
      vidEl.play().catch(() => {});
    } else {
      vidEl.pause(); vidEl.hidden = true;
      imgEl.hidden = false;
      imgEl.src = item.href;
      imgEl.alt = item.alt;
    }
    titleEl.textContent = item.title || '';
    titleEl.hidden = !item.title;
    // the write-up if the piece has one, otherwise the plain visual description
    capEl.textContent = item.desc || item.alt;
    if (item.credit) {
      creditEl.textContent = 'Work by ' + item.credit;
      // Credits for people without a written-up profile are plain labels, so
      // there is no href to hang on them. An <a> without one isn't focusable,
      // which is exactly right: it goes nowhere.
      if (item.creditHref) creditEl.href = item.creditHref;
      else creditEl.removeAttribute('href');
      creditEl.hidden = false;
    } else {
      creditEl.hidden = true;
    }
  };
  // everything you can tab to inside the viewer, in document order
  const focusables = () => [...overlay.querySelectorAll('button, [href], video[controls]')]
    .filter((el) => !el.hidden && el.offsetParent !== null);

  // while the viewer is open the rest of the page is inert: no tabbing behind it,
  // and screen readers skip it too
  let inerted = [];
  const setBackgroundInert = (on) => {
    if (on) {
      inerted = [...document.body.children].filter((el) => el !== overlay && !el.inert);
      inerted.forEach((el) => { el.inert = true; });
    } else {
      inerted.forEach((el) => { el.inert = false; });
      inerted = [];
    }
  };

  const open = (list, i, fromEl) => {
    items = list; lastFocus = fromEl;
    show(i);
    overlay.classList.add('is-open');
    document.body.style.overflow = 'hidden';
    setBackgroundInert(true);
    // .lightbox is visibility:hidden until .is-open lands, and you can't focus what
    // isn't visible yet. Reading a layout property forces the style recalc right now
    // so the focus sticks. (requestAnimationFrame is too early: it runs before the
    // recalc, so the button is still hidden when the callback fires.)
    void overlay.offsetWidth;
    overlay.querySelector('.lightbox__close').focus();
  };
  const close = () => {
    overlay.classList.remove('is-open');
    document.body.style.overflow = '';
    setBackgroundInert(false);
    imgEl.removeAttribute('src');
    vidEl.pause();
    if (lastFocus) lastFocus.focus();
  };

  overlay.querySelector('.lightbox__close').addEventListener('click', close);
  overlay.querySelector('.lightbox__btn--prev').addEventListener('click', () => show(index - 1));
  overlay.querySelector('.lightbox__btn--next').addEventListener('click', () => show(index + 1));
  overlay.addEventListener('click', (e) => { if (e.target === overlay) close(); });
  document.addEventListener('keydown', (e) => {
    if (!overlay.classList.contains('is-open')) return;
    if (e.key === 'Escape') close();
    else if (e.key === 'ArrowLeft') show(index - 1);
    else if (e.key === 'ArrowRight') show(index + 1);
    else if (e.key === 'Tab') {
      // keep focus looping inside the viewer
      const els = focusables();
      if (!els.length) return;
      const first = els[0], last = els[els.length - 1];
      if (e.shiftKey && document.activeElement === first) { e.preventDefault(); last.focus(); }
      else if (!e.shiftKey && document.activeElement === last) { e.preventDefault(); first.focus(); }
      else if (!overlay.contains(document.activeElement)) { e.preventDefault(); first.focus(); }
    }
  });

  carousels.forEach((carousel) => {
    const track = carousel.querySelector('.carousel__track');
    if (!track) return;

    // Artwork tiles are links, so they already tab. Clip tiles are a bare
    // <video> with no control on them, which left them mouse-only: 2.1.1 wants
    // the same viewer reachable from the keyboard. The role and tabindex go on
    // here rather than in the markup because without JS there is no viewer to
    // open, and advertising a button that does nothing is worse than neither.
    track.querySelectorAll('.carousel__slot > video').forEach((v) => {
      v.setAttribute('role', 'button');
      v.setAttribute('tabindex', '0');
      if (!v.hasAttribute('aria-label')) v.setAttribute('aria-label', 'Open clip in the gallery viewer');
    });
    track.addEventListener('keydown', (e) => {
      if (e.key !== 'Enter' && e.key !== ' ') return;
      const v = e.target.closest('video[role="button"]');
      if (!v) return;
      e.preventDefault();
      v.click();
    });

    track.addEventListener('click', (e) => {
      const a = e.target.closest('a[href]');
      if (a && a.classList.contains('carousel__credit')) return; // credit chips navigate normally
      const v = a ? null : e.target.closest('video');
      if ((!a && !v) || !track.contains(a || v)) return;
      e.preventDefault();
      // unique pieces (images and clips) in display order
      const seen = new Set(), list = [];
      track.querySelectorAll('.carousel__slot').forEach((slot) => {
        const credit = slot.querySelector('.carousel__credit');
        const base = {
          credit: credit ? credit.textContent.trim() : '',
          creditHref: credit ? credit.getAttribute('href') : '',
          title: slot.dataset.title || '',
          desc: slot.dataset.desc || ''
        };
        const art = slot.querySelector('a[href]:not(.carousel__credit)');
        const clip = slot.querySelector('video');
        if (art) {
          const href = art.getAttribute('href');
          if (seen.has(href)) return;
          seen.add(href);
          list.push({ ...base, href, alt: art.querySelector('img') ? art.querySelector('img').alt : '' });
        } else if (clip) {
          const src = clip.getAttribute('src');
          if (seen.has(src)) return;
          seen.add(src);
          list.push({ ...base, video: src, alt: clip.getAttribute('aria-label') || '' });
        }
      });
      const key = a ? a.getAttribute('href') : v.getAttribute('src');
      open(list, Math.max(0, list.findIndex((x) => (x.href || x.video) === key)), a || v);
    });
  });
})();

// ----- analytics: count the handful of moments that actually matter -----
// GoatCounter events, on the same cookieless endpoint as the page view. Nothing
// here identifies anyone: it is a label and a count, so it stays inside what the
// privacy policy promises and still needs no consent banner. count.js loads
// async, so every call is guarded rather than assumed.
const countEvent = (name) => {
  const gc = window.goatcounter;
  if (gc && typeof gc.count === 'function') {
    gc.count({ path: name, title: name, event: true });
  }
};

const slug = (s) => s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');

document.addEventListener('click', (e) => {
  const a = e.target.closest('a[href]');
  if (!a) return;
  const href = a.getAttribute('href') || '';
  if (a.hasAttribute('download')) {
    countEvent('download-' + href.split('/').pop());
  } else if (a.dataset.cta) {
    // The "start a conversation" buttons used to be mailto links, whose ?subject=
    // was the only thing telling a publishing enquiry apart from a co-dev one in
    // the inbox. They point at the forms now, so carry that label across by hand:
    // the general form has a single _subject covering everything that lands in it.
    // The co-dev form sets its own, more specific subject and is left alone.
    countEvent('cta-' + slug(a.dataset.cta));
    const subject = document.querySelector('#contactForm input[name="_subject"]');
    if (subject) subject.value = a.dataset.cta;
    // Same bargain the package cards make: arrive with the opening line already
    // written rather than on a blank box. Never overwrites anything already typed.
    if (a.dataset.prefill) {
      const msg = document.querySelector('#contactForm textarea[name="message"]');
      if (msg && !msg.value.trim()) msg.value = a.dataset.prefill;
    }
  } else if (a.dataset.package) {
    // A package card was clicked. It's a plain #contact link, so the scroll
    // happens on its own; all this adds is arriving with the size already picked
    // and an opening line written, so nobody lands on a blank form wondering
    // which of the three they were just reading about.
    countEvent('package-' + slug(a.dataset.package));
    const form = document.getElementById('codevForm');
    if (form) {
      const size = form.querySelector('select[name="package"]');
      if (size) {
        const want = [...size.options].find((o) => o.text.indexOf(a.dataset.package) === 0);
        if (want) size.value = want.value || want.text;
      }
      // never overwrite something they have already started typing
      const msg = form.querySelector('textarea[name="message"]');
      if (msg && !msg.value.trim()) {
        msg.value = 'We' + RSQUO + 're interested in the ' + a.dataset.package +
                    ' package (' + a.dataset.packageName + ').\n\nHere' + RSQUO +
                    's what we' + RSQUO + 're building: ';
      }
    }
  } else if (href.startsWith('mailto:')) {
    // the ?subject= is what tells press enquiries apart from general
    const subject = href.split('subject=')[1] || 'general';
    countEvent('mailto-' + slug(decodeURIComponent(subject)));
  }
});

// ----- forms: post in the background so nobody gets bounced off the site -----
// Both endpoints send Access-Control-Allow-Origin, so we can read the result.
// Without JS the forms still submit natively, which is why the action stays on them.
const enhanceForm = (form, sentMsg, errorMsg, eventName) => {
  if (!form) return;
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = form.querySelector('button[type="submit"]');
    form.parentNode.querySelector('.form-note')?.remove();
    btn.disabled = true;
    // Success is polite, failure is assertive: a send that didn't go through is
    // the one thing the visitor has to act on.
    const note = document.createElement('p');
    try {
      const res = await fetch(form.action, {
        method: 'POST',
        body: new FormData(form),
        headers: { 'Accept': 'application/json' }
      });
      if (res.ok) {
        note.className = 'form-note form-sent';
        note.textContent = sentMsg;
        form.reset();
        if (eventName) countEvent(eventName);
      } else {
        note.className = 'form-note form-error';
        note.textContent = errorMsg;
      }
    } catch (err) {
      note.className = 'form-note form-error';
      note.textContent = errorMsg;
    }
    note.setAttribute('role', note.classList.contains('form-error') ? 'alert' : 'status');
    form.parentNode.insertBefore(note, form);
    btn.disabled = false;
  });
};

enhanceForm(
  document.getElementById('contactForm'),
  "Message sent! We'll get back to you soon.",
  "Hmm, that didn't send. Try again, or email us directly above.",
  'contact-form-sent'
);

enhanceForm(
  document.getElementById('codevForm'),
  "Thanks. That's with us, and you'll hear back within a couple of working days.",
  "Hmm, that didn't send. Try again, or email us directly above.",
  'codev-enquiry-sent'
);

enhanceForm(
  document.getElementById('newsletterForm'),
  'Almost there. Check your inbox and confirm your address.',
  "Hmm, that didn't go through. Give it another go in a moment.",
  'newsletter-signup'
);

// ----- footer year -----
const year = document.getElementById('year');
if (year) year.textContent = new Date().getFullYear();

// ----- press kit: copy the boilerplate -----
// Progressive enhancement. The buttons are in the markup, but a press kit whose
// copy blocks can only be selected by hand is a press kit people retype, so if
// the clipboard API is unavailable the buttons come out rather than sit there
// doing nothing.
(() => {
  const buttons = [...document.querySelectorAll('[data-copy]')];
  if (!buttons.length) return;

  if (!navigator.clipboard) {
    buttons.forEach((btn) => { btn.remove(); });
    return;
  }

  buttons.forEach((btn) => {
    const source = document.querySelector(btn.dataset.copy);
    if (!source) { btn.remove(); return; }

    const label = btn.textContent;
    let reset;

    // aria-live would announce on every press; changing the button's own label
    // is announced once, by the control the user just activated.
    const say = (text, done) => {
      btn.textContent = text;
      btn.classList.toggle('is-done', !!done);
      clearTimeout(reset);
      reset = setTimeout(() => {
        btn.textContent = label;
        btn.classList.remove('is-done');
      }, 2500);
    };

    btn.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(source.textContent.trim());
        say('Copied', true);
      } catch {
        // Clipboard permission can be refused (locked-down enterprise policy,
        // an embedded webview, an insecure origin). Telling someone to press
        // Ctrl+C is only useful if the thing they want is already selected, so
        // do that part for them.
        const range = document.createRange();
        range.selectNodeContents(source);
        const selection = window.getSelection();
        selection.removeAllRanges();
        selection.addRange(range);
        say('Selected - press Ctrl+C');
      }
    });
  });
})();
