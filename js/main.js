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

// ----- gallery carousels: arrow buttons scroll the track -----
document.querySelectorAll('.carousel').forEach((carousel) => {
  const track = carousel.querySelector('.carousel__track');
  if (!track) return;
  const behavior = window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 'auto' : 'smooth';
  const step = () => Math.max(track.clientWidth * 0.8, 200);
  carousel.querySelector('.carousel__btn--prev')?.addEventListener('click', () => track.scrollBy({ left: -step(), behavior }));
  carousel.querySelector('.carousel__btn--next')?.addEventListener('click', () => track.scrollBy({ left: step(), behavior }));
});

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
