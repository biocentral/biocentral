String bytesAsFormatString(int bytes) {
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  double size = bytes.toDouble();

  for (int i = 0; i < suffixes.length - 1; i++) {
    if (size < 1024) {
      return '${size.toStringAsFixed(2)} ${suffixes[i]}';
    }
    size /= 1024;
  }

  return '${size.toStringAsFixed(2)} ${suffixes.last}';
}
