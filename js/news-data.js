// ============================================================
// News section: LinkedIn post embeds
//
// Each entry below matches one card in the news grid, in order
// (1st = Develop:Brighton wrap, 2nd = GameNext, 3rd = Gamebridge).
//
// Leave an entry as null and the hand-written card stays.
// Paste a LinkedIn embed URL and the card is replaced by the
// real post, straight from LinkedIn.
//
// How to get an embed URL:
//   1. Open the post on LinkedIn (must be public)
//   2. Click the "..." menu on the post  ->  "Embed this post"
//   3. Copy the src="..." URL out of the iframe code it gives you.
//      It looks like:
//      https://www.linkedin.com/embed/feed/update/urn:li:share:1234567890123456789
//
// Note: embeds load content from linkedin.com in the visitor's
// browser, so they only appear once the page is online (and can
// show a LinkedIn cookie prompt inside the frame). The fallback
// cards are still used by search engines and if LinkedIn is slow.
// ============================================================

window.LINKEDIN_EMBEDS = [
  null,  // TODO: Develop:Brighton wrap post embed URL
  null,  // TODO: GameNext post embed URL
  null   // TODO: Gamebridge / new faces post embed URL
];
