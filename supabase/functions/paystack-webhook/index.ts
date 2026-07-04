// supabase/functions/paystack-webhook/index.ts
// PUBLIC endpoint — set this as the webhook URL on ALL THREE Paystack accounts
// (KES, USD, EUR dashboards each have their own Webhook URL field — point
// all three at this same function). Deploy with --no-verify-jwt.

import { serve } from "https://deno.land/std@0.192.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { applyAddonsAndConfirm } from "../_shared/applyPayment.ts";

const SECRETS = [
  Deno.env.get("PAYSTACK_SECRET_KES"),
  Deno.env.get("PAYSTACK_SECRET_USD"),
  Deno.env.get("PAYSTACK_SECRET_EUR"),
].filter(Boolean) as string[];

async function hmacSha512Hex(secret: string, message: string): Promise<string> {
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey(
    "raw", enc.encode(secret), { name: "HMAC", hash: "SHA-512" }, false, ["sign"]
  );
  const sig = await crypto.subtle.sign("HMAC", key, enc.encode(message));
  return Array.from(new Uint8Array(sig)).map((b) => b.toString(16).padStart(2, "0")).join("");
}

serve(async (req) => {
  try {
    const rawBody = await req.text();
    const signature = req.headers.get("x-paystack-signature");
    if (!signature) return new Response("missing signature", { status: 401 });

    // Only one of the three accounts will have signed this particular event —
    // try each secret until one matches.
    let verified = false;
    for (const secret of SECRETS) {
      const computed = await hmacSha512Hex(secret, rawBody);
      if (computed === signature) { verified = true; break; }
    }
    if (!verified) return new Response("invalid signature", { status: 401 });

    const event = JSON.parse(rawBody);

    if (event.event === "charge.success") {
      const reference = event.data.reference;
      const supabase = createClient(
        Deno.env.get("SUPABASE_URL")!,
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
      );

      const { data: payment } = await supabase
        .from("payments")
        .select("*")
        .eq("provider_reference", reference)
        .eq("provider", "paystack")
        .single();

      if (payment && payment.status !== "success") {
        await supabase
          .from("payments")
          .update({ status: "success", raw_response: event })
          .eq("id", payment.id);

        await applyAddonsAndConfirm(supabase, payment.registration_id, payment.addons);
      }
    }

    return new Response("ok", { status: 200 });
  } catch (err) {
    console.error("paystack-webhook error:", err);
    return new Response("error", { status: 200 }); // 200 so Paystack doesn't hammer retries on our bug
  }
});