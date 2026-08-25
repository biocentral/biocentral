import 'package:biocentral_api/biocentral_api.dart';

class BiocentralCommandAvailability {
  final bool available;
  final String? unavailableMessage;

  BiocentralCommandAvailability({required this.available, required this.unavailableMessage});

  factory BiocentralCommandAvailability.fromHealth(List<BiocentralAPIHealth> currentHealth) {
    const String noApiUnavailableMessage = 'Command requires a healthy biocentral service, but none found!';
    final anyHealthy = currentHealth.any((health) => health.healthy);
    return BiocentralCommandAvailability(available: anyHealthy, unavailableMessage: noApiUnavailableMessage);
  }

  factory BiocentralCommandAvailability.always() {
    return BiocentralCommandAvailability(available: true, unavailableMessage: null);
  }

  BiocentralCommandAvailability and({required bool condition, String? unavailableMessage}) {
    return BiocentralCommandAvailability(
      available: available && condition,
      unavailableMessage: unavailableMessage ?? this.unavailableMessage,
    );
  }
}
