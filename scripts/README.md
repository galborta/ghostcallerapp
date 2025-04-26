# Setup Scripts

This directory contains scripts for setting up the development environment.

## Setting up Storage Buckets

Run the following command to create the required Supabase storage buckets:

```bash
dart run scripts/setup_storage.dart
```

This will create:
- An `audio` bucket for meditation tracks (500MB limit per file)
- An `images` bucket for artist and track cover images (5MB limit per file)

## Setting up Test Data

1. Create a directory for your audio files:
```bash
mkdir -p assets/audio
```

2. Add your meditation audio files to `assets/audio/`

3. Update your Supabase credentials in `scripts/setup_test_data.dart` if needed

4. Install dependencies:
```bash
flutter pub get
```

5. Run the setup script:
```bash
dart run scripts/setup_test_data.dart
```

This will:
- Create a test artist user
- Upload sample audio files
- Create meditation tracks
- Print login credentials for the test account

## Test Account
Once setup is complete, you can login with:
- Email: test.artist@example.com
- Password: testpassword123 