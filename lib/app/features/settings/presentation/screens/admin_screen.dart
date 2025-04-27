import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:meditation_app/core/constants/spacing.dart';
import 'package:meditation_app/core/theme/typography.dart';
import 'package:meditation_app/presentation/state/artist_provider.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _artistNameController = TextEditingController();
  final _artistBioController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _audioFile;
  File? _imageFile;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _artistNameController.dispose();
    _artistBioController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav'],
    );

    if (result != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _pickImageFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );

    if (result != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFiles() async {
    if (!_formKey.currentState!.validate() || _audioFile == null || _imageFile == null) {
      setState(() {
        _errorMessage = 'Please fill all required fields and select both audio and image files';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // 1. Create artist first with only required fields
      final artistData = {
        'name': _artistNameController.text,
        'bio': _artistBioController.text,
        'short_bio': _artistBioController.text.length > 100 
          ? _artistBioController.text.substring(0, 100) + '...' 
          : _artistBioController.text,
        'featured': false,
        'revenue_share_percentage': 50,
        'referral_code': 'ARTIST_${DateTime.now().millisecondsSinceEpoch}',
      };

      // Create artist record first to get the ID
      final artistResponse = await supabase
          .from('artists')
          .insert(artistData)
          .select()
          .single();

      final artistId = artistResponse['id'];

      // Now upload artist image with the correct artistId
      final imageFileName = path.basename(_imageFile!.path);
      final imageStoragePath = 'artists/$artistId/${DateTime.now().millisecondsSinceEpoch}_$imageFileName';
      
      await supabase.storage.from('images').upload(
        imageStoragePath,
        _imageFile!,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      final imageUrl = supabase.storage.from('images').getPublicUrl(imageStoragePath);
      
      // Update artist with image URL
      await supabase
          .from('artists')
          .update({'image_url': imageUrl})
          .eq('id', artistId);

      // 2. Upload audio file
      final audioFileName = path.basename(_audioFile!.path);
      final audioStoragePath = 'tracks/$artistId/${DateTime.now().millisecondsSinceEpoch}_$audioFileName';
      
      await supabase.storage.from('audio').upload(
        audioStoragePath,
        _audioFile!,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      final audioUrl = supabase.storage.from('audio').getPublicUrl(audioStoragePath);

      // 3. Create track record
      await supabase.from('meditation_tracks').insert({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'audio_url': audioUrl,
        'audio_storage_path': audioStoragePath,
        'artist_id': artistId,
        'duration': 0, // TODO: Calculate actual duration
        'is_premium': false,
        'is_guided': false,
        'category': 'meditation',
      });

      setState(() {
        _successMessage = 'Artist and track uploaded successfully!';
        _artistNameController.clear();
        _artistBioController.clear();
        _titleController.clear();
        _descriptionController.clear();
        _audioFile = null;
        _imageFile = null;
      });

      // Invalidate providers to refresh the artists list
      ref.invalidate(artistsProvider);
      ref.invalidate(featuredArtistsProvider);
      ref.invalidate(filteredArtistsProvider);

    } catch (e) {
      setState(() {
        _errorMessage = 'Error uploading files: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Artist & Track'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.large),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(Spacing.medium),
                  color: Colors.red.shade100,
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),

              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(Spacing.medium),
                  color: Colors.green.shade100,
                  child: Text(
                    _successMessage!,
                    style: TextStyle(color: Colors.green.shade900),
                  ),
                ),

              const SizedBox(height: Spacing.medium),

              // Artist Information
              Text('Artist Information', style: AppTypography.headline3),
              const SizedBox(height: Spacing.medium),

              TextFormField(
                controller: _artistNameController,
                decoration: const InputDecoration(
                  labelText: 'Artist Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter artist name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: Spacing.medium),

              TextFormField(
                controller: _artistBioController,
                decoration: const InputDecoration(
                  labelText: 'Artist Bio *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter artist bio';
                  }
                  return null;
                },
              ),

              const SizedBox(height: Spacing.medium),

              // Artist Image Picker
              ListTile(
                title: Text(_imageFile != null 
                  ? 'Selected: ${path.basename(_imageFile!.path)}'
                  : 'No artist image selected *'),
                leading: const Icon(Icons.image),
                trailing: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: _pickImageFile,
                ),
                tileColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              const SizedBox(height: Spacing.large),

              // Track Information
              Text('Track Information', style: AppTypography.headline3),
              const SizedBox(height: Spacing.medium),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Track Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter track title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: Spacing.medium),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Track Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter track description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: Spacing.medium),

              // Audio File Picker
              ListTile(
                title: Text(_audioFile != null 
                  ? 'Selected: ${path.basename(_audioFile!.path)}'
                  : 'No audio file selected *'),
                leading: const Icon(Icons.audio_file),
                trailing: IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: _pickAudioFile,
                ),
                tileColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              const SizedBox(height: Spacing.large),

              ElevatedButton(
                onPressed: _isLoading ? null : _uploadFiles,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Upload Artist & Track'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 