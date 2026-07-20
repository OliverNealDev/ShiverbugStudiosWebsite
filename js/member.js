// Renders a team member profile from js/team-data.js based on ?p=<slug>

(function () {
  const root = document.getElementById('profileRoot');
  if (!root || !window.TEAM) return;

  const slug = new URLSearchParams(location.search).get('p');
  const person = window.TEAM[slug];

  if (!person) {
    root.innerHTML = `
      <div class="profile__missing">
        <h1>Hmm, no shiverbug by that name.</h1>
        <p>They might be hiding in a shell. Try the team page instead.</p>
        <a class="btn btn--ink" href="index.html#team">Back to the team</a>
      </div>`;
    return;
  }

  document.title = `${person.name} | Shiverbug Studios`;
  const firstName = person.name.split(' ')[0];

  // --- favourite character badge ---
  const favourites = {
    turtle:  { cls: 'badge--turtle',  text: 'Team Turtle' },
    seagull: { cls: 'badge--seagull', text: 'Team Seagull' },
    crab:    { cls: 'badge--crab',    text: 'Team Crab (the army)' }
  };
  const fav = favourites[person.favourite];
  const favBadge = fav
    ? `<span class="badge ${fav.cls}">${fav.text}</span>`
    : `<span class="badge">Turtle or seagull? Undecided.</span>`;

  // --- talent pool status badge ---
  const statusBadge = person.status === 'active'
    ? `<span class="badge badge--active">Actively contributing</span>`
    : person.status === 'former'
      ? `<span class="badge badge--former">Former shiverbug</span>`
      : '';

  // --- photo ---
  const photo = person.photo
    ? `<img src="${person.photo}" alt="${person.name}">`
    : `<div class="profile__photo--empty"><span>${person.initials}</span></div>`;

  // --- tagline ---
  const tagline = person.tagline
    ? `<p class="profile__tagline">“${person.tagline}”</p>`
    : `<p class="profile__tagline">${firstName} hasn't picked a tagline yet. We're on it.</p>`;

  // --- about (long bios get clamped with a "Read more" toggle) ---
  const aboutParas = person.about && person.about.length ? person.about : null;
  const aboutLong = aboutParas && aboutParas.join(' ').length > 600;
  const about = aboutParas
    ? `<div class="profile__about${aboutLong ? ' is-clamped' : ''}" id="aboutText">${aboutParas.map(p => `<p>${p}</p>`).join('')}</div>` +
      (aboutLong ? `<button class="profile__more" id="aboutMore" aria-expanded="false" aria-controls="aboutText">Read more</button>` : '')
    : `<p class="is-placeholder">We're still squeezing a bio out of ${firstName}. Check back soon.</p>`;

  // --- ask me about ---
  const askMe = person.askMeAbout && person.askMeAbout.length
    ? `<section class="profile__section">
         <h2>Ask me about</h2>
         <div class="profile__chips">${person.askMeAbout.map(t => `<span class="chip">${t}</span>`).join('')}</div>
       </section>`
    : '';

  // --- socials ---
  const socials = person.socials && person.socials.length
    ? person.socials.map(s => `<a class="btn btn--ghost-ink" href="${s.url}" target="_blank" rel="noopener">${s.label} ↗</a>`).join('')
    : `<p class="is-placeholder" style="font-style:italic;color:#9a9284;">Links on the way.</p>`;

  // --- prev / next ---
  const talentOrder = window.TALENT_ORDER || [];
  const order = talentOrder.includes(slug)
    ? talentOrder
    : (window.TEAM_ORDER || Object.keys(window.TEAM));
  const i = order.indexOf(slug);
  const prev = order[(i - 1 + order.length) % order.length];
  const next = order[(i + 1) % order.length];

  root.innerHTML = `
    <div class="profile__inner">
      <figure class="profile__photo">${photo}</figure>
      <div>
        <h1 class="profile__name">${person.name}</h1>
        <p class="kicker kicker--sea profile__role">${person.role}${person.pronouns ? ` · ${person.pronouns}` : ''}</p>
        ${tagline}
        <div class="profile__badges">${favBadge}${statusBadge}</div>
        <section class="profile__section">
          <h2>About</h2>
          ${about}
        </section>
        ${askMe}
        <section class="profile__section">
          <h2>Find me</h2>
          <div class="profile__socials">${socials}</div>
        </section>
      </div>
    </div>
    <nav class="profile__nav" aria-label="Team">
      <a href="team-member.html?p=${prev}">← ${window.TEAM[prev].name.split(' ')[0]}</a>
      <a class="is-back" href="index.html#team">All shiverbugs</a>
      <a href="team-member.html?p=${next}">${window.TEAM[next].name.split(' ')[0]} →</a>
    </nav>`;

  // --- "Read more" toggle for clamped abouts ---
  const moreBtn = document.getElementById('aboutMore');
  if (moreBtn) {
    const text = document.getElementById('aboutText');
    moreBtn.addEventListener('click', () => {
      const open = !text.classList.toggle('is-clamped');
      moreBtn.textContent = open ? 'Show less' : 'Read more';
      moreBtn.setAttribute('aria-expanded', String(open));
    });
  }
})();
