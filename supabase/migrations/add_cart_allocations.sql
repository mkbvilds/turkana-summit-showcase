-- Add new columns for cart-style add-ons
ALTER TABLE public.registrations 
  ADD COLUMN IF NOT EXISTS gala_tickets integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS tour_tickets integer DEFAULT 0,
  ADD COLUMN IF NOT EXISTS addon_allocations jsonb DEFAULT '{}'::jsonb;

-- Optionally, migrate existing boolean flags to integers for backward compatibility
UPDATE public.registrations
SET gala_tickets = 1 WHERE gala_dinner = true AND gala_tickets = 0;

UPDATE public.registrations
SET tour_tickets = 1 WHERE addon_mine_tour = true AND tour_tickets = 0;
