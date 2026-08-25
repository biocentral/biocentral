// TODO Replace with bio_flutter function
import 'package:biocentral/sdk/data/biocentral_generic_config_parser.dart';

bool? str2bool(String? string) {
  if (string == null) {
    return null;
  }
  if (['yes', 'y', 'true', '1', 't'].contains(string.toLowerCase())) {
    return true;
  } else if (['no', 'n', 'false', '0', 'f'].contains(string.toLowerCase())) {
    return false;
  }
  return null;
}

class BiocentralConfig {
  final List<BiocentralConfigOption> options;
  final Map<String, dynamic> _selectedConfig;
  final BiocentralGenericConfigHandler? configHandler;

  BiocentralConfig({required this.options, Map<String, dynamic>? selectedConfig, this.configHandler})
      : _selectedConfig =
            selectedConfig ?? Map.fromEntries(options.map((option) => MapEntry(option.name, option.defaultValue)));

  const BiocentralConfig.empty()
      : options = const [],
        _selectedConfig = const {},
        configHandler = null;

  Future<BiocentralConfig> load(String? fileContent) async {
    if (configHandler == null || fileContent == null || fileContent.isEmpty) {
      return this;
    }
    final loadResult = await configHandler?.parse(fileContent, _selectedConfig) ?? {};
    if (loadResult.isEmpty) {
      return this;
    }
    return BiocentralConfig(options: options, selectedConfig: loadResult, configHandler: configHandler);
  }

  Map<String, List<BiocentralConfigOption>> clusterByCategory() {
    final String fallbackName = 'other';
    final Map<String, List<BiocentralConfigOption>> result = {};
    for (final option in options) {
      final optionCategory = option.category ?? fallbackName;
      result.putIfAbsent(optionCategory, () => []);
      result[optionCategory]?.add(option);
    }
    return result;
  }

  dynamic currentValueForKey(String? key) {
    return _selectedConfig[key];
  }

  void update(String key, dynamic value) {
    _selectedConfig[key] = value;
  }

  Map<String, String> asStringMap() =>
      Map<String, String>.from(_selectedConfig.map((k, v) => MapEntry(k.toString(), v.toString())));
}

/// Manages configuration options for different tasks on the server
class BiocentralConfigOption {
  final String name;
  final bool required;
  final dynamic defaultValue;

  final String? category;
  final String? description;
  final BiocentralConfigConstraints? constraints;

  BiocentralConfigOption({
    required this.name,
    required this.required,
    required this.defaultValue,
    this.category,
    this.description,
    this.constraints,
  });

  BiocentralConfigOption.deserialize(Map<String, dynamic> map)
      : name = map['name'],
        required = str2bool(map['required'].toString()) ?? false,
        defaultValue = map['default'],
        category = map['category'],
        description = map['description'],
        constraints = BiocentralConfigConstraints.deserialize(map['constraints']);

  Map<String, dynamic> serialize() {
    return {
      'name': name,
      'required': required.toString(),
      'default': defaultValue,
      'category': category,
      'description': description,
      'constraints': constraints?.serialize() ?? {},
    };
  }

  bool isValid(dynamic value) {
    return constraints?.isValid(value) ?? true;
  }
}

class BiocentralConfigConstraints {
  final Type? typeConstraint;
  final Type? mapTypeConstraint;
  final Set<dynamic>? allowedValues;
  final num? gt; // Greater Than
  final num? gte; // Greater Than Equal
  final num? lt; // Lower Than
  final num? lte; // Lower Than Equal

  BiocentralConfigConstraints({
    this.typeConstraint,
    this.mapTypeConstraint,
    this.gt,
    this.gte,
    this.lt,
    this.lte,
    this.allowedValues,
  });

