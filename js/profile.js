// Progressive enhancement for the static team pages in /team.
// Everything here is optional: the page is complete and readable without it.

(function () {
  // ----- "Read more" clamp for long bios -----
  // The full bio is always in the HTML (so crawlers and no-JS visitors get it);
  // we only fold it up once we know JS can unfold it again.
  const about = document.getElementById('aboutText');
  if (about && about.dataset.clamp === 'true') {
    about.classList.add('is-clamped');

    const btn = document.createElement('button');
    btn.className = 'profile__more';
    btn.type = 'button';
    btn.textContent = 'Read more';
    btn.setAttribute('aria-expanded', 'false');
    btn.setAttribute('aria-controls', 'aboutText');
    about.insertAdjacentElement('afterend', btn);

    btn.addEventListener('click', () => {
      const open = !about.classList.toggle('is-clamped');
      btn.textContent = open ? 'Show less' : 'Read more';
      btn.setAttribute('aria-expanded', String(open));
    });
  }

  // The "Back" link that used to sit here was replaced by the breadcrumb trail,
  // which says where you are as well as where it goes. history.back() went with
  // it: a crumb labelled "Team" has to lead to the team, not to wherever you
  // happened to arrive from.
})();
