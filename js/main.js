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

// ----- news: swap cards for real LinkedIn post embeds when URLs are set -----
const embeds = window.LINKEDIN_EMBEDS || [];
document.querySelectorAll('.news__grid .post').forEach((post, i) => {
  const url = embeds[i];
  if (!url) return;
  post.classList.add('post--embed');
  post.innerHTML = `<iframe src="${url}" title="LinkedIn post" loading="lazy" allowfullscreen></iframe>`;
});

// ----- footer year -----
const year = document.getElementById('year');
if (year) year.textContent = new Date().getFullYear();
