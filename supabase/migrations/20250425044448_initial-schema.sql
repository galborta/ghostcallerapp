-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    is_artist BOOLEAN DEFAULT FALSE,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create an index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Artists table
CREATE TABLE IF NOT EXISTS artists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    bio TEXT,
    website_url TEXT,
    social_links JSONB,
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create an index on user_id for faster joins
CREATE INDEX IF NOT EXISTS idx_artists_user_id ON artists(user_id);

-- Meditation Tracks table
CREATE TABLE IF NOT EXISTS meditation_tracks (
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

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS idx_meditation_tracks_artist_id ON meditation_tracks(artist_id);
CREATE INDEX IF NOT EXISTS idx_meditation_tracks_category ON meditation_tracks(category);
CREATE INDEX IF NOT EXISTS idx_meditation_tracks_is_premium ON meditation_tracks(is_premium);

-- Add triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing triggers if they exist
DROP TRIGGER IF EXISTS set_timestamp_users ON users;
DROP TRIGGER IF EXISTS set_timestamp_artists ON artists;
DROP TRIGGER IF EXISTS set_timestamp_meditation_tracks ON meditation_tracks;

-- Create triggers for each table
CREATE TRIGGER set_timestamp_users
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_artists
    BEFORE UPDATE ON artists
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_meditation_tracks
    BEFORE UPDATE ON meditation_tracks
    FOR EACH ROW
    EXECUTE FUNCTION trigger_set_timestamp();
