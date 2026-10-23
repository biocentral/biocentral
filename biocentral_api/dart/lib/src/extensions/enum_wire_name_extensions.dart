import '../model/common_embedder.dart';
import '../model/protocol.dart';
import '../serializers.dart';

/// Wire names for the generated enums.
///
/// These were previously getters patched directly into the generated
/// `common_embedder.dart` and `protocol.dart`, so every run of
/// `_global/bin/generate_openapi_client.py` silently dropped them. Defined here
/// against public API only, they survive regeneration.
extension CommonEmbedderWireName on CommonEmbedder {
  String get wireName =>
      serializers.serializeWith(CommonEmbedder.serializer, this)! as String;
}

extension ProtocolWireName on Protocol {
  String get wireName =>
      serializers.serializeWith(Protocol.serializer, this)! as String;
}
