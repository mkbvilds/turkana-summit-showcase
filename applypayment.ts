import type { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";
import type { AddonSelection } from "./pricing.ts";

export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// Called once a payment (M-Pesa or Paystack) is confirmed successful.
// Applies the add-ons the user selected at checkout time and flips the
// registration to "confirmed".
export async function applyAddonsAndConfirm(
  supabase: SupabaseClient,
  registrationId: string,
  addons: AddonSelection | null | undefined
) {
  const update: Record<string, unknown> = { status: "confirmed" };

  if (addons?.gala) update.gala_dinner = true;
  if (addons?.tour) update.addon_mine_tour = true;
  if (typeof addons?.extraReps === "number" && addons.extraReps > 0) {
    // Fetch current value first so repeat top-ups add on top rather than overwrite.
    const { data: existing } = await supabase
      .from("registrations")
      .select("additional_passes")
      .eq("id", registrationId)
      .single();
    const current = existing?.additional_passes || 0;
    update.additional_passes = Math.max(current, addons.extraReps);
  }

  await supabase.from("registrations").update(update).eq("id", registrationId);
}