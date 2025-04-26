import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meditation_app/data/models/track_model.dart';
import 'package:meditation_app/data/repositories/track_repository.dart';
import 'package:meditation_app/data/repositories/supabase_track_repository.dart';
import 'package:meditation_app/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  final supabase = Supabase.instance.client;
  return SupabaseTrackRepository(supabase);
});

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _artistNameController = TextEditingController();
  final _artistBioController = TextEditingController();
  String? _selectedAudioPath;
  bool _isGuided = false;
  bool _isUploading = false;
  final _player = AudioPlayer();
  Duration? _duration;
  String _category = 'onlyMusic';

  @override
  void dispose() {
    _titleController.dispose();
    _artistNameController.dispose();
    _artistBioController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedAudioPath = result.files.single.path;
      });

      // Get audio duration
      try {
        final duration = await _player.setFilePath(_selectedAudioPath!);
        setState(() {
          _duration = duration;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reading audio file: $e')),
        );
      }
    }
  }

  Future<void> _uploadTrack() async {
    if (!_formKey.currentState!.validate() || 
        _selectedAudioPath == null || 
        _duration == null) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // 1. Create artist first with only required fields
      final artistData = {
        'name': _artistNameController.text,
        'short_bio': _artistBioController.text.length > 100 
          ? _artistBioController.text.substring(0, 100) + '...' 
          : _artistBioController.text,
        'image_url': 'https://via.placeholder.com/300.png',
        'revenue_share_percentage': 50,
        'referral_code': 'ARTIST_${DateTime.now().millisecondsSinceEpoch}',
        'bio': _artistBioController.text,
      };

      print('Creating artist with data: $artistData');

      final response = await Supabase.instance.client
          .from('artists')
          .insert(artistData)
          .select()
          .maybeSingle();

      print('Full Supabase response: $response');

      if (response == null) {
        throw Exception('No data returned from artist creation');
      }

      final artistId = response['id'];
      print('Artist ID: $artistId');

      if (artistId == null) {
        throw Exception('Artist ID is null in response data');
      }

      print('About to upload track with artist ID: $artistId');

      // 2. Then upload track
      final track = await ref.read(trackRepositoryProvider).uploadTrack(
        title: _titleController.text,
        artistId: artistId.toString(),
        filePath: _selectedAudioPath!,
        isGuided: _isGuided,
        duration: _duration!.inSeconds,
        category: _category,
      );

      print('Track upload response: $track');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artist and track uploaded successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e, stackTrace) {
      print('Error details: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _updateCategory(bool isGuided) {
    setState(() {
      _isGuided = isGuided;
      // Update category when toggle changes
      _category = isGuided ? 'guidedMeditation' : 'onlyMusic';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Track'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Artist Information Section
              Text('Artist Information', 
                style: Theme.of(context).textTheme.titleLarge
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _artistNameController,
                decoration: const InputDecoration(
                  labelText: 'Artist Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter artist name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _artistBioController,
                decoration: const InputDecoration(
                  labelText: 'Artist Bio',
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
              const SizedBox(height: 32),
              
              // Track Information Section
              Text('Track Information', 
                style: Theme.of(context).textTheme.titleLarge
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Track Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Guided Meditation'),
                value: _isGuided,
                onChanged: _updateCategory,
              ),
              const SizedBox(height: 16),
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                child: Text(_isGuided ? 'Guided Meditation' : 'Music Only'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickAudioFile,
                icon: const Icon(Icons.audio_file),
                label: Text(_selectedAudioPath == null 
                  ? 'Select Audio File' 
                  : 'Audio File Selected'),
              ),
              if (_selectedAudioPath != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Selected file: ${_selectedAudioPath!.split('/').last}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (_duration != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      'Duration: ${_duration!.inMinutes}:${(_duration!.inSeconds % 60).toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isUploading ? null : _uploadTrack,
                  child: _isUploading
                      ? const CircularProgressIndicator()
                      : const Text('Upload Artist & Track'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 