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

  // --- founder badge (role keeps "Co-Founder" in the data; the badge shows it, the role line doesn't) ---
  const founderBadge = /co-founder/i.test(person.role)
    ? `<span class="badge badge--founder">★ Co-Founder</span>`
    : '';
  const roleDisplay = person.role.replace(/\s*·\s*Co-Founder/i, '');

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
  const SOCIAL_ICONS = {
    linkedin: '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.225 0z"/></svg>',
    github: '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></svg>',
    instagram: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="5"/><circle cx="12" cy="12" r="4.2"/><circle cx="17.3" cy="6.7" r="1.2" fill="currentColor" stroke="none"/></svg>',
    artstation: '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M0 17.723l2.027 3.505a2.424 2.424 0 0 0 2.164 1.333h13.457l-2.792-4.838H0zm24-.025c0-.484-.143-.935-.388-1.314L15.728 2.728a2.424 2.424 0 0 0-2.142-1.289h-4.19l12.06 20.902 2.028-3.513c.388-.672.516-.973.516-1.13zm-11.35-10.85l-4.277 7.408h8.552l-4.275-7.408z"/></svg>',
    bluesky: '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 10.8C10.913 8.686 7.954 4.747 5.202 2.805 2.566.944 1.561 1.266.902 1.565.139 1.908 0 3.08 0 3.768c0 .69.378 5.65.624 6.479.815 2.736 3.713 3.66 6.383 3.364-3.912.58-7.387 2.005-2.83 7.078 5.013 5.19 6.87-1.113 7.823-4.308.953 3.195 2.05 9.271 7.733 4.308 4.267-4.308 1.172-6.498-2.74-7.078 2.67.297 5.568-.628 6.383-3.364.246-.828.624-5.79.624-6.478 0-.69-.139-1.861-.902-2.206-.659-.298-1.664-.62-4.3 1.24C16.046 4.748 13.087 8.687 12 10.8Z"/></svg>',
    itchio: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 12h.01M10 10v4M8 12h4"/><path d="M17.5 10.5h.01M15.5 13.5h.01"/><path d="M7.2 6h9.6c2.3 0 4.1 1.8 4.2 4.1l.4 5.2a3.6 3.6 0 0 1-6.3 2.7l-1-1.2a2.6 2.6 0 0 0-4.2 0l-1 1.2A3.6 3.6 0 0 1 2.6 15.3l.4-5.2C3.1 7.8 4.9 6 7.2 6z"/></svg>',
    x: '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M18.901 1.153h3.68l-8.04 9.19L24 22.846h-7.406l-5.8-7.584-6.638 7.584H.474l8.6-9.83L0 1.154h7.594l5.243 6.932ZM17.61 20.644h2.039L6.486 3.24H4.298Z"/></svg>',
    website: '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><circle cx="12" cy="12" r="9"/><ellipse cx="12" cy="12" rx="4" ry="9"/><path d="M3.6 9h16.8M3.6 15h16.8"/></svg>'
  };
  const iconFor = label => {
    const key = label.toLowerCase().replace(/[^a-z]/g, '');
    return SOCIAL_ICONS[key] || SOCIAL_ICONS.website;
  };
  const socials = person.socials && person.socials.length
    ? person.socials.map(s => `
        <a class="social" href="${s.url}" target="_blank" rel="noopener">
          <span class="social__icon">${iconFor(s.label)}</span>
          <span class="social__label">${s.label}</span>
        </a>`).join('')
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
    <a class="profile__back" href="index.html#team" id="backLink">&larr; Back</a>
    <div class="profile__inner">
      <figure class="profile__photo">${photo}</figure>
      <div>
        <h1 class="profile__name">${person.name}</h1>
        <p class="kicker kicker--sea profile__role">${roleDisplay}${person.pronouns ? ` · ${person.pronouns}` : ''}</p>
        ${tagline}
        <div class="profile__badges">${founderBadge}${favBadge}${statusBadge}</div>
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

  // --- back button: real history.back() when the visitor came from our own site ---
  const backLink = document.getElementById('backLink');
  let cameFromSite = false;
  try { cameFromSite = document.referrer && new URL(document.referrer).origin === location.origin; } catch (e) {}
  if (backLink && cameFromSite && history.length > 1) {
    backLink.addEventListener('click', (e) => { e.preventDefault(); history.back(); });
  }

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
