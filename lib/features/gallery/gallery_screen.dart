import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/branding.dart';
import '../photo_editor/photo_editor_screen.dart';
import '../video_editor/video_editor_screen.dart';

class GalleryScreen extends StatefulWidget {
  final bool isVideoMode;

  const GalleryScreen({super.key, required this.isVideoMode});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final List<String> _selectedVideos = [];

  Future<void> _pickOne(ImageSource source) async {
    setState(() => _isLoading = true);
    try {
      if (widget.isVideoMode) {
        final XFile? file = await _picker.pickVideo(source: source);
        if (file != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => VideoEditorScreen(initialVideoPaths: [file.path]),
            ),
          );
        }
      } else {
        final XFile? file = await _picker.pickImage(source: source);
        if (file != null && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PhotoEditorScreen(imagePath: file.path),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickMultipleVideos() async {
    setState(() => _isLoading = true);
    try {
      final files = await _picker.pickMultipleMedia();
      final videos = <String>[];
      for (final f in files) {
        final path = f.path.toLowerCase();
        if (path.endsWith('.mp4') ||
            path.endsWith('.mov') ||
            path.endsWith('.mkv') ||
            path.endsWith('.webm') ||
            path.endsWith('.3gp') ||
            path.endsWith('.m4v') ||
            f.mimeType?.startsWith('video/') == true) {
          videos.add(f.path);
        }
      }
      // If picker returns mixed, also allow user-picked single videos via repeated pick
      if (videos.isEmpty && files.length == 1) {
        // treat as video attempt
        videos.add(files.first.path);
      }
      if (videos.isEmpty) {
        // fallback: one video
        final one = await _picker.pickVideo(source: ImageSource.gallery);
        if (one != null) videos.add(one.path);
      }
      if (videos.isNotEmpty && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => VideoEditorScreen(initialVideoPaths: videos),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No videos selected')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addAnotherVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _selectedVideos.add(file.path));
    }
  }

  void _openSelected() {
    if (_selectedVideos.isEmpty) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VideoEditorScreen(initialVideoPaths: List.from(_selectedVideos)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.isVideoMode ? 'Select Video(s)' : 'Select Photo'),
            Text(Branding.byLine, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: AppTheme.primary)
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isVideoMode ? Icons.videocam_rounded : Icons.photo_library_rounded,
                      size: 72,
                      color: AppTheme.primary.withOpacity(0.8),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.isVideoMode
                          ? 'Import one or many videos into one project'
                          : 'Choose a photo to edit',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 28),
                    if (widget.isVideoMode) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _pickMultipleVideos,
                          icon: const Icon(Icons.library_add_check),
                          label: const Text('Import multiple videos'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _pickOne(ImageSource.gallery),
                          icon: const Icon(Icons.video_file),
                          label: const Text('One video from gallery'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _addAnotherVideo,
                          icon: const Icon(Icons.add),
                          label: Text('Add to queue (${_selectedVideos.length})'),
                        ),
                      ),
                      if (_selectedVideos.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _openSelected,
                            child: Text('Open ${_selectedVideos.length} videos in editor'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _pickOne(ImageSource.camera),
                          icon: const Icon(Icons.videocam),
                          label: const Text('Record with camera'),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _pickOne(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('From Gallery'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _pickOne(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('From Camera'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
