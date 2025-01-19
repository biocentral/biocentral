import 'dart:convert';

import 'package:biocentral/sdk/data/biocentral_task_dto.dart';

extension ProjectionDTO on BiocentralDTO {
  String? get projections {
    final projections = get<List>('projections');
    if(projections == null || projections.isEmpty) {
      return null;
    }
    return jsonEncode(responseMap);
  }
}
