import 'package:biocentral/sdk/domain/biocentral_database.dart';

class BiocentralDatabaseRepository {
  final Map<Type, BiocentralDatabase> _availableDatabases;

  BiocentralDatabaseRepository({List<BiocentralDatabase>? databases})
      : _availableDatabases =
            Map.fromEntries(databases?.map((database) => MapEntry(database.getType(), database)) ?? []);

  void addDatabases(List<BiocentralDatabase> databases) {
    final Map<Type, BiocentralDatabase> databaseMap =
        Map.fromEntries(databases.map((database) => MapEntry(database.getType(), database)));
    _availableDatabases.addAll(databaseMap);
  }

  Map<String, Type> getAvailableTypes() {
    return Map.fromEntries(
        _availableDatabases.entries.map((entry) => MapEntry(entry.value.getEntityTypeName(), entry.key)),);
  }

  BiocentralDatabase? getFromType(Type? type) {
    return _availableDatabases[type];
  }
}
