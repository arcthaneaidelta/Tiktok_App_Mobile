import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/app_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _titleController = TextEditingController();
  final _musicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedVideoPath;
  bool _uploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _musicController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
    if (video != null) {
      setState(() => _selectedVideoPath = video.path);
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedVideoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a video first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _uploading = true);
    final provider = context.read<AppProvider>();

    try {
      await provider.uploadVideo(
        videoFile: File(_selectedVideoPath!),
        title: _titleController.text.trim(),
        musicName: _musicController.text.trim().isEmpty ? null : _musicController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video uploaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _titleController.clear();
      _musicController.clear();
      setState(() {
        _selectedVideoPath = null;
        _uploading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('Upload Video'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Video picker
              GestureDetector(
                onTap: _pickVideo,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.15),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _selectedVideoPath != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'Video selected',
                              style: TextStyle(color: Colors.white.withOpacity(0.7)),
                            ),
                            const SizedBox(height: 4),
                            TextButton(
                              onPressed: _pickVideo,
                              child: const Text('Change', style: TextStyle(color: Colors.pinkAccent)),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.white.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to select video',
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Max 60 seconds | MP4, MOV',
                              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Video Title', Icons.title),
                validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _musicController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Music Name (optional)', Icons.music_note),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Videos longer than 60 seconds will be rejected.',
                        style: TextStyle(color: Colors.orange.withOpacity(0.8), fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _uploading ? null : _upload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: Colors.pinkAccent.withOpacity(0.5),
                  ),
                  child: _uploading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Uploading...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        )
                      : const Text('Upload', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.white54),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.pinkAccent)),
    );
  }
}
