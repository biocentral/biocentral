import 'package:biocentral/sdk/data/biocentral_task_dto.dart';


extension BayOptDTO on BiocentralDTO {
  List<dynamic>? get bayOptResults => get<List<dynamic>>('bo_results');
}
