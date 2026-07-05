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
