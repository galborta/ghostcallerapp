-- Reset policies
DROP POLICY IF EXISTS "Allow public downloads" ON storage.objects;
DROP POLICY IF EXISTS "Allow authenticated uploads" ON storage.objects;

-- Enable RLS
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Allow public downloads from both buckets
CREATE POLICY "Allow public downloads"
ON storage.objects FOR SELECT
USING (bucket_id IN ('audio', 'images'));

-- Allow any authenticated user to upload to both buckets
CREATE POLICY "Allow authenticated uploads"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id IN ('audio', 'images')
  AND auth.role() = 'authenticated'
);

-- Allow authenticated users to update their own uploads
CREATE POLICY "Allow users to update own uploads"
ON storage.objects FOR UPDATE
USING (
  bucket_id IN ('audio', 'images')
  AND auth.role() = 'authenticated'
  AND owner = auth.uid()
)
WITH CHECK (
  bucket_id IN ('audio', 'images')
  AND auth.role() = 'authenticated'
  AND owner = auth.uid()
);

-- Allow authenticated users to delete their own uploads
CREATE POLICY "Allow users to delete own uploads"
ON storage.objects FOR DELETE
USING (
  bucket_id IN ('audio', 'images')
  AND auth.role() = 'authenticated'
  AND owner = auth.uid()
); 