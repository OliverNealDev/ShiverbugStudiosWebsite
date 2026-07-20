// ============================================================
// Shiverbug Studios — team data
// This is the only file you need to edit to fill in profiles.
//
// Fields per person:
//   name       required
//   role       required ("Role TBC" is fine for now)
//   pronouns   e.g. 'he/him', shown next to the role
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
  'evan'
];

// Talent pool: volunteers, guest contributors and former core members.
// Profiles live in window.TEAM below like everyone else.
window.TALENT_ORDER = [
  'madi', 'max', 'aiden'
];

window.TEAM = {

  'lewis': {
    name: 'Lewis Mennim',
    role: 'CEO · Co-Founder',
    photo: 'assets/img/team-lewis.jpg',
    initials: 'LM',
    pronouns: 'he/him',
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
    pronouns: 'he/him',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  },

  'ryan': {
    name: 'Ryan Hughes',
    role: 'CFO · Co-Founder',
    photo: 'assets/img/team-ryan.jpg',
    initials: 'RH',
    pronouns: 'he/him',
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
    pronouns: 'he/him',
    tagline: 'Programming Department',
    about: [
      "I'm a games developer working in Unity and C#. I graduated from Teesside University in July 2026 with First Class Honours in BSc (Hons) Games Development, and joined Shiverbug Studios as a gameplay programmer straight after.",
      "I love automation games, tactical shooters like Valorant, and a good co-op session. Beyond playing them, I really enjoy game design itself and thinking about what makes games fun."
    ],
    favourite: 'seagull',
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
    pronouns: 'she/her',
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
    pronouns: 'he/him',
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
    pronouns: 'he/him',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  },

  'nathan': {
    name: 'Nathan Hopwood',
    role: '3D Artist',
    photo: 'assets/img/team-nathan.jpg',
    initials: 'NH',
    pronouns: 'he/him',
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
    pronouns: 'he/him',
    tagline: "Neurospicy, with lots of flavor",
    about: [
      "I'm a level designer that works in Unreal and Unity. I graduated from Teesside University in July 2025 with First Class Honours in Game Design, and am currently studying a masters in Game Design. I joined Shiverbug in May of 2026 as a level designer.",
      "Some of my favourite games are Sonic X Shadow Generations, Resident Evil and Hades 1/2. My favourite part of games is the level design and creating different worlds and levels for players to explore and be guided through.",
      "Outside of games, I also like to take part in the One Piece TCG (a revolutionary Army player) and explore different pieces of media."
    ],
    favourite: 'turtle',
    askMeAbout: null,
    socials: [
      { label: 'Portfolio', url: 'https://charlieashall7.wixsite.com/rephrase-and-suggest' },
      { label: 'LinkedIn', url: 'https://www.linkedin.com/in/charlie-ashall-designer/' }
    ]
  },

  'charlie-p': {
    name: 'Charlie Pelling',
    role: 'Narrative Designer',
    photo: null,          // TODO: photo -> assets/img/team-charlie-p.jpg
    initials: 'CP',
    pronouns: 'he/him',
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
    pronouns: 'he/him',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  },

  'evan': {
    name: 'Evan',           // TODO: surname
    role: 'Character Artist',
    photo: null,            // TODO: photo -> assets/img/team-evan.jpg
    initials: 'E',
    pronouns: 'he/him',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  },

  // --- talent pool ---

  'madi': {
    name: 'Madi Freck',
    role: 'Social Media',
    photo: null,            // TODO: photo -> assets/img/team-madi.jpg
    initials: 'MF',
    pronouns: 'they/them',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  },

  'max': {
    name: 'Max Breeze',
    role: 'Character Artist',
    photo: 'assets/img/team-max.jpg',
    initials: 'MB',
    pronouns: 'he/him',
    tagline: "I've always loved living in other worlds",
    about: [
      "I care a lot about games. I've been playing since I was 5, starting with Oddworld: Stranger's Wrath, and I've always loved living in other worlds and being able to create worlds of my own.",
      "I do a lot of GDD work and always chip in when it comes to games. Big fan of knights, vikings and fantasy stuff."
    ],
    favourite: 'turtle',
    askMeAbout: null,
    socials: [
      { label: 'ArtStation', url: 'https://www.artstation.com/maxbreeze' },
      { label: 'LinkedIn', url: 'https://www.linkedin.com/in/max-breeze-b2b593281/' }
    ]
  },

  'aiden': {
    name: 'Aiden Hendry',
    role: 'Sound Designer',
    photo: null,            // TODO: photo -> assets/img/team-aiden.jpg
    initials: 'AH',
    pronouns: 'he/him',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  }

};