  static BiocentralConfigConstraints? deserialize(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return null;
    }
    final typeConstraint = parseTypeConstraint(map['type']);
    final mapTypeConstraint = parseTypeConstraint(map['mapType']);
    var allowedValues = Set.from(map['allowed'] ?? map['allowed_values'] ?? []);
    if (allowedValues.isEmpty && typeConstraint == bool) {
      allowedValues = {true, false};
    }
    return BiocentralConfigConstraints(
      typeConstraint: typeConstraint,
      mapTypeConstraint: mapTypeConstraint,
      gt: map['gt'],
      gte: map['gte'],
      lt: map['lt'],
      lte: map['lte'],
      allowedValues: allowedValues,
    );
  }

  Map<String, dynamic> serialize() {
    final Map<String, dynamic> result = {};

    if (typeConstraint != null) {
      result['type'] = _typeToString(typeConstraint!);
    }

    if (mapTypeConstraint != null) {
      result['mapType'] = _typeToString(mapTypeConstraint!);
    }

    if (allowedValues != null && allowedValues!.isNotEmpty) {
      result['allowed_values'] = allowedValues!.toList();
    }

    if (gt != null) {
      result['gt'] = gt;
    }

    if (gte != null) {
      result['gte'] = gte;
    }

    if (lt != null) {
      result['lt'] = lt;
    }

    if (lte != null) {
      result['lte'] = lte;
    }

    return result;
  }

  String _typeToString(Type type) {
    if (type == bool) return 'bool';
    if (type == int) return 'int';
    if (type == double) return 'double';
    if (type == String) return 'str';
    return 'str';
  }

  static Type? parseTypeConstraint(String? typeConstraint) {
    if (typeConstraint == null) {
      return null;
    }
    return switch (typeConstraint) {
      'bool' || 'boolean' => bool,
      'int' || 'integer' => int,
      'float' || 'double' => double,
      'str' || 'String' || 'Literal' || 'Any' => String,
      _ => String,
    };
  }

  (bool, String?, dynamic) validate(dynamic value) {
    // Parse the value if it is a string
    if (value is String) {
      dynamic parsedValue;
      for (final parseFunction in [int.tryParse, double.tryParse, str2bool]) {
        parsedValue = parseFunction(value);
        if (parsedValue != null) {
          value = parsedValue;
          break;
        }
      }
    }
    final valueTypeConstraint = mapTypeConstraint ?? typeConstraint;

    // Check type constraint
    if (valueTypeConstraint != null && valueTypeConstraint != String) {
      if (value.runtimeType != valueTypeConstraint) {
        if (valueTypeConstraint == int && int.tryParse(value.toString()) != null) {
          // Special case for double that is also an integer
        } else if (valueTypeConstraint == double && value.runtimeType == int) {
          // Special case for int that is also a double
        } else {
          return (false, 'Invalid type. Expected: ${valueTypeConstraint.toString()}. Got: ${value.runtimeType}', null);
        }
      }
    }

    // Check allowed values
    if (allowedValues != null && allowedValues!.isNotEmpty) {
      if (!allowedValues!.contains(value)) {
        return (false, 'Value must be one of: ${allowedValues!.join(', ')}', null);
      }
      return (true, null, value);
    }

    // Check numeric constraints
    if (value is num) {
      final List<String> violatedConstraints = [];
      if (gt != null && value <= gt!) violatedConstraints.add('> $gt');
      if (gte != null && value < gte!) violatedConstraints.add('≥ $gte');
      if (lt != null && value >= lt!) violatedConstraints.add('< $lt');
      if (lte != null && value > lte!) violatedConstraints.add('≤ $lte');

      if (violatedConstraints.isNotEmpty) {
        return (false, 'Value must be ${violatedConstraints.join(' and ')}', null);
      }
    }

    return (true, null, value);
  }

  bool isValid(dynamic value) {
    final (isValid, _, _) = validate(value);
    return isValid;
  }

  String? Function(String?) get validator {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'This field cannot be empty';
      }

      final (isValid, errorMessage, _) = validate(value);
      return isValid ? null : errorMessage;
    };
  }

  dynamic parse(String value) {
    final (_, _, parsedValue) = validate(value);
    return parsedValue;
  }
}
