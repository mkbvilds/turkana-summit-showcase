import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const priceMapping: Record<string, number> = {
  "Standard Participant Pass — Ksh 1,500": 1500,
  "Cooperative Mining Package — Ksh 5,000 (up to 4 pax)": 5000,
  "Gold Sponsor — USD 40,000": 40000 * 130,
  "Silver Sponsor — USD 25,000": 25000 * 130,
  "Copper Sponsor — USD 10,000": 10000 * 130,
  "Bronze Sponsor — USD 5,000": 5000 * 130,
  "Tier 1 Exhibitor — KES 50,000": 50000,
  "Standard Exhibitor — KES 30,000": 30000,
  "International Exhibitor — USD 750": 750 * 130
};

function getBasePrice(pkgName: string | null): number {
  if (!pkgName) return 1500;
  return priceMapping[pkgName] || 1500;
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

    // Get the authenticated user
    const reqAuthHeader = req.headers.get('Authorization');
    const token = reqAuthHeader?.replace('Bearer ', '') ?? '';
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser(token);
    if (userError || !user) {
      throw new Error(`Unauthorized: ${userError?.message || 'No user found'} (Header: ${reqAuthHeader ? 'Present' : 'Missing'})`);
    }

    const body = await req.json();
    const { phone, addons } = body; // { gala: bool, tour: bool, extraReps: number }
    if (!phone) throw new Error('Phone number is required');

    // Fetch user's current registration to verify package
    const { data: reg, error: regError } = await supabaseClient
      .from('registrations')
      .select('*')
      .eq('user_id', user.id)
      .single();

    if (regError || !reg) throw new Error('Registration not found');

    // Calculate total amount securely
    let amount = 0;
    
    // If they haven't paid the base fee yet
    if (reg.status === 'pending') {
      amount += getBasePrice(reg.package);
    }
    
    // Add-ons
    const willHaveGala = addons?.gala || reg.gala_dinner;
    const willHaveTour = addons?.tour || reg.addon_mine_tour;
    const extraReps = Math.max(0, parseInt(addons?.extraReps || '0', 10));

    // Calculate difference (only charge for new add-ons if they already paid base, 
    // but if pending, we charge everything they selected).
    // For simplicity, if status is 'pending', we charge the full new amount.
    // If 'confirmed', we'd theoretically only charge the difference, but let's assume
    // Daraja is mostly used for the initial payment. If they are confirmed and adding things,
    // we charge just the new items.
    
    if (reg.status === 'pending') {
      if (willHaveGala) amount += 2500;
      if (willHaveTour) amount += 5000;
      amount += extraReps * 1500;
    } else {
      if (addons?.gala && !reg.gala_dinner) amount += 2500;
      if (addons?.tour && !reg.addon_mine_tour) amount += 5000;
      if (extraReps > (reg.additional_passes || 0)) {
        amount += (extraReps - (reg.additional_passes || 0)) * 1500;
      }
    }

    if (amount <= 0) {
      return new Response(JSON.stringify({ error: 'Amount must be greater than 0' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      });
    }

    // 1. Get Daraja Auth Token
    const consumerKey = Deno.env.get('DARAJA_CONSUMER_KEY');
    const consumerSecret = Deno.env.get('DARAJA_CONSUMER_SECRET');
    if (!consumerKey || !consumerSecret) {
      throw new Error('Missing DARAJA_CONSUMER_KEY or DARAJA_CONSUMER_SECRET in environment variables.');
    }
    
    const darajaAuthHeader = 'Basic ' + btoa(`${consumerKey}:${consumerSecret}`);

    const authRes = await fetch('https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials', {
      headers: { Authorization: darajaAuthHeader }
    });
    
    if (!authRes.ok) {
      const errText = await authRes.text();
      throw new Error(`Failed to authenticate with Daraja: ${errText}`);
    }
    const authData = await authRes.json();
    const accessToken = authData.access_token;

    // 2. Initiate STK Push
    const shortCode = Deno.env.get('DARAJA_SHORTCODE') || '174379';
    const passkey = Deno.env.get('DARAJA_PASSKEY') || 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';
    const timestamp = new Date().toISOString().replace(/[^0-9]/g, '').slice(0, 14);
    const password = btoa(`${shortCode}${passkey}${timestamp}`);

    // Format phone: 254...
    let formattedPhone = phone.replace(/\D/g, '');
    if (formattedPhone.startsWith('0')) formattedPhone = '254' + formattedPhone.slice(1);
    if (formattedPhone.startsWith('7') || formattedPhone.startsWith('1')) formattedPhone = '254' + formattedPhone;

    const stkPayload = {
      BusinessShortCode: shortCode,
      Password: password,
      Timestamp: timestamp,
      TransactionType: "CustomerPayBillOnline",
      Amount: Math.ceil(amount),
      PartyA: formattedPhone,
      PartyB: shortCode,
      PhoneNumber: formattedPhone,
      CallBackURL: `${Deno.env.get('SUPABASE_URL')}/functions/v1/mpesa-callback?uid=${user.id}&gala=${addons?.gala ? 1 : 0}&tour=${addons?.tour ? 1 : 0}&reps=${extraReps}`,
      AccountReference: `TGS-${user.id.substring(0, 5).toUpperCase()}`,
      TransactionDesc: "Turkana Gold Summit Registration"
    };

    const stkRes = await fetch('https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(stkPayload)
    });

    const stkData = await stkRes.json();

    if (stkData.ResponseCode !== "0") {
      throw new Error(`Daraja API Error: ${stkData.errorMessage || stkData.ResponseDescription}`);
    }

    return new Response(JSON.stringify({ 
      success: true, 
      message: 'STK Push sent to phone',
      merchantRequestId: stkData.MerchantRequestID,
      checkoutRequestId: stkData.CheckoutRequestID
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
