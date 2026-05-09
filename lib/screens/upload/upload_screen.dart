import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

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
          backgroundColor: AppColors.danger,
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
          backgroundColor: AppColors.success,
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
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Upload Video'),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGlow),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 120),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickVideo,
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      gradient: _selectedVideoPath != null
                          ? LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.18),
                                AppColors.secondary.withOpacity(0.10),
                              ],
                            )
                          : null,
                      color: _selectedVideoPath != null ? null : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(
                        color: _selectedVideoPath != null
                            ? AppColors.primary.withOpacity(0.6)
                            : AppColors.border,
                        width: _selectedVideoPath != null ? 1.5 : 1,
                      ),
                    ),
                    child: _selectedVideoPath != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppGradients.pinkPurple,
                                ),
                                child: const Icon(Icons.check_rounded, color: Colors.white, size: 32),
                              ),
                              const SizedBox(height: 12),
                              const Text('Video selected', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              TextButton(
                                onPressed: _pickVideo,
                                child: const Text('Change'),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.cloud_upload_outlined, size: 56, color: AppColors.textDim),
                              SizedBox(height: 12),
                              Text('Tap to select video',
                                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                              SizedBox(height: 4),
                              Text('Max 60 seconds  ·  MP4, MOV',
                                  style: TextStyle(color: AppColors.textDim, fontSize: 12)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Video title',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _musicController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Music name (optional)',
                    prefixIcon: Icon(Icons.music_note_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Videos longer than 60 seconds will be rejected.',
                          style: TextStyle(color: AppColors.warning.withOpacity(0.9), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                GradientButton(
                  label: _uploading ? 'Uploading...' : 'Upload',
                  icon: _uploading ? null : Icons.cloud_upload_rounded,
                  onPressed: _uploading ? null : _upload,
                  loading: _uploading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
