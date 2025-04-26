-- Enable storage extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "storage";

-- Create storage buckets directly
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types, owner, created_at, updated_at, avif_autodetection)
VALUES 
    ('audio', 'audio', true, 524288000, ARRAY['audio/mpeg', 'audio/mp3', 'audio/wav'], null, NOW(), NOW(), false),
    ('images', 'images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'], null, NOW(), NOW(), false)
ON CONFLICT (id) DO UPDATE SET
    public = EXCLUDED.public,
    file_size_limit = EXCLUDED.file_size_limit,
    allowed_mime_types = EXCLUDED.allowed_mime_types; 