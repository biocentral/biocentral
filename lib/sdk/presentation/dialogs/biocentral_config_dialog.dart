import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';

class BiocentralConfigDialogStep<B, S> {
  final bool Function(S state) shouldShow;
  final Widget Function(B bloc, S state) builder;

  const BiocentralConfigDialogStep({
    required this.shouldShow,
    required this.builder,
  });
}

abstract class BiocentralConfigDialogBuilder<B, S> {
  String title();

  List<BiocentralConfigDialogStep<B, S>> steps();

  Widget buildRunButton(B bloc, S state, void Function({dynamic Function()? callback}) closeDialog);
}

class BiocentralConfigDialog<B, S> extends StatefulWidget {
  final BiocentralConfigDialogBuilder<B, S> configDialogBuilder;
  final B bloc;
  final S state;

  const BiocentralConfigDialog({required this.configDialogBuilder, required this.bloc, required this.state, super.key});

  @override
  State<BiocentralConfigDialog> createState() => _BiocentralConfigDialogState<B, S>();
}

class _BiocentralConfigDialogState<B, S> extends State<BiocentralConfigDialog<B, S>> with BiocentralDialogCloseMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BiocentralDialog(
      children: [
        buildTitle(),
        ...buildSteps(widget.bloc, widget.state),
        buildRunButton(widget.bloc, widget.state),
        buildCancelButton(),
      ],
    );
  }

  Widget buildTitle() {
    return Text(
      widget.configDialogBuilder.title(),
      style: Theme.of(context).textTheme.headlineLarge,
    );
  }

  List<Widget> buildSteps(B bloc, S state) {
    return widget.configDialogBuilder
        .steps()
        .where(
          (step) => step.shouldShow(state),
        )
        .map((step) => step.builder(bloc, state))
        .toList();
  }

  Widget buildRunButton(B bloc, S state) => widget.configDialogBuilder.buildRunButton(bloc, state, closeDialog);

  Widget buildCancelButton() {
    return BiocentralSmallButton(onTap: closeDialog, label: 'Close');
  }
}
