/* ==========================================================================
   Turkana Gold Summit — Supabase configuration
   --------------------------------------------------------------------------
   1. Create a free project at https://supabase.com
   2. Project Settings → API → copy "Project URL" and "anon public" key
   3. Paste them below
   4. Run schema.sql in the Supabase SQL Editor (Project → SQL Editor → New query)
   5. Auth → Providers → Email: for a live event you can leave "Confirm email"
      ON (safer). For quick testing you can turn it OFF so users can log in
      immediately after registering.
   ========================================================================== */

const SUPABASE_URL = "https://ijbxhxpzpnyuhsbzzkmq.supabase.co"; // e.g. https://xxxxxxxx.supabase.co
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlqYnhoeHB6cG55dWhzYnp6a21xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwNjM2ODYsImV4cCI6MjA5ODYzOTY4Nn0.5rsIfVOFxqTXnT69Gb7-eJUfS5vHMbCg6ArvQEuFKGg";

// Creates a single shared client (window.supabaseClient) for all pages.
// Relies on the Supabase JS SDK loaded via CDN in each page's <head>.
const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

/* --------------------------------------------------------------------------
   Shared helpers
   -------------------------------------------------------------------------- */

// Redirects to login.html if there's no active session. Returns the session.
async function requireAuth() {
  const { data: { session } } = await supabaseClient.auth.getSession();
  if (!session) {
    window.location.href = "login.html";
    return null;
  }
  return session;
}

// Signs the current user out and sends them home.
async function logout() {
  await supabaseClient.auth.signOut();
  window.location.href = "login.html";
}

// Simple inline form-error / success message helper.
function setFormMessage(el, text, isError = true) {
  if (!el) return;
  el.textContent = text;
  el.style.display = text ? "block" : "none";
  el.classList.toggle("form-msg-error", isError);
  el.classList.toggle("form-msg-success", !isError);
}