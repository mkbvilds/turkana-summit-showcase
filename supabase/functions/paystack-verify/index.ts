// supabase/functions/paystack-verify/index.ts
// Called by payment-callback.html right after Paystack redirects the user
// back, so they see a confirmed dashboard immediately instead of waiting for
// the webhook to land. Requires the user's session (JWT).

import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { applyAddonsAndConfirm } from "../_shared/applyPayment.ts";
import { corsHeaders } from "../_shared/applyPayment.ts";
import { getVerifiedUser } from "../_shared/authUser.ts";

const SECRET_KEY_BY_CURRENCY: Record<string, string | undefined> = {
  KES: Deno.env.get("PAYSTACK_SECRET_KES"),
  USD: Deno.env.get("PAYSTACK_SECRET_USD"),
  EUR: Deno.env.get("PAYSTACK_SECRET_EUR"),
};

serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) throw new Error("Missing authorization header");

    const { user, serviceClient: supabase } = await getVerifiedUser(authHeader);

    const { reference } = await req.json();
    if (!reference) throw new Error("Missing reference");

    const { data: payment, error: paymentError } = await supabase
      .from("payments")
      .select("*")
      .eq("provider_reference", reference)
      .eq("provider", "paystack")
      .single();
    if (paymentError || !payment) throw new Error("Payment record not found");
    if (payment.registration_id !== user.id) throw new Error("This payment does not belong to you");

    if (payment.status === "success") {
      return new Response(JSON.stringify({ status: "success" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const secretKey = SECRET_KEY_BY_CURRENCY[payment.currency];
    if (!secretKey) throw new Error(`No Paystack account configured for ${payment.currency}`);

    const verifyRes = await fetch(`https://api.paystack.co/transaction/verify/${reference}`, {
      headers: { Authorization: `Bearer ${secretKey}` },
    });
    const verifyData = await verifyRes.json();

    if (verifyData?.data?.status === "success") {
      await supabase
        .from("payments")
        .update({ status: "success", raw_response: verifyData })
        .eq("id", payment.id);
      await applyAddonsAndConfirm(supabase, payment.registration_id, payment.addons);
      return new Response(JSON.stringify({ status: "success" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    } else {
      await supabase.from("payments").update({ status: "failed", raw_response: verifyData }).eq("id", payment.id);
      return new Response(JSON.stringify({ status: "failed" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }
  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});