import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const priceMapping: Record<string, { amount: number, currency: string }> = {
  "Standard Participant Pass — Ksh 1,500": { amount: 1500, currency: 'KES' },
  "Cooperative Mining Package — Ksh 5,000 (up to 4 pax)": { amount: 5000, currency: 'KES' },
  "Gold Sponsor — USD 40,000": { amount: 40000, currency: 'USD' },
  "Silver Sponsor — USD 25,000": { amount: 25000, currency: 'USD' },
  "Copper Sponsor — USD 10,000": { amount: 10000, currency: 'USD' },
  "Bronze Sponsor — USD 5,000": { amount: 5000, currency: 'USD' },
  "Tier 1 Exhibitor — KES 50,000": { amount: 50000, currency: 'KES' },
  "Standard Exhibitor — KES 30,000": { amount: 30000, currency: 'KES' },
  "International Exhibitor — USD 750": { amount: 750, currency: 'USD' }
};

function getBasePkg(pkgName: string | null) {
  if (!pkgName) return { amount: 1500, currency: 'KES' };
  return priceMapping[pkgName] || { amount: 1500, currency: 'KES' };
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
    );

    const authHeader = req.headers.get('Authorization');
    const token = authHeader?.replace('Bearer ', '') ?? '';
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser(token);
    if (userError || !user) throw new Error(`Unauthorized: ${userError?.message || 'No user found'}`);

    const body = await req.json();
    const { addons, overrideCurrency } = body; 
    
    const { data: reg, error: regError } = await supabaseClient
      .from('registrations')
      .select('*')
      .eq('user_id', user.id)
      .single();

    if (regError || !reg) throw new Error('Registration not found');

    const basePkg = getBasePkg(reg.package);
    
    // Determine target currency (user can force EUR via override, otherwise defaults to package currency)
    const currency = overrideCurrency || basePkg.currency; 

    // Convert Add-ons to the target currency. 
    // Default add-on prices are in KES: Gala (2500), Tour (5000), Extra Reps (1500).
    // Let's use a standard conversion rate if charging in USD or EUR.
    // 1 USD ~ 130 KES, 1 EUR ~ 140 KES
    let conversionRate = 1;
    if (currency === 'USD') conversionRate = 130;
    if (currency === 'EUR') conversionRate = 140;

    let amount = 0;
    if (reg.status === 'pending') {
      // Base package is already in its native currency, so if it matches the target currency, use it directly.
      // If the target currency is different from the base package currency, we'd need to convert the base package too.
      // To keep it simple, we assume the user pays in the currency defined by their package, 
      // UNLESS they explicitly selected EUR, in which case we convert from KES.
      if (currency === basePkg.currency) {
        amount += basePkg.amount;
      } else if (basePkg.currency === 'KES') {
        amount += (basePkg.amount / conversionRate);
      } else if (basePkg.currency === 'USD' && currency === 'KES') {
        amount += (basePkg.amount * 130);
      } else if (basePkg.currency === 'USD' && currency === 'EUR') {
        amount += (basePkg.amount * (130 / 140));
      }
    }

    const willHaveGala = addons?.gala || reg.gala_dinner;
    const willHaveTour = addons?.tour || reg.addon_mine_tour;
    const extraReps = Math.max(0, parseInt(addons?.extraReps || '0', 10));

    if (reg.status === 'pending') {
      if (willHaveGala) amount += (2500 / conversionRate);
      if (willHaveTour) amount += (5000 / conversionRate);
      amount += ((extraReps * 1500) / conversionRate);
    } else {
      if (addons?.gala && !reg.gala_dinner) amount += (2500 / conversionRate);
      if (addons?.tour && !reg.addon_mine_tour) amount += (5000 / conversionRate);
      if (extraReps > (reg.additional_passes || 0)) {
        amount += (((extraReps - (reg.additional_passes || 0)) * 1500) / conversionRate);
      }
    }

    if (amount <= 0) {
      throw new Error('Amount must be greater than 0');
    }

    // Paystack requires amount in lowest denomination (e.g. cents for USD/EUR, kobo for NGN, or cents for KES?)
    // Paystack usually expects amount * 100 for all supported currencies.
    const paystackAmount = Math.ceil(amount * 100);

    // Get the right Paystack secret key based on currency. 
    // (If the user has 3 separate accounts, they can set PAYSTACK_SECRET_KES, PAYSTACK_SECRET_USD, PAYSTACK_SECRET_EUR).
    // Otherwise fallback to PAYSTACK_SECRET_KEY
    const secretKey = Deno.env.get(`PAYSTACK_SECRET_${currency}`) || Deno.env.get('PAYSTACK_SECRET_KEY');
    
    if (!secretKey) throw new Error(`Missing Paystack Secret Key for ${currency}`);

    const payload = {
      email: reg.email,
      amount: paystackAmount,
      currency: currency,
      callback_url: `${Deno.env.get('SUPABASE_URL')}/functions/v1/paystack-callback`,
      metadata: {
        uid: user.id,
        gala: addons?.gala ? 1 : 0,
        tour: addons?.tour ? 1 : 0,
        reps: extraReps
      }
    };

    const res = await fetch('https://api.paystack.co/transaction/initialize', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${secretKey}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    });

    const data = await res.json();
    if (!data.status) {
      throw new Error(`Paystack initialization failed: ${data.message}`);
    }

    return new Response(JSON.stringify({ 
      success: true, 
      authorization_url: data.data.authorization_url,
      reference: data.data.reference
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });

  } catch (error: any) {
    console.error(error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });
  }
});
