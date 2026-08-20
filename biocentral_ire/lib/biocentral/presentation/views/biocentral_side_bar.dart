import 'package:biocentral/biocentral/bloc/biocentral_sidebar_bloc.dart';
import 'package:biocentral/biocentral/presentation/displays/biocentral_command_log_display.dart';
import 'package:biocentral/sdk/util/size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Animated sidebar to show help, wiki and settings
class BiocentralSideBar extends StatelessWidget {
  const BiocentralSideBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BiocentralSideBarBloc, BiocentralSideBarState>(
      builder: (context, state) {
        final sidebarVisible = state.displayMode != BiocentralSideBarDisplayMode.none;
        return AnimatedSlide(
          offset: sidebarVisible ? Offset.zero : const Offset(1, 0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: sidebarVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: sidebarVisible
                ? Container(
                    width: SizeConfig.screenWidth(context) * 0.33,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(-2, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Close button
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => BlocProvider.of<BiocentralSideBarBloc>(context).add(
                              BiocentralSideBarChangeVisibilityEvent(
                                displayMode: state.displayMode,
                              ),
                            ),
                          ),
                        ),
                        buildSideBar(state),
                      ],
                    ),
                  )
                : const SizedBox(width: 0),
          ),
        );
      },
    );
  }

  Widget buildSideBar(BiocentralSideBarState state) {
    switch (state.displayMode) {
      case BiocentralSideBarDisplayMode.help:
        return buildHelpSideBar(state);
      case BiocentralSideBarDisplayMode.commandLog:
        return buildCommandLogSideBar(state);
      case BiocentralSideBarDisplayMode.none:
        return Container();
    }
  }

  Widget buildHelpSideBar(BiocentralSideBarState state) {
    return Expanded(child: Text(state.showHelp ?? 'SIDEBAR TEST'));
  }

  Widget buildCommandLogSideBar(BiocentralSideBarState state) {
    return const Expanded(child: BiocentralCommandLogView());
  }
}
