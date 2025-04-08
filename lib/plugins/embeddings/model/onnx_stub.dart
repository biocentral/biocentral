// This is a stub implementation for web platform
class OrtEnv {
  static final OrtEnv instance = OrtEnv();
  void init() {
    // Do nothing
  }
}

class OrtSessionOptions {
  // Empty implementation
}

class OrtSession {

  List<String> get inputNames => throw UnsupportedError('ONNX runtime is not supported on web platform');

  int get outputCount => throw UnsupportedError('ONNX runtime is not supported on web platform');

  static fromBuffer(List<int> buffer, OrtSessionOptions options) {
    throw UnsupportedError('ONNX runtime is not supported on web platform');
  }
}