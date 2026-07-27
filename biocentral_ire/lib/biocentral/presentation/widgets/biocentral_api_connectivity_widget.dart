import 'package:biocentral/sdk/domain/biocentral_api_repository.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_tooltip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BiocentralAPIConnectivityWidget extends StatelessWidget {
  const BiocentralAPIConnectivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final apiRepository = context.read<BiocentralAPIRepository>();

    return StreamBuilder(
      initialData: apiRepository.currentHealth,
      stream: apiRepository.healthStatusStream,
      builder: (context, snapshot) {
        final healthStatusList = snapshot.data ?? [];
        final connectionStatusAny =
        healthStatusList.isEmpty ? false : healthStatusList.any((health) => health.healthy);
        final connectionColor = connectionStatusAny == true ? Colors.green : Colors.red;
        final connectionMessage = connectionStatusAny == true ? 'Connected!' : 'Not connected';
        String tooltipMessage = 'Connection Status: \n\n';
        for (final healthStatus in healthStatusList) {
          tooltipMessage += '${healthStatus.url}: ${healthStatus.healthy ? 'Connected' : 'Not connected'}';
          tooltipMessage += healthStatus.version != null ? ' (v${healthStatus.version})' : '';
          tooltipMessage += '\n';
        }
        return BiocentralTooltip(
          message: tooltipMessage,
          child: Row(
            children: [
              Icon(
                Icons.cloud_circle_sharp,
                color: connectionColor,
                size: 14,
              ),
              const SizedBox(
                width: 4,
              ),
              Text(
                'Biocentral API - $connectionMessage',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        );
      },
    );
  }
  
}