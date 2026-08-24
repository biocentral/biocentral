import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CloseProjectDialog extends StatefulWidget {
  const CloseProjectDialog({super.key});

  @override
  State<CloseProjectDialog> createState() => _CloseProjectDialogState();
}

class _CloseProjectDialogState extends State<CloseProjectDialog> with BiocentralDialogCloseMixin {
  void _confirmClose() {
    final closeProjectController = context.read<CloseProjectController>();
    closeDialog(callback: () => closeProjectController.closeProject());
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralDialog(
      small: true,
      children: [
        Text(
          'Close project',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 20),
        const Text('Close the current project and return to the start page?'),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BiocentralSmallButton(onTap: closeDialog, label: 'Cancel'),
            BiocentralSmallButton(onTap: _confirmClose, label: 'Close project'),
          ],
        ),
      ],
    );
  }
}
