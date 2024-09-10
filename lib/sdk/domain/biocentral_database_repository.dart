import 'biocentral_database.dart';

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

  Set<Type> getAvailableTypes() {
    return _availableDatabases.keys.toSet();
  }

  BiocentralDatabase? getFromType(Type? type) {
    return _availableDatabases[type];
  }
}
