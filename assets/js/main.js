document.addEventListener('DOMContentLoaded', function () {

  // ── Mobile Navigation ──
  const navToggle = document.getElementById('nav-toggle');
  const siteNav = document.getElementById('site-nav');

  if (navToggle && siteNav) {
    navToggle.addEventListener('click', function () {
      const isOpen = siteNav.classList.toggle('is-open');
      navToggle.setAttribute('aria-expanded', String(isOpen));
    });
    document.addEventListener('click', function (e) {
      if (!navToggle.contains(e.target) && !siteNav.contains(e.target)) {
        siteNav.classList.remove('is-open');
        navToggle.setAttribute('aria-expanded', 'false');
      }
    });
    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && siteNav.classList.contains('is-open')) {
        siteNav.classList.remove('is-open');
        navToggle.setAttribute('aria-expanded', 'false');
        navToggle.focus();
      }
    });
    siteNav.querySelectorAll('.nav-link:not(.nav-link--parent)').forEach(function (link) {
      link.addEventListener('click', function () {
        siteNav.classList.remove('is-open');
        navToggle.setAttribute('aria-expanded', 'false');
      });
    });
  }

  // ── Mobile Dropdown Toggle (tap parent link) ──
  document.querySelectorAll('.nav-item--has-dropdown').forEach(function (item) {
    const parent = item.querySelector('.nav-link--parent');
    if (!parent) return;
    parent.addEventListener('click', function (e) {
      const isMobile = window.innerWidth <= 860;
      if (isMobile) {
        e.preventDefault();
        item.classList.toggle('is-open');
      }
    });
  });

  // ── Subscribe "more" toggle ──
  document.querySelectorAll('.subscribe-links[data-collapsible="true"]').forEach(function (container) {
    var btn = container.querySelector('.subscribe-more-btn');
    if (!btn) return;
    btn.addEventListener('click', function () {
      container.classList.add('is-expanded');
      btn.setAttribute('aria-expanded', 'true');
    });
  });

});
