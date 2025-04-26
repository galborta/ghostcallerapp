-- Drop existing policies if any
DROP POLICY IF EXISTS "Allow authenticated users to upload audio files" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to update audio files" ON storage.objects;
DROP POLICY IF EXISTS "Allow public to download audio files" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to upload images" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated users to update images" ON storage.objects;
DROP POLICY IF EXISTS "Allow public to download images" ON storage.objects;
DROP POLICY IF EXISTS "Allow users to delete their own uploads" ON storage.objects;

-- Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Create helper function to check if user is admin
CREATE OR REPLACE FUNCTION auth.is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1
    FROM auth.users
    JOIN public.users ON auth.users.id = public.users.id
    WHERE auth.users.id = auth.uid()
    AND public.users.is_admin = true
  );
$$ LANGUAGE sql SECURITY DEFINER;

-- Allow public to download files from both buckets
CREATE POLICY "Allow public to download files"
ON storage.objects FOR SELECT
USING (bucket_id IN ('audio', 'images'));

-- Allow admin users to upload audio files
CREATE POLICY "Allow admin users to upload audio files"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'audio'
  AND auth.role() = 'authenticated'
  AND auth.is_admin()
);

-- Allow admin users to update audio files
CREATE POLICY "Allow admin users to update audio files"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'audio'
  AND auth.role() = 'authenticated'
  AND auth.is_admin()
)
WITH CHECK (
  bucket_id = 'audio'
  AND auth.role() = 'authenticated'
  AND auth.is_admin()
);

-- Allow admin users to delete audio files
CREATE POLICY "Allow admin users to delete audio files"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'audio'
  AND auth.role() = 'authenticated'
  AND auth.is_admin()
);

-- Allow admin users to upload images
CREATE POLICY "Allow admin users to upload images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'images'
  AND auth.role() = 'authenticated'
  AND auth.is_admin()
);

-- Allow admin users to update images
CREATE POLICY "Allow admin users to update images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'images'
  AND auth.role() = 'authenticated'
  AND auth.is_admin()
)
WITH CHECK (
  bucket_id = 'images'
  AND auth.role() = 'authenticated'
  AND auth.is_admin()
);

-- Allow admin users to delete images
CREATE POLICY "Allow admin users to delete images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'images'
  AND auth.role() = 'authenticated'
  AND auth.is_admin()
); 