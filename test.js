import { createClient } from '@supabase/supabase-js'; 
const sb = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);
sb.from('payments').select('id, status').then(console.log).catch(console.error);
