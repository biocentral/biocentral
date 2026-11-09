import 'package:flutter/material.dart';

/// A content-sized workspace dialog with scrollable content and wrapping actions.
class BiocentralWorkspaceDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? child;
  final List<Widget> actions;
  final double maxWidth;

  const BiocentralWorkspaceDialog({
    required this.title,
    required this.actions,
    this.subtitle,
    this.child,
    this.maxWidth = 440,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Dialog(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            if (subtitle != null) ...[const SizedBox(height: 4), Text(subtitle!)],
            if (child != null) ...[const SizedBox(height: 18), child!],
            const SizedBox(height: 20),
            Wrap(alignment: WrapAlignment.end, spacing: 8, runSpacing: 8, children: actions),
          ],
        ),
      ),
    ),
  );
}

/// Returns true only when the user explicitly confirms the action.
Future<bool> showBiocentralConfirmation(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => BiocentralWorkspaceDialog(
          title: title,
          subtitle: message,
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            ElevatedButton(
              style: destructive
                  ? ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    )
                  : null,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ) ??
      false;
}
