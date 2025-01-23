// TODO Replace with bio_flutter function
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

/// Manages configuration options for different tasks on the server
class BiocentralConfigOption {
  final String name;
  final bool required;
  final dynamic defaultValue;

  final String? category;
  final String? description;
  final BiocentralConfigConstraints? constraints;

  BiocentralConfigOption.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        required = str2bool(map['required']) ?? false,
        defaultValue = map['default'],
        category = map['category'],
        description = map['description'],
        constraints = BiocentralConfigConstraints.fromMap(map['constraints']);

  bool isValid(dynamic value) {
    return constraints?.isValid(value) ?? true;
  }
}

class BiocentralConfigConstraints {
  final Type? typeConstraint;
  final Set<dynamic>? allowedValues;
  final num? gt; // Greater Than
  final num? gte; // Greater Than Equal
  final num? lt; // Lower Than
  final num? lte; // Lower Than Equal

  BiocentralConfigConstraints({this.typeConstraint, this.gt, this.gte, this.lt, this.lte, this.allowedValues});

  static BiocentralConfigConstraints? fromMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return null;
    }
    final typeConstraint = parseTypeConstraint(map['type']);
    var allowedValues = Set.from(map['allowed'] ?? []);
    if (allowedValues.isEmpty && typeConstraint is bool) {
      allowedValues = {true, false};
    }
    return BiocentralConfigConstraints(
        typeConstraint: typeConstraint,
        gt: map['gt'],
        gte: map['gte'],
        lt: map['lt'],
        lte: map['lte'],
        allowedValues: allowedValues);
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

    // Check type constraint
    if (typeConstraint != null && typeConstraint != String) {
      if (value.runtimeType != typeConstraint) {
        if (typeConstraint == int && int.tryParse(value.toString()) != null) {
          // Special case for double that is also an integer
        } else if(typeConstraint == double && value.runtimeType == int) {
          // Special case for int that is also a double
        }
        else {
          return (false, 'Invalid type. Expected: ${typeConstraint.toString()}. Got: ${value.runtimeType}', null);
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
