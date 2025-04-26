-- Add audio_storage_path column to meditation_tracks table
ALTER TABLE meditation_tracks 
ADD COLUMN IF NOT EXISTS audio_storage_path TEXT NOT NULL DEFAULT '';

-- Update existing rows to use audio_url as storage path (if any exist)
UPDATE meditation_tracks 
SET audio_storage_path = audio_url 
WHERE audio_storage_path = ''; 