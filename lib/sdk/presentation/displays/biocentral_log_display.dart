import 'package:flutter/material.dart';

import 'package:biocentral/sdk/util/logging.dart';

@immutable
class BiocentralLogDisplay extends StatelessWidget {
  final BiocentralLog log;

  const BiocentralLogDisplay({required this.log, super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle? titleLogStyle = Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold);
    final Widget errorTile = log.error != null
        ? ExpansionTile(
            title: Text('Error', style: titleLogStyle),
            children: [Text(log.error.toString(), style: Theme.of(context).textTheme.displaySmall)],
          )
        : Container();
    final Widget stackTraceTile = log.stackTrace != null
        ? ExpansionTile(
            title: Text('Stack Trace', style: titleLogStyle),
            children: [Text(log.stackTrace.toString(), style: titleLogStyle)],
          )
        : Container();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Card(
          child: ExpansionTile(
              leading: Text(log.getFormatTimeString(), style: titleLogStyle),
              title: Text(
                log.message,
                style: getTextStyleByLog(log, context),
              ),
              children: [errorTile, stackTraceTile],),),
    );
  }

  TextStyle getTextStyleByLog(BiocentralLog log, BuildContext context) {
    return switch (log) {
          BiocentralLogMessage() => Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
          BiocentralLogWarning() => Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
          BiocentralLogError() => Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
        } ??
        const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        );
  }
}
