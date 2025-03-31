import 'dart:convert';

import 'package:biocentral/sdk/model/biocentral_config_option.dart';
import 'package:yaml/yaml.dart';

class BiocentralGenericConfigHandler {
  final ConfigHandlingStrategy _handlingStrategy;

  BiocentralGenericConfigHandler(this._handlingStrategy);

  Future<Map<BiocentralConfigOption, dynamic>> parse(
      String? fileContent, Map<BiocentralConfigOption, dynamic> configMap) async {
    final resultMap = Map.of(configMap);
    final configFileMap = await _handlingStrategy.parse(fileContent);

    for (final key in configMap.keys) {
      if (configFileMap.containsKey(key.name)) {
        resultMap[key] = configFileMap[key.name];
      }
    }
    return resultMap;
  }
  
  Future<String> write(Map<BiocentralConfigOption, dynamic> configMap) async => _handlingStrategy.write(configMap);

  Set<String> supportedFileExtensions() => _handlingStrategy.supportedFileExtensions();
}

abstract class ConfigHandlingStrategy {
  Future<Map<String, dynamic>> parse(String? fileContent);
  Future<String> write(Map<BiocentralConfigOption, dynamic> configMap);
  Set<String> supportedFileExtensions();
}

class JSONConfigHandlingStrategy implements ConfigHandlingStrategy {
  @override
  Future<Map<String, dynamic>> parse(String? fileContent) async {
    if (fileContent == null) {
      return <String, dynamic>{};
    }
    return jsonDecode(fileContent);
  }

  @override
  Future<String> write(Map<BiocentralConfigOption, dynamic> configMap) async {
    return jsonEncode(configMap.map((k, v) => MapEntry(k.name, v)));
  }

  @override
  Set<String> supportedFileExtensions() {
    return {'.json'};
  }
}

class YAMLConfigHandlingStrategy implements ConfigHandlingStrategy {
  @override
  Future<Map<String, dynamic>> parse(String? fileContent) async {
    if (fileContent == null) {
      return <String, dynamic>{};
    }

    final YamlMap parsedConfigYaml = loadYaml(fileContent);
    return Map<String, dynamic>.from(parsedConfigYaml.value);
  }

  @override
  Future<String> write(Map<BiocentralConfigOption, dynamic> configMap) async {
    final yamlMap = YamlMap.wrap(configMap.map((k, v) => MapEntry(k.name, v)));
    return yamlMap.toString();
  }

  @override
  Set<String> supportedFileExtensions() {
    return {'.yml', '.yaml'};
  }
}
