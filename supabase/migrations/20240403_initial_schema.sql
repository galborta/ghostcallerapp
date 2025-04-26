-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    full_name TEXT,
    avatar_url TEXT,
    is_artist BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create an index on email for faster lookups
CREATE INDEX idx_users_email ON users(email);

-- Artists table
CREATE TABLE artists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bio TEXT,
    website_url TEXT,
    social_links JSONB,
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Create an index on user_id for faster joins
CREATE INDEX idx_artists_user_id ON artists(user_id);

-- Meditation Tracks table
CREATE TABLE meditation_tracks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    duration INTEGER NOT NULL, -- Duration in seconds
    audio_url TEXT NOT NULL,
    cover_image_url TEXT,
    category TEXT NOT NULL,
    tags TEXT[],
    is_premium BOOLEAN DEFAULT FALSE,
    price DECIMAL(10,2),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_artist FOREIGN KEY (artist_id) REFERENCES artists(id)
);

-- Create indexes for common queries
CREATE INDEX idx_meditation_tracks_artist_id ON meditation_tracks(artist_id);
CREATE INDEX idx_meditation_tracks_category ON meditation_tracks(category);
CREATE INDEX idx_meditation_tracks_is_premium ON meditation_tracks(is_premium);

-- Meditation Sessions table
CREATE TABLE meditation_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    track_id UUID NOT NULL REFERENCES meditation_tracks(id) ON DELETE CASCADE,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    duration INTEGER, -- Actual duration in seconds
    completed BOOLEAN DEFAULT FALSE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    feedback TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_track FOREIGN KEY (track_id) REFERENCES meditation_tracks(id)
);

-- Create indexes for analytics and queries
CREATE INDEX idx_meditation_sessions_user_id ON meditation_sessions(user_id);
CREATE INDEX idx_meditation_sessions_track_id ON meditation_sessions(track_id);
CREATE INDEX idx_meditation_sessions_start_time ON meditation_sessions(start_time);

-- User Referrals table
CREATE TABLE user_referrals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    referrer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    referred_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'expired')),
    reward_claimed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    CONSTRAINT fk_referrer FOREIGN KEY (referrer_id) REFERENCES users(id),
    CONSTRAINT fk_referred FOREIGN KEY (referred_id) REFERENCES users(id),
    CONSTRAINT unique_referral UNIQUE (referrer_id, referred_id)
);

-- Create indexes for referral lookups
CREATE INDEX idx_user_referrals_referrer_id ON user_referrals(referrer_id);
CREATE INDEX idx_user_referrals_referred_id ON user_referrals(referred_id);
CREATE INDEX idx_user_referrals_status ON user_referrals(status);

-- Artist Earnings table
CREATE TABLE artist_earnings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artist_id UUID NOT NULL REFERENCES artists(id) ON DELETE CASCADE,
    track_id UUID NOT NULL REFERENCES meditation_tracks(id) ON DELETE CASCADE,
    amount DECIMAL(10,2) NOT NULL,
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('sale', 'stream', 'refund')),
    status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'failed')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ,
    CONSTRAINT fk_artist FOREIGN KEY (artist_id) REFERENCES artists(id),
    CONSTRAINT fk_track FOREIGN KEY (track_id) REFERENCES meditation_tracks(id)
);

-- Create indexes for financial reporting
CREATE INDEX idx_artist_earnings_artist_id ON artist_earnings(artist_id);
CREATE INDEX idx_artist_earnings_track_id ON artist_earnings(track_id);
CREATE INDEX idx_artist_earnings_created_at ON artist_earnings(created_at);
CREATE INDEX idx_artist_earnings_status ON artist_earnings(status);

-- Add triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for each table with updated_at
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