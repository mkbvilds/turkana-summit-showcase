// supabase/functions/mpesa-callback/index.ts
// PUBLIC endpoint — configure this function's URL as MPESA_CALLBACK_URL.
// Safaricom POSTs here after the customer enters their M-Pesa PIN (or cancels/times out).
// No JWT — Daraja doesn't send one — so this must be deployed with --no-verify-jwt.

import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { applyAddonsAndConfirm } from "../_shared/applyPayment.ts";

serve(async (req) => {
  // Always acknowledge Daraja with ResultCode 0, even on our own internal errors,
  // otherwise Safaricom will retry the callback repeatedly.
  const ack = () =>
    new Response(JSON.stringify({ ResultCode: 0, ResultDesc: "Received" }), {
      headers: { "Content-Type": "application/json" },
    });

  try {
    const body = await req.json();
    const stk = body?.Body?.stkCallback;
    if (!stk?.CheckoutRequestID) return ack();

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    const { data: payment } = await supabase
      .from("payments")
      .select("*")
      .eq("provider_reference", stk.CheckoutRequestID)
      .eq("provider", "mpesa")
      .single();

    if (!payment) return ack(); // unknown reference, nothing to do

    if (stk.ResultCode === 0) {
      const items: Array<{ Name: string; Value: unknown }> = stk.CallbackMetadata?.Item || [];
      const receipt = items.find((i) => i.Name === "MpesaReceiptNumber")?.Value;

      await supabase
        .from("payments")
        .update({ status: "success", provider_receipt: receipt, raw_response: body })
        .eq("id", payment.id);

      await applyAddonsAndConfirm(supabase, payment.registration_id, payment.addons);
    } else {
      // ResultCode !== 0 → user cancelled, timed out, or insufficient funds
      await supabase
        .from("payments")
        .update({ status: "failed", raw_response: body })
        .eq("id", payment.id);
    }

    return ack();
  } catch (err) {
    console.error("mpesa-callback error:", err);
    return ack();
  }
});