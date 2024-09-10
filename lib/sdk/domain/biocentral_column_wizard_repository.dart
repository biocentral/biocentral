import '../model/column_wizard_abstract.dart';
import '../model/column_wizard_defaults.dart';

class BiocentralColumnWizardRepository {
  final Map<Type, ColumnWizardFactory> _factories = {};
  final List<TypeDetector> _detectors = [];

  BiocentralColumnWizardRepository.withDefaultWizards() {
    registerFactories([IntColumnWizardFactory(), DoubleColumnWizardFactory(), StringColumnWizardFactory()]);
  }

  void registerFactories(List<ColumnWizardFactory> factories) {
    for (ColumnWizardFactory factory in factories) {
      _registerFactory(factory);
    }
  }

  void _registerFactory(ColumnWizardFactory factory) {
    TypeDetector detector = factory.getTypeDetector();
    _factories[detector.type] = factory;
    _detectors.add(detector);
    _sortDetectors();
  }

  void _sortDetectors() {
    _detectors.sort((b, a) => a.priority.compareTo(b.priority));
  }

  Future<T> getColumnWizardForColumn<T extends ColumnWizard>(
      {required String columnName, required Map<String, dynamic> valueMap, Type? columnType}) async {
    columnType ??= await _detectColumnType(valueMap.values);
    if (_factories.containsKey(columnType)) {
      return _factories[columnType]!.create(columnName: columnName, valueMap: valueMap) as T;
    }
    // TODO Exception handling
    throw Exception('No factory registered for column type: $columnType');
  }

  Future<Type> _detectColumnType(Iterable<dynamic> values) async {
    Set<dynamic> valuesSet = values.toSet();
    Map<Type, List<bool>> detectionResultMap = {};

    for (final value in valuesSet) {
      for (TypeDetector detector in _detectors) {
        detectionResultMap.putIfAbsent(detector.type, () => []);
        detectionResultMap[detector.type]!.add(detector.detectionFunction(value));
      }
    }

    // TODO Write test that type with highest priority is correctly returned in case of conflict
    for (final typeToDetectionResult in detectionResultMap.entries) {
      if (typeToDetectionResult.value.every((result) => result == true)) {
        return typeToDetectionResult.key;
      }
    }
    return String;
  }
}
