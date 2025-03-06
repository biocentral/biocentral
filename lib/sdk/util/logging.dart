// https://stackoverflow.com/questions/70145480/dart-singleton-with-parameters-global-app-logger
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

LoggerService get logger => LoggerService._instance;

class LoggerService extends ChangeNotifier {
  final Logger _logger;
  final List<BiocentralLog> _logMessages = [];

  LoggerService._(this._logger);

  static final LoggerService _instance = LoggerService._(
      Logger(printer: PrettyPrinter(dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, methodCount: 8)),);

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
    final lines = message.toString().split('\n');
    for (String line in lines) {
      if (!line.contains('Create GitHub Issue')) {
        clearedLines.add(line);
      }
    }
    return clearedLines.join();
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
