import 'dart:io';
import 'package:flutter/material.dart';

/// Opens a photo full screen with pinch-zoom. Pass either a network URL or a
/// local file path.
Future<void> showFullScreenImage(BuildContext context,
    {required String title, String url = '', String filePath = ''}) {
  return Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => FullScreenImagePage(
              title: title, url: url, filePath: filePath)));
}

class FullScreenImagePage extends StatelessWidget {
  final String title;
  final String url;
  final String filePath;

  const FullScreenImagePage(
      {super.key, required this.title, this.url = '', this.filePath = ''});

  @override
  Widget build(BuildContext context) {
    final image = url.isNotEmpty
        ? Image.network(url,
            errorBuilder: (context, error, stack) => const Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 48))
        : Image.file(File(filePath));
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(maxScale: 5, child: image),
      ),
    );
  }
}
