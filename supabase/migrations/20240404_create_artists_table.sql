-- Create artists table
create table if not exists public.artists (
    id uuid default gen_random_uuid() primary key,
    name text not null,
    bio text not null,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS
alter table public.artists enable row level security;

-- Create policy to allow all operations for authenticated users
create policy "Enable all operations for authenticated users" on public.artists
    for all using (auth.role() = 'authenticated');

-- Grant access to authenticated users
grant all on public.artists to authenticated; 