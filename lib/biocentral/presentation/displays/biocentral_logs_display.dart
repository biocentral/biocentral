import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BiocentralLogsDisplay extends StatefulWidget {
  const BiocentralLogsDisplay({super.key});

  @override
  State<BiocentralLogsDisplay> createState() => _BiocentralLogsDisplayState();
}

class _BiocentralLogsDisplayState extends State<BiocentralLogsDisplay> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: ChangeNotifierProvider<LoggerService>(
            create: (_) => logger,
            child: Consumer<LoggerService>(
              builder: (context, loggerService, child) {
                return BiocentralLogContainer(
                  title: 'Application Logs',
                  logsWidget: ListView.builder(
                    shrinkWrap: true,
                    itemCount: loggerService.logMessages.length,
                    itemBuilder: (context, index) {
                      final BiocentralLog log = loggerService.logMessages[index];
                      return BiocentralLogDisplay(log: log);
                    },
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: ChangeNotifierProvider<ServerLoggerService>(
            create: (_) => serverLogger,
            child: Consumer<ServerLoggerService>(
              builder: (context, serverLoggerService, child) {
                return BiocentralLogContainer(
                  title: 'Local Server Logs',
                  logsWidget: ListView.builder(
                    shrinkWrap: true,
                    itemCount: serverLoggerService.serverLogMessages.length,
                    itemBuilder: (context, index) {
                      final BiocentralLog log = serverLoggerService.serverLogMessages[index];
                      return BiocentralLogDisplay(log: log);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
