import 'dart:convert';

import 'package:biocentral/plugins/embeddings/data/protspace_api.dart';
import 'package:biocentral/plugins/embeddings/model/projection.dart';
import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:biocentral/sdk/domain/biocentral_repository_auto_saver.dart';
import 'package:biocentral/sdk/domain/streamable_database.dart';

class ProjectionsRepository with AutoSaving, StreamableDatabase<List<Projection>> {
  final List<Projection> _projections = [];

  @override
  late final BiocentralRepositoryAutoSaver autoSaver;

  ProjectionsRepository(BiocentralProjectRepository projectRepository) {
    autoSaver = BiocentralRepositoryAutoSaver(
      projectRepository: projectRepository,
      fileName: 'projections_db.json',
      fileType: Projection,
      saveFunctionString: saveDBInfo,
    );
  }

  void addProjections(List<Projection> projections) {
    _projections.addAll(projections);
    updateStream();
    autosave();
  }

  List<Projection> databaseToList() => List.from(_projections);

  Map<String, dynamic> serialize() => ProtspaceFileHandler.toProtSpaceMap(projections: _projections);

  Future<String> saveDBInfo() async {
    final jsonMap = serialize();
    return jsonEncode(jsonMap);
  }

  @override
  List<Projection> toStreamable() => databaseToList();
}
