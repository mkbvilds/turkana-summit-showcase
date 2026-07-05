const { createClient } = require('@supabase/supabase-js');
const supabase = createClient("https://ijbxhxpzpnyuhsbzzkmq.supabase.co", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlqYnhoeHB6cG55dWhzYnp6a21xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwNjM2ODYsImV4cCI6MjA5ODYzOTY4Nn0.5rsIfVOFxqTXnT69Gb7-eJUfS5vHMbCg6ArvQEuFKGg");

async function run() {
  const { data: users, error } = await supabase.auth.admin.listUsers();
  if (users) {
      console.log(users.users.map(u => u.user_metadata));
  } else {
      console.error(error);
  }
}
run();
