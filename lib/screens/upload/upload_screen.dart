import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
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
  VideoPlayerController? _previewController;
  bool _previewReady = false;
  bool _uploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _musicController.dispose();
    _previewController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
    if (video == null) return;
    await _loadPreview(video.path);
  }

  Future<void> _loadPreview(String path) async {
    await _previewController?.dispose();
    final controller = VideoPlayerController.file(File(path));
    setState(() {
      _selectedVideoPath = path;
      _previewController = controller;
      _previewReady = false;
    });
    try {
      await controller.initialize();
      controller.setLooping(true);
      if (mounted) setState(() => _previewReady = true);
    } catch (_) {
      if (mounted) setState(() => _previewReady = false);
    }
  }

  void _togglePreview() {
    final c = _previewController;
    if (c == null || !c.value.isInitialized) return;
    setState(() {
      c.value.isPlaying ? c.pause() : c.play();
    });
  }

  Future<void> _clearVideo() async {
    await _previewController?.dispose();
    setState(() {
      _selectedVideoPath = null;
      _previewController = null;
      _previewReady = false;
    });
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
      await _previewController?.dispose();
      if (!mounted) return;
      setState(() {
        _selectedVideoPath = null;
        _previewController = null;
        _previewReady = false;
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
                if (_selectedVideoPath == null)
                  GestureDetector(
                    onTap: _pickVideo,
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.lg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
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
                  )
                else
                  _buildPreview(),
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

  Widget _buildPreview() {
    final c = _previewController;
    final aspect = (_previewReady && c != null) ? c.value.aspectRatio : 9 / 16;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
      child: AspectRatio(
        aspectRatio: aspect.isFinite && aspect > 0 ? aspect : 9 / 16,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_previewReady && c != null)
              GestureDetector(
                onTap: _togglePreview,
                child: VideoPlayer(c),
              )
            else
              const Center(child: CircularProgressIndicator()),
            if (_previewReady && c != null && !c.value.isPlaying)
              IgnorePointer(
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.45),
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                  ),
                ),
              ),
            Positioned(
              top: 8,
              right: 8,
              child: Row(
                children: [
                  _previewActionButton(
                    icon: Icons.swap_horiz_rounded,
                    onTap: _pickVideo,
                    tooltip: 'Change',
                  ),
                  const SizedBox(width: 6),
                  _previewActionButton(
                    icon: Icons.close_rounded,
                    onTap: _clearVideo,
                    tooltip: 'Remove',
                  ),
                ],
              ),
            ),
            if (_previewReady && c != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: VideoProgressIndicator(
                  c,
                  allowScrubbing: true,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  colors: const VideoProgressColors(
                    playedColor: AppColors.primary,
                    bufferedColor: AppColors.borderStrong,
                    backgroundColor: AppColors.border,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _previewActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Material(
      color: Colors.black.withOpacity(0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
