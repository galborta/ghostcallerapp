-- Drop existing table
DROP TABLE IF EXISTS meditation_tracks CASCADE;

-- Recreate Meditation Tracks table
CREATE TABLE meditation_tracks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artist_id UUID REFERENCES artists(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    duration INTEGER NOT NULL,
    audio_url TEXT NOT NULL,
    audio_storage_path TEXT NOT NULL,
    cover_image_url TEXT,
    category TEXT NOT NULL,
    tags TEXT[],
    is_premium BOOLEAN DEFAULT FALSE,
    is_guided BOOLEAN DEFAULT FALSE,
    price DECIMAL(10,2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_artist FOREIGN KEY (artist_id) REFERENCES artists(id)
);

-- Recreate indexes
CREATE INDEX idx_meditation_tracks_artist_id ON meditation_tracks(artist_id);
CREATE INDEX idx_meditation_tracks_category ON meditation_tracks(category);
CREATE INDEX idx_meditation_tracks_is_premium ON meditation_tracks(is_premium);

-- Recreate trigger
CREATE TRIGGER set_timestamp_meditation_tracks
    BEFORE UPDATE ON meditation_tracks
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp(); 