-- Make user_id optional in artists table
ALTER TABLE artists ALTER COLUMN user_id DROP NOT NULL;

-- Add name column if it doesn't exist
DO $$ 
BEGIN 
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'artists' 
        AND column_name = 'name'
    ) THEN
        ALTER TABLE artists ADD COLUMN name TEXT NOT NULL DEFAULT '';
    END IF;
END $$;

-- Add featured column if it doesn't exist
DO $$ 
BEGIN 
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'artists' 
        AND column_name = 'featured'
    ) THEN
        ALTER TABLE artists ADD COLUMN featured BOOLEAN NOT NULL DEFAULT false;
    END IF;
END $$; 