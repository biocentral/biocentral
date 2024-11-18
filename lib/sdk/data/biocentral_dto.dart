class BiocentralDTO {
  final Map responseMap;

  BiocentralDTO(this.responseMap);

  // Default methods used across multiple plugins
  String? get embedderName {
    return responseMap['embedder_name'];
  }

  T? get<T>(String key) => responseMap[key] as T?;
}
