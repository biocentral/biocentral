import 'package:biocentral/biocentral/bloc/biocentral_sidebar_bloc.dart';
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
        final sidebarVisible = state.showSidebar;
        return AnimatedSlide(
          offset: sidebarVisible ? Offset.zero : const Offset(1, 0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: sidebarVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: sidebarVisible
                ? Container(
                    width: 300,
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
                            onPressed: () => BlocProvider.of<BiocentralSideBarBloc>(context)
                                .add(BiocentralSideBarChangeVisibilityEvent(showSidebar: false)),
                          ),
                        ),
                        Expanded(child: Text(state.showHelp ?? 'SIDEBAR TEST')),
                      ],
                    ),
                  )
                : const SizedBox(width: 0),
          ),
        );
      },
    );
  }
}
