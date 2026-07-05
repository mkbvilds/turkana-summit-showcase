-- Migration: Allow manual payments provider
-- This updates the payments table to accept 'manual' as a provider type
-- for payments submitted for admin review via Paybill.

-- Drop the old provider check constraint and recreate with 'manual' included
ALTER TABLE public.payments 
  DROP CONSTRAINT IF EXISTS payments_provider_check;

ALTER TABLE public.payments
  ADD CONSTRAINT payments_provider_check 
  CHECK (provider IN ('mpesa', 'paystack', 'manual'));

-- Add an insert policy so users can insert their own manual payment records
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'payments' AND policyname = 'Users can insert own payments'
  ) THEN
    EXECUTE 'CREATE POLICY "Users can insert own payments"
      ON public.payments FOR INSERT
      WITH CHECK (auth.uid() = user_id)';
  END IF;
END $$;

-- Allow admins to update payments (e.g. to confirm or reject)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'payments' AND policyname = 'Admins can update payments'
  ) THEN
    EXECUTE 'CREATE POLICY "Admins can update payments"
      ON public.payments FOR UPDATE
      USING (public.is_admin_user())';
  END IF;
END $$;
