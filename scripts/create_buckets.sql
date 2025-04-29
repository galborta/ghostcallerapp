-- Enable the storage extension
create extension if not exists "storage-api" with schema "extensions";

-- Create the audio bucket
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'audio',
  'audio',
  true,
  524288000, -- 500MB
  array['audio/mpeg', 'audio/mp3', 'audio/wav']
);

-- Create the images bucket
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'images',
  'images',
  true,
  5242880, -- 5MB
  array['image/jpeg', 'image/png', 'image/gif', 'image/webp']
);

-- Set up policies for audio bucket
create policy "Public Access"
  on storage.objects for select
  using ( bucket_id = 'audio' AND (storage.foldername(name))[1] = 'tracks' );

create policy "Authenticated users can upload audio"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'audio' 
    AND (storage.foldername(name))[1] = 'tracks'
    AND (storage.foldername(name))[2] = auth.uid()
  );

create policy "Users can delete their own audio"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'audio'
    AND (storage.foldername(name))[1] = 'tracks'
    AND (storage.foldername(name))[2] = auth.uid()
  );

-- Set up policies for images bucket
create policy "Public Access Images"
  on storage.objects for select
  using ( bucket_id = 'images' AND (storage.foldername(name))[1] = 'artists' );

create policy "Authenticated users can upload images"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'images'
    AND (storage.foldername(name))[1] = 'artists'
    AND (storage.foldername(name))[2] = auth.uid()
  );

create policy "Users can delete their own images"
  on storage.objects for delete
  to authenticated
  using (
    bucket_id = 'images'
    AND (storage.foldername(name))[1] = 'artists'
    AND (storage.foldername(name))[2] = auth.uid()
  ); 