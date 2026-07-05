const { createClient } = require('@supabase/supabase-js');
const supabase = createClient("https://ijbxhxpzpnyuhsbzzkmq.supabase.co", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlqYnhoeHB6cG55dWhzYnp6a21xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwNjM2ODYsImV4cCI6MjA5ODYzOTY4Nn0.5rsIfVOFxqTXnT69Gb7-eJUfS5vHMbCg6ArvQEuFKGg");

async function run() {
  const { data, error } = await supabase.from('registrations').select('*').limit(1);
  if (error) {
    console.error("Error fetching:", error.message);
  } else {
    console.log(data);
  }
}
run();
