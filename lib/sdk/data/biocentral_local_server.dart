import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;

import '../util/biocentral_exception.dart';
import '../util/logging.dart';

class BiocentralLocalServer {
  static final BiocentralLocalServer _instance = BiocentralLocalServer._internal();

  factory BiocentralLocalServer() {
    return _instance;
  }

  BiocentralLocalServer._internal();

  Process? _serverProcess;
  List<String> _localServices = [];

  Future<Either<BiocentralException, List<String>>> start(
      {required String extractedExecutablePath, required String workingDirectory}) async {
    if (_serverProcess != null) {
      logger.w('Server is already running.');
      return right(_localServices);
    }

    // Check if the server is running on localhost but started outside of this main application
    List<String> localServicesFromOutsideProcess = await getLocalServices();
    if (localServicesFromOutsideProcess.isNotEmpty) {
      logger.i('Server is already running as a separate process, connecting to the server now.');
      _localServices = localServicesFromOutsideProcess;
      return right(_localServices);
    }

    try {
      // Change file permissions to executable
      await _setExecutablePermissions(extractedExecutablePath);

      _serverProcess = await Process.start(extractedExecutablePath, ["--headless"], workingDirectory: workingDirectory);

      _serverProcess!.stdout.transform(utf8.decoder).listen(serverLogger.i);
      _serverProcess!.stderr.transform(utf8.decoder).listen(serverLogger.e);

      _serverProcess!.exitCode.then((exitCode) {
        logger.i('Server process exited with code $exitCode');
        _serverProcess = null;
      });

      // Wait for server startup (max ~1 minute)
      const timeoutDuration = Duration(seconds: 60);
      const stepSize = Duration(seconds: 5);

      for (int step = 0; step < timeoutDuration.inSeconds; step += stepSize.inSeconds) {
        await Future.delayed(stepSize);
        _localServices = await getLocalServices();
        if (_localServices.isNotEmpty) {
          break;
        }
      }

      if (_localServices.isEmpty) {
        _serverProcess?.kill();
        _serverProcess = null;
        _localServices = [];
        return left(BiocentralServerException(
            message: "Error starting server process or local server does not provide any services!"));
      }

      logger.i('Server started successfully.');
      return right(_localServices);
    } catch (e) {
      logger.e('$e');
      _serverProcess?.kill();
      _serverProcess = null;
      _localServices = [];
      return left(BiocentralServerException(message: "Error starting server process", error: e));
    }
  }

  Future<void> _setExecutablePermissions(String filePath) async {
    if (Platform.isWindows) {
      // On Windows, .exe files are executable by default
      return;
    } else if (kIsWeb) {
      throw BiocentralSecurityException(
        message: "Trying to set file permissions on the web, this should not have happened!",
      );
    } else if (Platform.isMacOS || Platform.isLinux) {
      // On macOS and Linux, use chmod to set executable permissions
      try {
        await Process.run('chmod', ['+x', filePath]);
      } catch (e) {
        throw BiocentralServerException(
          message: "Failed to set executable permissions",
          error: e,
        );
      }
    } else {
      throw BiocentralServerException(
        message: "Unsupported platform for setting executable permissions",
      );
    }
  }

  Future<void> stop() async {
    if (_serverProcess == null) {
      logger.w('No server is running.');
      return;
    }

    logger.i('Stopping server...');
    _serverProcess!.kill(ProcessSignal.sigterm);

    // Wait for the process to exit
    await _serverProcess!.exitCode;
    _serverProcess = null;
    _localServices = [];
    logger.i('Server stopped.');
  }

  Future<List<String>> getLocalServices() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:9540/biocentral_service/services'));
      if (response.statusCode != 200) {
        return [];
      }
      Map responseMap = jsonDecode(response.body);
      return List<String>.from(responseMap["services"]);
    } catch (e) {
      return [];
    }
  }

  bool isRunning() {
    return _serverProcess != null;
  }
}
