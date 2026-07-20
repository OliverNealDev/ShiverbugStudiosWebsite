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

  // --- photo ---
  const photo = person.photo
    ? `<img src="${person.photo}" alt="${person.name}">`
    : `<div class="profile__photo--empty"><span>${person.initials}</span></div>`;

  // --- tagline ---
  const tagline = person.tagline
    ? `<p class="profile__tagline">“${person.tagline}”</p>`
    : `<p class="profile__tagline">${firstName} hasn't picked a tagline yet. We're on it.</p>`;

  // --- about ---
  const about = person.about && person.about.length
    ? person.about.map(p => `<p>${p}</p>`).join('')
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
  const order = window.TEAM_ORDER || Object.keys(window.TEAM);
  const i = order.indexOf(slug);
  const prev = order[(i - 1 + order.length) % order.length];
  const next = order[(i + 1) % order.length];

  root.innerHTML = `
    <div class="profile__inner">
      <figure class="profile__photo">${photo}</figure>
      <div>
        <p class="kicker kicker--sea profile__role">${person.role}</p>
        <h1 class="profile__name">${person.name}</h1>
        ${tagline}
        <div class="profile__badges">${favBadge}</div>
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
})();
