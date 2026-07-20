// ============================================================
// Shiverbug Studios — team data
// This is the only file you need to edit to fill in profiles.
//
// Fields per person:
//   name       required
//   role       required ("Role TBC" is fine for now)
//   photo      path to portrait, or null for an initials tile
//   initials   shown when photo is null
//   tagline    one-liner in their own words, or null
//   about      array of paragraphs, or null
//   favourite  'turtle' | 'seagull' | 'crab' | null (undecided)
//   askMeAbout array of short topics, or null
//   socials    array of { label, url }, or null
// ============================================================

window.TEAM_ORDER = [
  'lewis', 'garrett', 'ryan', 'oliver', 'sarah',
  'connor', 'josh', 'nathan', 'charlie-a', 'charlie-p', 'martin',
  'max'
];

window.TEAM = {

  'lewis': {
    name: 'Lewis Mennim',
    role: 'CEO · Co-Founder',
    photo: 'assets/img/team-lewis.jpg',
    initials: 'LM',
    tagline: null,          // TODO: get from Lewis
    about: null,            // TODO: get from Lewis
    favourite: 'turtle',
    askMeAbout: null,       // e.g. ['Publishing', 'The NE dev scene', 'Coffee']
    socials: null           // e.g. [{ label: 'LinkedIn', url: 'https://...' }]
  },

  'garrett': {
    name: 'Garrett Windus',
    role: 'Lead Artist · Co-Founder',
    photo: 'assets/img/team-garrett.jpg',
    initials: 'GW',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  },

  'ryan': {
    name: 'Ryan Hughes',
    role: 'CFO · Co-Founder',
    photo: null,          // TODO: photo -> assets/img/team-ryan.jpg
    initials: 'RH',
    tagline: null,
    about: null,
    favourite: 'seagull',
    askMeAbout: null,
    socials: null
  },

  'oliver': {
    name: 'Oliver Neal',
    role: 'Gameplay Programmer',
    photo: 'assets/img/team-oliver.jpg',
    initials: 'ON',
    tagline: 'Programming Department',
    about: [
      "I'm a games developer working in Unity and C#. I graduated from Teesside University in July 2026 with First Class Honours in BSc (Hons) Games Development, and joined Shiverbug Studios as a gameplay programmer straight after.",
      "The part of games I enjoy most is the systems layer: state machines driving enemy AI, multiplayer netcode, and the optimisation that lets thousands of entities simulate without dropping frames."
    ],
    favourite: 'turtle',
    askMeAbout: null,
    socials: [
      { label: 'Website', url: 'https://oliverneal.dev' },
      { label: 'GitHub', url: 'https://github.com/OliverNealDev' },
      { label: 'itch.io', url: 'https://olivernealdev.itch.io' },
      { label: 'LinkedIn', url: 'https://www.linkedin.com/in/oliver-neal-197b74290' }
    ]
  },

  'sarah': {
    name: 'Sarah Childs',
    role: '2D Concept Artist',
    photo: 'assets/img/team-sarah.jpg',
    initials: 'SC',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  },

  'connor': {
    name: 'Connor Milburn',
    role: '3D Artist',
    photo: 'assets/img/team-connor.jpg',
    initials: 'CM',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: [
      { label: 'ArtStation', url: 'https://www.artstation.com/cmilburn3d' },
      { label: 'LinkedIn', url: 'https://www.linkedin.com/in/connor-milburn-0399a1224/' }
    ]
  },

  'josh': {
    name: 'Josh Cairns',
    role: '3D Artist',
    photo: 'assets/img/team-josh.jpg',
    initials: 'JC',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  },

  'nathan': {
    name: 'Nathan Hopwood',
    role: '3D Artist',
    photo: 'assets/img/team-nathan.png',
    initials: 'NH',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  },

  'charlie-a': {
    name: 'Charlie Ashall',
    role: 'Level Designer',
    photo: 'assets/img/team-charlie-a.png',
    initials: 'CA',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  },

  'charlie-p': {
    name: 'Charlie Pelling',
    role: 'Narrative Designer',
    photo: null,          // TODO: photo -> assets/img/team-charlie-p.jpg
    initials: 'CP',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  },

  'martin': {
    name: 'Martin Wilkinson',
    role: '3D Artist',
    photo: 'assets/img/team-martin.png',
    initials: 'MW',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  },

  'max': {
    name: 'Max',            // TODO: surname
    role: 'Character Artist',
    photo: null,            // TODO: photo -> assets/img/team-max.jpg
    initials: 'M',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  }

};
