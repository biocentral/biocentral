import 'package:equatable/equatable.dart';

import '../util/constants.dart';

final class BiocentralServerData extends Equatable {
  final String name;
  final String url;
  final List<String> availableServices;

  const BiocentralServerData({required this.name, required this.url, required this.availableServices});

  const BiocentralServerData.local({List<String>? availableServices})
      : name = "localhost",
        url = Constants.localHostServerURL,
        availableServices = availableServices ??
            const [
              "biocentral_service",
              "embeddings_service",
              "ppi_service",
              "prediction_models_service",
              "protein_service"
            ];

  bool isLocal() {
    return name == "localhost" || url.contains("127.0.0.1");
  }

  @override
  List<Object?> get props => [name, url, availableServices];
}
