const { createClient } = require('@supabase/supabase-js');
const supabase = createClient("https://ijbxhxpzpnyuhsbzzkmq.supabase.co", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlqYnhoeHB6cG55dWhzYnp6a21xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwNjM2ODYsImV4cCI6MjA5ODYzOTY4Nn0.5rsIfVOFxqTXnT69Gb7-eJUfS5vHMbCg6ArvQEuFKGg");

async function run() {
  const { data, error } = await supabase.from('group_members').insert([{ registration_id: '00000000-0000-0000-0000-000000000000', full_name: 'test', email: 'test', phone: 'test', job_title: 'test' }]);
  console.log(error);
}
run();
