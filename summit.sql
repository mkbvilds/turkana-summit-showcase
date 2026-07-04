-- ============================================================================
-- Turkana Gold Summit & Minerals Expo 2026 — Registration schema
-- Run this once in Supabase: Project → SQL Editor → New query → Run
-- ============================================================================

create table if not exists public.registrations (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade,
  full_name text,
  email text,
  phone text,
  organization text,
  country text,
  participant_type text not null,
  package text,               -- e.g. "Standard Participant Pass", "Gold Sponsor", "Tier 1 Exhibitor"
  representatives int default 1,
  gala_dinner boolean default false,
  website text,               -- sponsors/exhibitors
  notes text,
  status text not null default 'pending' check (status in ('pending', 'confirmed', 'cancelled')),
  is_admin boolean not null default false,
  addon_mine_tour boolean not null default false,
  additional_passes int not null default 0,
  booth_number text,
  job_title text,
  industry_affiliate text,
  invitation_status text,
  invitation_sent_by text,
  attendance_status text,
  supplies_provided text,
  contact_person text,
  created_at timestamptz not null default now()
);

-- Two exhibitors can't reserve the same booth.
create unique index if not exists idx_registrations_unique_booth
  on public.registrations(booth_number) where booth_number is not null;

-- Row Level Security: each person can only see/edit their own registration.
alter table public.registrations enable row level security;

create policy "Users can view own registration"
  on public.registrations for select
  using (auth.uid() = user_id);

create policy "Users can update own registration"
  on public.registrations for update
  using (auth.uid() = user_id);

-- NOTE: there is intentionally NO client-facing insert policy. The browser
-- never inserts into this table — see handle_new_user() below. This closes
-- off the RLS error you'd otherwise hit (auth.uid() is null immediately
-- after signUp() when email confirmation is required, since the user isn't
-- logged in yet) and stops anyone from writing a row for themselves directly.

-- ============================================================================
-- Admin support
-- ----------------------------------------------------------------------------
-- is_admin_user(): a SECURITY DEFINER helper so an "is admin" check inside a
-- policy doesn't recurse into RLS on the same table.
-- ============================================================================

create or replace function public.is_admin_user()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.registrations
    where user_id = auth.uid() and is_admin = true
  );
$$;

create policy "Admins can view all registrations"
  on public.registrations for select
  using (public.is_admin_user());

create policy "Admins can update all registrations"
  on public.registrations for update
  using (public.is_admin_user());

-- ============================================================================
-- Column-level protection
-- ----------------------------------------------------------------------------
-- The UPDATE policies above only control which ROWS a user can touch, not
-- which COLUMNS. Without this, any logged-in user could call
-- supabase.from('registrations').update({ status: 'confirmed' }) on their own
-- row and mark themselves as paid, or worse, flip is_admin. This trigger
-- silently reverts those fields back to their old values unless the request
-- comes from an admin (via the admin panel) or a service-role edge function
-- (payment webhooks). is_admin can NEVER be changed by any client, admin or
-- not — only the first-signup trigger sets it.
-- ============================================================================

create or replace function public.protect_privileged_columns()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  acting_is_admin boolean;
begin
  if auth.role() = 'service_role' then
    return new; -- edge functions (payment webhooks) are trusted
  end if;

  select is_admin into acting_is_admin from public.registrations where user_id = auth.uid();

  new.is_admin := old.is_admin; -- never client-settable, even by an admin

  if not coalesce(acting_is_admin, false) then
    new.status := old.status;
    new.gala_dinner := old.gala_dinner;
    new.addon_mine_tour := old.addon_mine_tour;
    new.additional_passes := old.additional_passes;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_protect_privileged_columns on public.registrations;
create trigger trg_protect_privileged_columns
  before update on public.registrations
  for each row execute function public.protect_privileged_columns();

-- ============================================================================
-- Auto-create the registration row when someone signs up
-- ----------------------------------------------------------------------------
-- register.html passes all the form fields as signUp() metadata instead of
-- inserting them itself. This trigger fires the instant the auth.users row
-- is created — before email confirmation, before any client session exists —
-- and writes the registrations row as a SECURITY DEFINER function, which
-- bypasses RLS entirely. This is also where "first attendee becomes admin"
-- is decided: it IGNORES anything the client claims about is_admin and
-- computes it itself, server-side.
-- ============================================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  meta jsonb := new.raw_user_meta_data;
  admin_already_exists boolean;
begin
  perform pg_advisory_xact_lock(hashtext('registrations_first_admin'));

  select exists (select 1 from public.registrations where is_admin = true)
    into admin_already_exists;

  insert into public.registrations (
    user_id, full_name, email, phone, organization, country,
    participant_type, package, representatives, gala_dinner,
    website, notes, is_admin, job_title, industry_affiliate
  ) values (
    new.id,
    coalesce(meta->>'full_name', ''),
    new.email,
    meta->>'phone',
    meta->>'organization',
    meta->>'country',
    coalesce(meta->>'participant_type', 'attendee'),
    meta->>'package',
    coalesce((meta->>'representatives')::int, 1),
    coalesce((meta->>'gala_dinner')::boolean, false),
    meta->>'website',
    meta->>'notes',
    (coalesce(meta->>'participant_type', 'attendee') = 'attendee' and not admin_already_exists),
    meta->>'job_title',
    meta->>'industry_affiliate'
  );

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================================================
-- Payments — one row per M-Pesa STK push or Paystack transaction attempt
-- ----------------------------------------------------------------------------
-- Only the edge functions (mpesa-pay, mpesa-callback, paystack-pay,
-- paystack-webhook, paystack-verify) touch this table, using the service
-- role key, which bypasses RLS. There are deliberately NO insert/update
-- policies for regular users — a client can only ever READ their own
-- payment history, never write to it.
-- ============================================================================

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  registration_id uuid not null references public.registrations(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  provider text not null check (provider in ('mpesa', 'paystack')),
  provider_reference text not null,   -- CheckoutRequestID (M-Pesa) or reference (Paystack)
  provider_receipt text,              -- MpesaReceiptNumber once paid
  currency text not null default 'KES',
  amount numeric not null,
  addons jsonb,                       -- { gala, tour, extraReps } selected at checkout time
  status text not null default 'pending' check (status in ('pending', 'success', 'failed')),
  raw_response jsonb,
  created_at timestamptz not null default now()
);

create unique index if not exists idx_payments_provider_ref
  on public.payments(provider, provider_reference);

alter table public.payments enable row level security;

create policy "Users can view own payments"
  on public.payments for select
  using (auth.uid() = user_id);

create policy "Admins can view all payments"
  on public.payments for select
  using (public.is_admin_user());