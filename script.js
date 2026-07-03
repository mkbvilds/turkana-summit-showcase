/* Turkana Gold Summit 2026 — interactive helpers */

// Sticky header shadow
const header = document.getElementById('siteHeader');
window.addEventListener('scroll', () => {
  if (window.scrollY > 10) header.classList.add('scrolled');
  else header.classList.remove('scrolled');
});

// Mobile nav toggle
const menuToggle = document.getElementById('menuToggle');
const mainNav = document.getElementById('mainNav');
menuToggle?.addEventListener('click', () => mainNav.classList.toggle('open'));
mainNav?.querySelectorAll('a').forEach(a =>
  a.addEventListener('click', () => mainNav.classList.remove('open'))
);

// ─── HERO CAROUSEL ───────────────────────────────────────────────
const SLIDE_DURATION = 5000; // milliseconds between auto-advances

const slides = document.querySelectorAll('.carousel-slide');
const dots   = document.querySelectorAll('.dot');
let current  = 0;
let timer    = null;

function goTo(index) {
  slides[current].classList.remove('active');
  dots[current].classList.remove('active');
  current = (index + slides.length) % slides.length;
  slides[current].classList.add('active');
  dots[current].classList.add('active');
}

function startTimer() {
  clearInterval(timer);
  timer = setInterval(() => goTo(current + 1), SLIDE_DURATION);
}

// Arrow clicks
document.getElementById('carouselPrev')?.addEventListener('click', () => {
  goTo(current - 1);
  startTimer();
});
document.getElementById('carouselNext')?.addEventListener('click', () => {
  goTo(current + 1);
  startTimer();
});

// Dot clicks
dots.forEach(dot => {
  dot.addEventListener('click', () => {
    goTo(parseInt(dot.dataset.target, 10));
    startTimer();
  });
});

// Pause on hover
const carousel = document.getElementById('heroCarousel');
carousel?.addEventListener('mouseenter', () => clearInterval(timer));
carousel?.addEventListener('mouseleave', startTimer);

// Keyboard navigation
document.addEventListener('keydown', (e) => {
  if (e.key === 'ArrowLeft')  { goTo(current - 1); startTimer(); }
  if (e.key === 'ArrowRight') { goTo(current + 1); startTimer(); }
});

// Start auto-play
if (slides.length > 0) startTimer();
// ─────────────────────────────────────────────────────────────────


// ─── COUNTDOWN ───────────────────────────────────────────────────
// Update SUMMIT_DATE to the confirmed date/time (YYYY-MM-DDTHH:mm:ss local)
const SUMMIT_DATE = new Date('2026-09-15T09:00:00');

function updateCountdown() {
  const now  = new Date();
  const diff = SUMMIT_DATE - now;
  const set  = (unit, val) => {
    const el = document.querySelector(`[data-unit="${unit}"]`);
    if (el) el.textContent = String(Math.max(0, val)).padStart(2, '0');
  };

  if (diff <= 0) {
    ['days', 'hours', 'minutes', 'seconds'].forEach(u => set(u, 0));
    return;
  }

  const days    = Math.floor(diff / (1000 * 60 * 60 * 24));
  const hours   = Math.floor((diff / (1000 * 60 * 60)) % 24);
  const minutes = Math.floor((diff / (1000 * 60)) % 60);
  const seconds = Math.floor((diff / 1000) % 60);

  set('days',    days);
  set('hours',   hours);
  set('minutes', minutes);
  set('seconds', seconds);
}
updateCountdown();
setInterval(updateCountdown, 1000);
// ─────────────────────────────────────────────────────────────────

// ─── NAVBAR PARTNER CAROUSEL ─────────────────────────────────────
const navLogos = document.querySelectorAll('#navPartnerCarousel .partner-logo');
let currentNavLogo = 0;
if (navLogos.length > 0) {
  setInterval(() => {
    navLogos[currentNavLogo].classList.remove('active');
    currentNavLogo = (currentNavLogo + 1) % navLogos.length;
    navLogos[currentNavLogo].classList.add('active');
  }, 3000);
}
// ─────────────────────────────────────────────────────────────────