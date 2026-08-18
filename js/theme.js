/* Dark by default, light on request.
 *
 * This file is loaded SYNCHRONOUSLY from <head>, above the stylesheet
 * links, and that is not an accident. It writes data-theme on <html>
 * before anything is painted, so a visitor who chose light does not see
 * a frame of dark first. Give it defer, move it to the foot of the page,
 * or fold it into main.js and that flash comes straight back.
 *
 * It cannot be an inline <script>: the site's own Content-Security-Policy
 * meta tag allows script-src 'self' with no 'unsafe-inline', and
 * tools/validate-site.ps1 fails the build on an inline script for exactly
 * that reason. Hence a separate file rather than four lines in the head.
 *
 * The stylesheet does not depend on this having run. Its bare :root holds
 * the dark values and light is the [data-theme="light"] override, so with
 * JavaScript off the site is dark - which is what it is meant to be - and
 * the toggle stays hidden rather than sitting there doing nothing.
 *
 * There is deliberately no prefers-color-scheme fallback. Dark is the
 * house style, not a response to the operating system, so a first-time
 * visitor gets dark whatever their machine is set to. Once they press the
 * button their choice is remembered and outranks everything.
 */
(function () {
  var KEY = 'sb-theme';
  var root = document.documentElement;

  /* Private browsing and blocked storage both throw on access rather than
     returning null, so every touch of localStorage is wrapped. The theme
     still works without it; it just stops persisting. */
  function stored() {
    try {
      return localStorage.getItem(KEY) === 'light' ? 'light' : 'dark';
    } catch (e) {
      return 'dark';
    }
  }

  function apply(theme) {
    root.setAttribute('data-theme', theme);
    /* The browser paints its own chrome from this on mobile - the address
       bar on Android, the status bar area in a standalone install - so a
       stale value here is a light strip above a dark page. */
    var meta = document.querySelector('meta[name="theme-color"]');
    if (meta) meta.setAttribute('content', theme === 'light' ? '#f7f1e4' : '#0a0d12');
  }

  apply(stored());

  /* The button is in the markup on every page that has a nav, hidden by
     CSS until data-theme exists. Pages without one - the co-dev redirect
     stub - still want the theme applied above, so a missing button is not
     an error. */
  document.addEventListener('DOMContentLoaded', function () {
    var btn = document.getElementById('themeToggle');
    if (!btn) return;

    /* The accessible name states the ACTION, not the current state, which
       is why this is a plain button with a changing label rather than a
       toggle carrying aria-pressed: "switch to light theme" is
       unambiguous, where a pressed/unpressed "theme" button leaves a
       screen reader user to guess which way round it is. */
    function relabel() {
      var next = root.getAttribute('data-theme') === 'light' ? 'dark' : 'light';
      var text = 'Switch to ' + next + ' theme';
      btn.setAttribute('aria-label', text);
      btn.setAttribute('title', text);
    }

    relabel();

    btn.addEventListener('click', function () {
      var next = root.getAttribute('data-theme') === 'light' ? 'dark' : 'light';

      /* Cut, do not dissolve. Buttons, nav links, cards and the copy pills
         all transition colour on their own schedule, so without this the
         page arrives at the new theme in stages over about a third of a
         second and reads as a rendering fault. The class kills every
         transition; the getComputedStyle call forces the style recalc to
         happen while it is still on, and the rAF pair puts them back one
         painted frame later. */
      root.classList.add('is-theme-switching');
      apply(next);
      void window.getComputedStyle(root).backgroundColor;
      requestAnimationFrame(function () {
        requestAnimationFrame(function () { root.classList.remove('is-theme-switching'); });
      });

      relabel();
      try {
        localStorage.setItem(KEY, next);
      } catch (e) {
        /* nothing to do: the theme is applied, it just will not survive
           the next page load */
      }
    });
  });
}());
