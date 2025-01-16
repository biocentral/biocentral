import 'dart:convert';

import 'package:bio_flutter/bio_flutter.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/data/biocentral_python_companion.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

extension EmbeddingsPythonCompanion on BiocentralPythonCompanion {
  Future<Either<BiocentralException, Map<String, Embedding>>> loadH5File(PlatformFile platformFile) async {
    final Map<String, String> body = {'absolute_file_path': platformFile.path.toString()};
    final responseEither = await doPostRequest('read_h5', body);
    return responseEither.match((l) async {
      return left(l);
    }, (r) async {
      final embeddings = await compute<Map<String, dynamic>, Either<BiocentralIOException, Map<String, Embedding>>>(
        _readEmbeddingsFromResponse,
        (r['id2emb'] ?? {}) as Map<String, dynamic>,
      );
      return embeddings;
    });
  }

  Future<Either<BiocentralException, String>> writeH5File(String filePath, Map<String, Embedding> embeddings) async {
    final Map<String, String> body = {
      'absolute_file_path': filePath,
      'embeddings': jsonEncode(embeddings.map((key, embd) => MapEntry(key, embd.rawValues()))),
    };
    final responseEither = await doPostRequest('write_h5', body);
    return responseEither.match((l) async {
      return left(l);
    }, (r) async {
      final h5Bytes = r['h5_bytes'];
      return right(h5Bytes);
    });
  }

  static Future<Either<BiocentralIOException, Map<String, Embedding>>> _readEmbeddingsFromResponse(
      Map<String, dynamic>? id2emb) async {
    if (id2emb == null) {
      return left(
        BiocentralIOException(message: 'Parsing of embeddings failed - Could not convert result map from companion!'),
      );
    }

    final Map<String, Embedding> result = {};
    for (final entry in id2emb.entries) {
      final conversion = _fromList(entry.value);
      if (conversion == null) {
        return left(
          BiocentralIOException(message: 'Parsing of embeddings failed - could not create embedding!'),
        );
      }
      result[entry.key] = conversion;
    }
    return right(result);
  }

  static Embedding? _fromList(dynamic embd) {
    if (embd is List<dynamic>) {
      return PerSequenceEmbedding(List<double>.from(embd), embedderName: 'TODO');
    }
    if (embd is List<List<dynamic>>) {
      return PerResidueEmbedding(List<List<double>>.from(embd), embedderName: 'TODO');
    }
    return null;
  }
}
