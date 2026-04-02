String bytesAsFormatString(int bytes) {
  const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
  final int unit = 1000;
  double size = bytes.toDouble();

  for (int i = 0; i < suffixes.length - 1; i++) {
    if (size < unit) {
      return '${size.toStringAsFixed(1)} ${suffixes[i]}';
    }
    size /= unit;
  }

  return '${size.toStringAsFixed(1)} ${suffixes.last}';
}
