import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:meditation_app/core/constants/spacing.dart';
import 'package:meditation_app/core/theme/typography.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _audioFile;
  File? _imageFile;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
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
      type: FileType.image,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    );

    if (result != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _uploadFiles() async {
    if (!_formKey.currentState!.validate() || _audioFile == null) {
      setState(() {
        _errorMessage = 'Please fill all required fields and select an audio file';
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

      // Upload audio file
      final audioFileName = path.basename(_audioFile!.path);
      final audioStoragePath = 'public/meditation_tracks/$audioFileName';
      
      await supabase.storage.from('audio').upload(
        audioStoragePath,
        _audioFile!,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      // Get the audio URL
      final audioUrl = supabase.storage.from('audio').getPublicUrl(audioStoragePath);

      // Upload image if selected
      String? imageUrl;
      if (_imageFile != null) {
        final imageFileName = path.basename(_imageFile!.path);
        final imageStoragePath = 'public/track_covers/$imageFileName';
        
        await supabase.storage.from('images').upload(
          imageStoragePath,
          _imageFile!,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: true,
          ),
        );

        imageUrl = supabase.storage.from('images').getPublicUrl(imageStoragePath);
      }

      // Create track record
      await supabase.from('meditation_tracks').insert({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'audio_url': audioUrl,
        'cover_image_url': imageUrl,
        'duration': 0, // TODO: Calculate actual duration
        'is_premium': false,
      });

      setState(() {
        _successMessage = 'Upload completed successfully!';
        _titleController.clear();
        _descriptionController.clear();
        _audioFile = null;
        _imageFile = null;
      });

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
        title: const Text('Upload Track'),
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

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Track Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: Spacing.medium),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),

              const SizedBox(height: Spacing.large),

              // Audio file picker
              ListTile(
                title: Text(_audioFile != null 
                  ? 'Selected: ${path.basename(_audioFile!.path)}'
                  : 'No audio file selected'),
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

              const SizedBox(height: Spacing.medium),

              // Image file picker
              ListTile(
                title: Text(_imageFile != null 
                  ? 'Selected: ${path.basename(_imageFile!.path)}'
                  : 'No cover image selected (optional)'),
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

              ElevatedButton(
                onPressed: _isLoading ? null : _uploadFiles,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Upload Track'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 