import 'package:biocentral/sdk/bloc/biocentral_command_bloc.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_status_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BiocentralStatusBar extends StatefulWidget {
  const BiocentralStatusBar({super.key});

  @override
  State<BiocentralStatusBar> createState() => _BiocentralStatusBarState();
}

class _BiocentralStatusBarState extends State<BiocentralStatusBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BiocentralCommandBloc, BiocentralCommandState>(
      builder: (context, state) {
        if (state.isIdle()) {
          return Container();
        }
        return BiocentralStatusIndicator(metaData: state.currentCommandLog?.metaData);
      },
    );
  }
}
