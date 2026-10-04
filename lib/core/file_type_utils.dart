const imageExtensions = ['.jpg', '.jpeg', '.png', '.heic', '.webp'];

bool isImageUrl(String url) {
  final path = url.split('?').first.toLowerCase();
  return imageExtensions.any(path.endsWith);
}

String fileExtensionLabel(String url) {
  final path = url.split('?').first;
  final dot = path.lastIndexOf('.');
  if (dot < 0 || dot == path.length - 1) return 'FILE';
  return path.substring(dot + 1).toUpperCase();
}
