import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";
import { createHmac } from "https://deno.land/std@0.177.0/node/crypto.ts";

serve(async (req: Request) => {
  try {
    const rawBody = await req.text();
    const sig = req.headers.get('x-paystack-signature');
    
    // We can't know which secret key (KES/USD/EUR) verified it if we have 3, 
    // so we might need to check against all, or if they just use 1 key for multi-currency:
    const secretKey = Deno.env.get('PAYSTACK_SECRET_KEY') || ''; 
    
    // Verify signature (optional but highly recommended for production)
    if (secretKey && sig) {
      const hash = createHmac('sha512', secretKey).update(rawBody).digest('hex');
      if (hash !== sig) {
        return new Response('Invalid signature', { status: 400 });
      }
    }

    const body = JSON.parse(rawBody);
    console.log("Paystack Webhook:", body.event);

    if (body.event === 'charge.success') {
      const { metadata, status } = body.data;

      if (status === 'success' && metadata && metadata.uid) {
        const uid = metadata.uid;
        const gala = metadata.gala === 1;
        const tour = metadata.tour === 1;
        const reps = parseInt(metadata.reps || '0', 10);

        const supabaseClient = createClient(
          Deno.env.get('SUPABASE_URL') ?? '',
          Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
        );

        const { error } = await supabaseClient
          .from('registrations')
          .update({
            status: 'confirmed',
            gala_dinner: gala,
            addon_mine_tour: tour,
            additional_passes: reps
          })
          .eq('user_id', uid);

        if (error) {
          console.error("Database update error:", error);
        } else {
          console.log(`Successfully updated registration for ${uid}`);
        }
      }
    }

    return new Response(JSON.stringify({ status: "success" }), {
      headers: { 'Content-Type': 'application/json' },
    });

  } catch (error: any) {
    console.error("Webhook Error:", error);
    return new Response(JSON.stringify({ status: "error" }), { status: 400 });
  }
});
