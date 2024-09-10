// https://stackoverflow.com/questions/70145480/dart-singleton-with-parameters-global-app-logger
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

LoggerService get logger => LoggerService._instance;

ServerLoggerService get serverLogger => ServerLoggerService._instance;

class LoggerService extends ChangeNotifier {
  final Logger _logger;
  final List<BiocentralLog> _logMessages = [];

  LoggerService._(this._logger);

  static final LoggerService _instance = LoggerService._(
      Logger(printer: PrettyPrinter(dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, methodCount: 8)));

  List<BiocentralLog> get logMessages => List.unmodifiable(_logMessages);

  void i(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    time ??= DateTime.now();
    _logMessages
        .add(BiocentralLogMessage(message: _clearMessage(message), time: time, error: error, stackTrace: stackTrace));
    _logger.i(message, time: time, error: error, stackTrace: stackTrace);
    notifyListeners();
  }

  void w(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    time ??= DateTime.now();
    _logMessages
        .add(BiocentralLogWarning(message: _clearMessage(message), time: time, error: error, stackTrace: stackTrace));
    _logger.w(message, time: time, error: error, stackTrace: stackTrace);
    notifyListeners();
  }

  void e(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    time ??= DateTime.now();
    _logMessages
        .add(BiocentralLogError(message: _clearMessage(message), time: time, error: error, stackTrace: stackTrace));
    _logger.e(message, time: time, error: error, stackTrace: stackTrace);
    notifyListeners();
  }

  void d(dynamic message, {DateTime? time, Object? error, StackTrace? stackTrace}) {
    time ??= DateTime.now();
    _logger.d(_clearMessage(message), time: time, error: error, stackTrace: stackTrace);
  }

  /// Remove GitHub Link for application internal logging
  String _clearMessage(dynamic message) {
    final clearedLines = [];
    final lines = message.toString().split("\n");
    for (String line in lines) {
      if (!line.contains("Create GitHub Issue")) {
        clearedLines.add(line);
      }
    }
    return clearedLines.join("");
  }

  void clearLogs() {
    _logMessages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    // TODO dispose() is called after plugins are unloaded
    // super.dispose();
  }
}

class ServerLoggerService extends ChangeNotifier {
  final List<BiocentralLog> _serverLogMessages = [];

  ServerLoggerService._();

  static final ServerLoggerService _instance = ServerLoggerService._();

  List<BiocentralLog> get serverLogMessages => List.unmodifiable(_serverLogMessages);

  void i(dynamic message) {
    final time = DateTime.now();
    _serverLogMessages.add(BiocentralLogMessage(message: message, time: time));
    if (kDebugMode) {
      _printServerLog(message);
    }
    notifyListeners();
  }

  void e(dynamic message) {
    final time = DateTime.now();
    _serverLogMessages.add(BiocentralLogError(message: message, time: time));
    if (kDebugMode) {
      _printServerLog(message);
    }
    notifyListeners();
  }

  void _printServerLog(dynamic message) {
    if (kDebugMode) {
      stdout.write("\x1B[35m LOCAL SERVER: $message\x1B[0m");
    }
  }

  void clearLogs() {
    _serverLogMessages.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    // TODO dispose() is called after plugins are unloaded
    // super.dispose();
  }
}

sealed class BiocentralLog {
  final String message;
  final DateTime time;
  final Object? error;
  final StackTrace? stackTrace;

  BiocentralLog({required this.message, required this.time, this.error, this.stackTrace});

  String getFormatTimeString() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(time);
  }
}

final class BiocentralLogMessage extends BiocentralLog {
  BiocentralLogMessage({required super.message, required super.time, super.error, super.stackTrace});
}

final class BiocentralLogWarning extends BiocentralLog {
  BiocentralLogWarning({required super.message, required super.time, super.error, super.stackTrace});
}

final class BiocentralLogError extends BiocentralLog {
  BiocentralLogError({required super.message, required super.time, super.error, super.stackTrace});
}
