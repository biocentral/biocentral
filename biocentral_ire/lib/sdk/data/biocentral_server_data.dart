import 'package:equatable/equatable.dart';

import 'package:biocentral/sdk/util/constants.dart';

final class BiocentralServerData extends Equatable {
  final String name;
  final String url;
  final List<String> availableServices;
  final bool isBuiltIn;

  const BiocentralServerData({
    required this.name,
    required this.url,
    required this.availableServices,
    this.isBuiltIn = false,
  });

  const BiocentralServerData.local({List<String>? availableServices})
      : name = 'localhost',
        url = Constants.localHostServerURL,
        isBuiltIn = true,
        availableServices = availableServices ??
            const [
              'biocentral_service',
              'embeddings_service',
              'ppi_service',
              'prediction_models_service',
              'protein_service',
            ];

  const BiocentralServerData.official({List<String>? availableServices})
      : name = 'Official',
        url = Constants.officialServerURL,
        isBuiltIn = true,
        availableServices = availableServices ??
            const [
              'biocentral_service',
              'embeddings_service',
              'ppi_service',
              'prediction_models_service',
              'protein_service',
            ];

  bool isLocal() {
    return name == 'localhost' || url.contains('127.0.0.1');
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url, 'availableServices': availableServices};
  }

  factory BiocentralServerData.fromJson(Map<String, dynamic> json) {
    return BiocentralServerData(
      name: json['name'] as String,
      url: json['url'] as String,
      availableServices: (json['availableServices'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  @override
  List<Object?> get props => [name, url, availableServices, isBuiltIn];
}
