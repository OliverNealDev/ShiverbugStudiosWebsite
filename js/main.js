// Shiverbug Studios — site interactions

// ----- nav: scrolled state + mobile menu -----
const nav = document.getElementById('nav');
const burger = document.getElementById('navBurger');
const navLinks = document.getElementById('navLinks');

window.addEventListener('scroll', () => {
  nav.classList.toggle('is-scrolled', window.scrollY > 10);
}, { passive: true });

burger.addEventListener('click', () => {
  const open = nav.classList.toggle('is-open');
  burger.setAttribute('aria-expanded', String(open));
});

navLinks.addEventListener('click', (e) => {
  if (e.target.tagName === 'A') {
    nav.classList.remove('is-open');
    burger.setAttribute('aria-expanded', 'false');
  }
});

// ----- ticker: duplicate track content so the loop is seamless -----
const track = document.getElementById('tickerTrack');
if (track) track.innerHTML += track.innerHTML;

// ----- trailer: big play button overlay -----
const player = document.querySelector('.game__player');
const video = document.getElementById('trailer');
const playBtn = document.getElementById('playBtn');

if (video && playBtn) {
  playBtn.addEventListener('click', () => video.play());
  video.addEventListener('play', () => player.classList.add('is-playing'));
  video.addEventListener('pause', () => {
    if (video.ended) player.classList.remove('is-playing');
  });
  video.addEventListener('ended', () => player.classList.remove('is-playing'));
}

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
        if (isIntersecting) target.play().catch(() => {});
        else target.pause();
      });
    }, { threshold: 0.25 });
    vids.forEach((v) => vio.observe(v));
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
      <img class="lightbox__img" src="" alt="">
      <video class="lightbox__video" controls loop playsinline hidden></video>
      <figcaption class="lightbox__caption"><span class="lightbox__cap-text"></span><a class="lightbox__credit" href="" hidden></a></figcaption>
    </figure>
    <button class="lightbox__btn lightbox__btn--next" type="button" aria-label="Next piece">&rsaquo;</button>`;
  document.body.appendChild(overlay);

  const imgEl = overlay.querySelector('.lightbox__img');
  const vidEl = overlay.querySelector('.lightbox__video');
  const capEl = overlay.querySelector('.lightbox__cap-text');
  const creditEl = overlay.querySelector('.lightbox__credit');
  let items = [], index = 0, lastFocus = null;

  const show = (i) => {
    index = (i + items.length) % items.length;
    const item = items[index];
    if (item.video) {
      imgEl.hidden = true; imgEl.src = '';
      if (vidEl.getAttribute('src') !== item.video) vidEl.src = item.video;
      vidEl.hidden = false;
      vidEl.play().catch(() => {});
    } else {
      vidEl.pause(); vidEl.hidden = true;
      imgEl.hidden = false;
      imgEl.src = item.href;
      imgEl.alt = item.alt;
    }
    capEl.textContent = item.alt;
    if (item.credit) {
      creditEl.textContent = 'Work by ' + item.credit;
      creditEl.href = item.creditHref;
      creditEl.hidden = false;
    } else {
      creditEl.hidden = true;
    }
  };
  const open = (list, i, fromEl) => {
    items = list; lastFocus = fromEl;
    show(i);
    overlay.classList.add('is-open');
    document.body.style.overflow = 'hidden';
    overlay.querySelector('.lightbox__close').focus();
  };
  const close = () => {
    overlay.classList.remove('is-open');
    document.body.style.overflow = '';
    imgEl.src = '';
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
  });

  carousels.forEach((carousel) => {
    const track = carousel.querySelector('.carousel__track');
    if (!track) return;
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
          creditHref: credit ? credit.getAttribute('href') : ''
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

// ----- contact form: submit to Formspree in the background -----
const contactForm = document.getElementById('contactForm');
if (contactForm) {
  contactForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = contactForm.querySelector('button[type="submit"]');
    contactForm.parentNode.querySelector('.form-note')?.remove();
    btn.disabled = true;
    const note = document.createElement('p');
    note.setAttribute('role', 'status');
    try {
      const res = await fetch(contactForm.action, {
        method: 'POST',
        body: new FormData(contactForm),
        headers: { 'Accept': 'application/json' }
      });
      if (res.ok) {
        note.className = 'form-note form-sent';
        note.textContent = "Message sent! We'll get back to you soon.";
        contactForm.reset();
      } else {
        note.className = 'form-note form-error';
        note.textContent = "Hmm, that didn't send. Try again, or email us directly above.";
      }
    } catch (err) {
      note.className = 'form-note form-error';
      note.textContent = "Hmm, that didn't send. Try again, or email us directly above.";
    }
    contactForm.parentNode.insertBefore(note, contactForm);
    btn.disabled = false;
  });
}

// ----- footer year -----
const year = document.getElementById('year');
if (year) year.textContent = new Date().getFullYear();
