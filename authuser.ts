import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Two separate clients, two separate jobs:
//   - authClient  → ONLY for verifying who's calling (uses the anon key +
//     forwards their Authorization header, exactly like a browser would)
//   - serviceClient → ONLY for reading/writing the database (uses the
//     service role key, bypasses RLS, never sees the caller's own token)
// Calling getUser(jwt) on a service-role client is the wrong tool for this
// and is what was producing the "Unauthorized" error — GoTrue expects the
// standard anon-key + forwarded-header flow to validate a user's own token.
export function getClients(authHeader: string) {
  const url = Deno.env.get("SUPABASE_URL")!;

  const authClient = createClient(url, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: authHeader } },
  });

  const serviceClient = createClient(url, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

  return { authClient, serviceClient };
}

export async function getVerifiedUser(authHeader: string) {
  const { authClient, serviceClient } = getClients(authHeader);
  const { data: { user }, error } = await authClient.auth.getUser();
  if (error || !user) throw new Error("Invalid or expired session");
  return { user, serviceClient };
}