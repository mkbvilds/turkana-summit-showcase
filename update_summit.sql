ALTER TABLE public.registrations ADD COLUMN IF NOT EXISTS payment_reference text;

create policy "Users can insert own group members"
  on public.group_members for insert
  with check (exists (
    select 1 from public.registrations
    where registrations.id = group_members.registration_id
    and registrations.user_id = auth.uid()
  ));

create policy "Users can update own group members"
  on public.group_members for update
  using (exists (
    select 1 from public.registrations
    where registrations.id = group_members.registration_id
    and registrations.user_id = auth.uid()
  ));

create policy "Users can delete own group members"
  on public.group_members for delete
  using (exists (
    select 1 from public.registrations
    where registrations.id = group_members.registration_id
    and registrations.user_id = auth.uid()
  ));

-- =============================================================
-- PAYMENTS: allow manual submissions & fix RLS (403 fix)
-- =============================================================

-- 1. Drop the strict provider constraint and add 'manual'
ALTER TABLE public.payments
  DROP CONSTRAINT IF EXISTS payments_provider_check;

ALTER TABLE public.payments
  ADD CONSTRAINT payments_provider_check
  CHECK (provider IN ('mpesa', 'paystack', 'manual'));

-- 2. Drop the old unique index (provider+reference) so we can
--    replace it with a simpler unique on just provider_reference
DROP INDEX IF EXISTS idx_payments_provider_ref;

-- 3. Add a unique constraint on provider_reference alone so the
--    same payment reference code can never be submitted twice
CREATE UNIQUE INDEX IF NOT EXISTS idx_payments_unique_reference
  ON public.payments (provider_reference);

-- 4. INSERT policy — lets authenticated users submit their own payments
DROP POLICY IF EXISTS "Users can insert own payments" ON public.payments;
CREATE POLICY "Users can insert own payments"
  ON public.payments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 5. UPDATE policy — lets admins approve / reject payments
DROP POLICY IF EXISTS "Admins can update payments" ON public.payments;
CREATE POLICY "Admins can update payments"
  ON public.payments FOR UPDATE
  USING (public.is_admin_user());

-- 6. Allow admins to SELECT all payments (Finance dashboard)
DROP POLICY IF EXISTS "Admins can view all payments" ON public.payments;
CREATE POLICY "Admins can view all payments"
  ON public.payments FOR SELECT
  USING (public.is_admin_user() OR auth.uid() = user_id);

-- =============================================================
-- REGISTRATIONS: add missing add-on columns (400 fix)
-- gala_tickets / tour_tickets / addon_allocations are written
-- to on checkout but don't exist yet in the table
-- =============================================================

ALTER TABLE public.registrations
  ADD COLUMN IF NOT EXISTS gala_tickets integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS tour_tickets integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS addon_allocations jsonb DEFAULT '{}'::jsonb;

-- Backfill from existing boolean flags so old records stay consistent
UPDATE public.registrations
  SET gala_tickets = 1
  WHERE gala_dinner = true AND (gala_tickets IS NULL OR gala_tickets = 0);

UPDATE public.registrations
  SET tour_tickets = 1
  WHERE addon_mine_tour = true AND (tour_tickets IS NULL OR tour_tickets = 0);

-- =============================================================
-- BOOTH STATUS FUNCTION
-- Returns booth occupancy map for the exhibition hall.
-- Runs as SECURITY DEFINER so any authenticated user can see
-- the state of every booth without exposing private data.
-- Only exposes: booth_number, lock_state, and organisation name.
-- =============================================================

DROP FUNCTION IF EXISTS public.get_booth_statuses();
CREATE OR REPLACE FUNCTION public.get_booth_statuses()
RETURNS TABLE (
  booth_number    text,
  lock_state      text,   -- 'locked' | 'under_review' | 'occupied'
  organization    text,
  hold_expires_at timestamptz
)
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT
    r.booth_number,
    CASE
      -- Confirmed & paid → permanently locked
      WHEN r.status = 'confirmed' THEN 'locked'
      -- Has a pending payment submitted within last 7 days → under review
      WHEN p.id IS NOT NULL
           AND p.status = 'pending'
           AND p.created_at >= (now() - interval '7 days') THEN 'under_review'
      -- Booth assigned but no qualifying payment → generic occupied
      ELSE 'occupied'
    END AS lock_state,
    r.organization,
    -- When the 7-day hold expires (null for locked/occupied)
    CASE
      WHEN p.id IS NOT NULL
           AND p.status = 'pending'
           AND p.created_at >= (now() - interval '7 days')
      THEN p.created_at + interval '7 days'
      ELSE NULL
    END AS hold_expires_at
  FROM public.registrations r
  LEFT JOIN LATERAL (
    -- Most recent pending payment for this registration
    SELECT id, status, created_at
    FROM public.payments
    WHERE payments.registration_id = r.id
      AND payments.status = 'pending'
    ORDER BY created_at DESC
    LIMIT 1
  ) p ON true
  WHERE r.booth_number IS NOT NULL
    AND r.status <> 'cancelled';
$$;

-- Grant execute to authenticated role
GRANT EXECUTE ON FUNCTION public.get_booth_statuses() TO authenticated;
