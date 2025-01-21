import 'package:bio_flutter/bio_flutter.dart';

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
        required = str2bool(map['required'] ?? 'false'),
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
  final num? gt;  // Greater Than
  final num? gte;  // Greater Than Equal
  final num? lt;  // Lower Than
  final num? lte;  // Lower Than Equal

  BiocentralConfigConstraints({this.typeConstraint, this.gt, this.gte, this.lt, this.lte, this.allowedValues});

  static BiocentralConfigConstraints? fromMap(Map<String, dynamic> map) {
    if(map.isEmpty) {
      return null;
    }
    final typeConstraint = parseTypeConstraint(map['type_constraint']);
    var allowedValues = Set.from(map['allowed'] ?? []);
    if(allowedValues.isEmpty && typeConstraint is bool) {
      allowedValues = {true, false};
    }
    return BiocentralConfigConstraints(
      typeConstraint: typeConstraint,
      gt: map['gt'],
      gte: map['gte'],
      lt: map['lt'],
      lte: map['lte'],
      allowedValues: allowedValues
    );
  }

  static Type? parseTypeConstraint(String? typeConstraint) {
    if(typeConstraint == null) {
      return null;
    }
    return switch(typeConstraint) {
      'bool' || 'boolean' => bool,
      'int' || 'integer' => int,
      'float' || 'double' => double,
      'str' || 'String' => String,
      _ => String,
    };
  }

  bool isValid(dynamic value) {
    if (typeConstraint != null && value.runtimeType != typeConstraint) {
      return false;
    }
    if (allowedValues != null && allowedValues!.isNotEmpty) return allowedValues!.contains(value);
    if (value is num) {
      if (gt != null && value <= gt!) return false;
      if (gte != null && value < gte!) return false;
      if (lt != null && value >= lt!) return false;
      if (lte != null && value > lte!) return false;
    }
    return true;
  }
}
