import 'package:onnxruntime/onnxruntime.dart';

class ONNXEmbedder {
  static const List<String> requiredInputNames = ['input_ids', 'attention_mask'];
  static const int requiredOutputCount = 1;
  
  static (bool, String) validateFromSession(OrtSession session) {
    final inputNames = session.inputNames;
    if(inputNames.length != requiredInputNames.length) {
      return (false, 'Expected exactly ${requiredInputNames.length} input names for '
          'onnx model (given: ${inputNames.length})!');
    }
    for(final inputName in inputNames) {
      if(!requiredInputNames.contains(inputName)) {
        return (false, 'Unknown input name for onnx model: $inputName');
      }
    }
    final outputCount = session.outputCount;
    if(outputCount != requiredOutputCount) {
      return (false, 'Expected exactly $requiredOutputCount outputs for onnx model (given: $outputCount)!');
    }
    return (true, '');
  }
}
