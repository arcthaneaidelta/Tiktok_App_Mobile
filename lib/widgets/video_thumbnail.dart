import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';

/// Square thumbnail tile for a video. Shows the server-generated thumbnail
/// when available, falls back to a gradient + play-icon placeholder otherwise.
class VideoThumbnail extends StatelessWidget {
  final String? thumbnailUrl;
  final double size;
  final double radius;

  const VideoThumbnail({
    super.key,
    required this.thumbnailUrl,
    this.size = 56,
    this.radius = AppRadii.sm,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: (thumbnailUrl == null || thumbnailUrl!.isEmpty)
            ? _placeholder(size)
            : _NetworkImage(url: thumbnailUrl!, size: size),
      ),
    );
  }

  static Widget _placeholder(double size) {
    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.pinkPurple),
      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: size * 0.5),
    );
  }
}

class _NetworkImage extends StatelessWidget {
  final String url;
  final double size;
  const _NetworkImage({required this.url, required this.size});

  @override
  Widget build(BuildContext context) {
    final token = ApiClient().token;
    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return Container(color: AppColors.surfaceMuted);
      },
      errorBuilder: (_, __, ___) => VideoThumbnail._placeholder(size),
    );
  }
}
