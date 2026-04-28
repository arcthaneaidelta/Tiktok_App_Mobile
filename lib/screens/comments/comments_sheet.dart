import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../providers/app_provider.dart';

class CommentsSheet extends StatefulWidget {
  final String videoId;
  const CommentsSheet({super.key, required this.videoId});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _controller = TextEditingController();
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await context.read<AppProvider>().loadComments(widget.videoId);
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _submitting) return;
    setState(() => _submitting = true);
    try {
      await context.read<AppProvider>().addComment(widget.videoId, text);
      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to comment: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final comments = provider.getCachedComments(widget.videoId);
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Color(0xFF1a1a2e),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${comments.length} Comments',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: _loading && comments.isEmpty
                    ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
                    : comments.isEmpty
                        ? const Center(child: Text('No comments yet', style: TextStyle(color: Colors.white54)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.pinkAccent.withOpacity(0.3),
                                      child: Text(
                                        comment.username.isNotEmpty ? comment.username[0].toUpperCase() : '?',
                                        style: const TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                comment.username,
                                                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                timeago.format(comment.createdAt),
                                                style: const TextStyle(color: Colors.white38, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(comment.text, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
              const Divider(color: Colors.white12, height: 1),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          enabled: !_submitting,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.08),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _submit(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _submit,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _submitting ? Colors.pinkAccent.withOpacity(0.5) : Colors.pinkAccent,
                            shape: BoxShape.circle,
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.send, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
