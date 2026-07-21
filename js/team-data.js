// ============================================================
// Shiverbug Studios — team data
// This is the only file you need to edit to fill in profiles.
//
// Fields per person:
//   name       required
//   role       required ("Role TBC" is fine for now)
//   pronouns   e.g. 'he/him', shown next to the role
//   status     talent pool only: 'active' | 'former'
//   photo      path to portrait, or null for an initials tile
//   initials   shown when photo is null
//   tagline    one-liner in their own words, or null
//   about      array of paragraphs, or null
//   favourite  'turtle' | 'seagull' | 'crab' | null (undecided)
//   askMeAbout array of short topics, or null
//   socials    array of { label, url }, or null
// ============================================================

window.TEAM_ORDER = [
  'lewis', 'ryan', 'garrett', 'oliver', 'sarah',
  'connor', 'josh', 'nathan', 'charlie-a', 'charlie-p', 'martin',
  'evan'
];

// Talent pool: guest contributors and former core members.
// Profiles live in window.TEAM below like everyone else.
window.TALENT_ORDER = [
  'madi', 'max', 'aidan', 'hollie'
];

window.TEAM = {

  'lewis': {
    name: 'Lewis Mennim',
    role: 'CEO · Co-Founder',
    photo: 'assets/img/team-lewis.webp',
    initials: 'LM',
    pronouns: 'he/him',
    tagline: 'Turtles go brrrrr…',
    about: [
      "Turtle-obsessed CEO. I founded the studio back at the start of 2025, and I'll do anything to make it successful.",
      "The first game I remember playing was Spyro: Year of the Dragon, and I spent ages in the skateboard levels. Hence the tattoo."
    ],
    favourite: 'turtle',
    askMeAbout: null,
    socials: [
      { label: 'LinkedIn', url: 'https://uk.linkedin.com/in/lewis-mennim' },
      { label: 'X', url: 'https://x.com/lewismennim' }
    ]
  },

  'garrett': {
    name: 'Garrett Windus',
    role: 'Lead Artist · Co-Founder',
    photo: 'assets/img/team-garrett.webp',
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
    photo: 'assets/img/team-ryan.webp',
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
    photo: 'assets/img/team-oliver.webp',
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
    role: 'Character Concept Artist',
    photo: 'assets/img/team-sarah.webp',
    initials: 'SC',
    pronouns: 'she/her',
    tagline: 'Never give up on a dream because of the time it takes. The time will pass anyway.',
    about: [
      "Specialist in fantasy, historical and RPG character designs that express gameplay mechanics and world-building through research-informed visuals. I love learning about the world and people around me, and expressing their stories through my art. I'm inspired by games that combine narrative, music, and art to create immersive worlds such as Zelda OOT, Final Fantasy X, and Kingdom Come: Deliverance.",
      "Over 10 years of professional art experience. First Class Honours Graduate in Concept Art BA at Teesside University. Awarded The Leni Oglesby Prize and Dean's Award for Best Graduating Student 2025. Twice winner of Best in Concept Art at Expo Tees. Graduate of David Ko's Riot Games Stylized Character Mentorship. Creator of The Chronicles of Gyzra graphic novels. In May 2026, I joined Shiverbug Studios to help bring their characters to life!"
    ],
    favourite: 'turtle',
    askMeAbout: null,
    socials: [
      { label: 'ArtStation', url: 'https://www.artstation.com/gyzra' },
      { label: 'LinkedIn', url: 'https://www.linkedin.com/in/gyzra/' },
      { label: 'Website', url: 'https://gyzra.com' },
      { label: 'Bluesky', url: 'https://bsky.app/profile/gyzra.bsky.social' },
      { label: 'Instagram', url: 'https://www.instagram.com/gyzra/' }
    ]
  },

  'connor': {
    name: 'Connor Milburn',
    role: '3D Artist',
    photo: 'assets/img/team-connor.webp',
    initials: 'CM',
    pronouns: 'he/him',
    tagline: 'I need a whiskey',
    about: [
      "I'm a dedicated 3D Artist who likes to specialise in Environment Art and Props, I primarily use Blender, ZBrush, the Substance Suite, Unreal Engine and now Unity. One of my favourite things about being a 3D Artist is that I get to create awesome models and environments for games, it's just awe-inspiring seeing worlds come to life. As part of this, I love to make modular assets as a root back to my love for architecture. Whether it's an old Victorian building with a beautiful façade or a modern office building with interesting shapes, my interest will always be piqued.",
      "Also, as I'm part of the game development world, I must have a favourite kind of game... well I love loads of games but growing up I was always hooked on the Assassin's Creed franchise, and well basically any game released by Ubisoft (Watch Dogs, Rainbow 6)."
    ],
    favourite: 'seagull',
    askMeAbout: null,
    socials: [
      { label: 'ArtStation', url: 'https://www.artstation.com/cmilburn3d' },
      { label: 'LinkedIn', url: 'https://www.linkedin.com/in/connor-milburn-0399a1224/' }
    ]
  },

  'josh': {
    name: 'Josh Cairns',
    role: '3D Artist',
    photo: 'assets/img/team-josh.webp',
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
    photo: 'assets/img/team-nathan.webp',
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
    photo: 'assets/img/team-charlie-a.webp',
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
    photo: null,          // TODO: photo -> assets/img/team-charlie-p.webp
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
    photo: 'assets/img/team-martin.webp',
    initials: 'MW',
    pronouns: 'he/him',
    tagline: 'A great world invites players to explore.',
    about: [
      "I've been passionate about games for as long as I can remember, and they've always inspired me to create worlds of my own. I specialise in environment art, with a particular love for stylised games, strong silhouettes, and creating places that players enjoy exploring."
    ],
    favourite: 'turtle',
    askMeAbout: null,
    socials: [
      { label: 'ArtStation', url: 'https://www.artstation.com/martinwilkinson' },
      { label: 'LinkedIn', url: 'https://uk.linkedin.com/in/martin-wilkinson-' }
    ]
  },

  'evan': {
    name: 'Evan',           // TODO: surname
    role: 'Character Artist',
    photo: null,            // TODO: photo -> assets/img/team-evan.webp
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
    photo: 'assets/img/team-madi.webp',
    initials: 'MF',
    pronouns: 'they/them',
    status: 'active',
    tagline: null,
    about: [
      "Hello, I'm Madi Freck, a 2nd Year 2D Animation and Stop-motion student at Teesside University.",
      "I specialise in stop-motion puppet making, frame-by-frame animation and creating 2D character rigs."
    ],
    favourite: 'seagull',
    askMeAbout: null,
    socials: [
      { label: 'Website', url: 'https://madifreck.github.io/WebsitePortfolio' },
      { label: 'LinkedIn', url: 'https://www.linkedin.com/in/madi-freck-b45116370' },
      { label: 'Instagram', url: 'https://www.instagram.com/madi.freck' }
    ]
  },

  'max': {
    name: 'Max Breeze',
    role: 'Character Artist',
    photo: 'assets/img/team-max.webp',
    initials: 'MB',
    pronouns: 'he/him',
    status: 'active',
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

  'aidan': {
    name: 'Aidan Hendry',
    role: 'Sound Designer',
    photo: 'assets/img/team-aidan.webp',
    initials: 'AH',
    pronouns: 'he/him',
    status: 'former',
    tagline: "Always pay attention to the small things, because they're the ones that bring the magic",
    about: [
      "I'm a British sound designer with a First Class BA (with Hons) in Digital Music from Solent University and an MA with a distinction in Sound Design from Manchester Metropolitan University. After finishing some work on another game, I joined Shiverbug Studios as a sound designer.",
      "I love adventure games, card games, and anything with a whimsical vibe. I am the first to point out when I recognise a sound popping up across different games or movies."
    ],
    favourite: 'turtle',
    askMeAbout: null,
    socials: [
      { label: 'LinkedIn', url: 'https://www.linkedin.com/in/aidan-hendry-9805b0b6/' },
      { label: 'Instagram', url: 'https://www.instagram.com/honeydewdsound' },
      { label: 'X', url: 'https://x.com/honeydewdsound' }
    ]
  },

  'hollie': {
    name: 'Hollie',          // TODO: surname
    role: '3D Animator',
    photo: null,             // TODO: photo -> assets/img/team-hollie.webp
    initials: 'H',
    pronouns: null,          // TODO: confirm
    status: 'former',
    tagline: null,
    about: null,
    favourite: null,
    askMeAbout: null,
    socials: null
  }

};
