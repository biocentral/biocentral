import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/sdk/bloc/biocentral_client_bloc.dart';
import 'package:biocentral/sdk/util/size_config.dart';
import 'package:biocentral/sdk/presentation/widgets/biocentral_tooltip.dart';

class BiocentralButton extends StatefulWidget {
  final void Function()? onTap;
  final IconData iconData;
  final String label;
  final List<String> requiredServices;

  const BiocentralButton(
      {required this.onTap, required this.iconData, required this.label, super.key, this.requiredServices = const [],});

  @override
  State<BiocentralButton> createState() => _BiocentralButtonState();
}

class _BiocentralButtonState extends State<BiocentralButton> {
  @override
  void initState() {
    super.initState();
  }

  List<String> getMissingServices(List<String> availableServices) {
    final List<String> missingServices = [];
    for (String service in widget.requiredServices) {
      if (!availableServices.contains(service)) {
        missingServices.add(service);
      }
    }
    return missingServices;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BiocentralClientBloc, BiocentralClientState>(builder: (context, state) {
      final List<String> missingServices = getMissingServices(state.connectedServer?.availableServices ?? []);
      final Widget button = buildButton(missingServices.isNotEmpty ? null : widget.onTap);
      return missingServices.isNotEmpty
          ? BiocentralTooltip(
              message: 'This functionality requires the service(s) $missingServices from a server',
              color: Colors.red,
              child: button,)
          : button;
    },);
  }

  Widget buildButton(void Function()? onTap) {
    return Padding(
      padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal(context) * 0.5),
      child: SizedBox.fromSize(
        size: Size(SizeConfig.safeBlockHorizontal(context) * 7, SizeConfig.safeBlockHorizontal(context) * 7),
        child: ClipRect(
          child: Material(
            shape:
                ContinuousRectangleBorder(side: const BorderSide(width: 3.0), borderRadius: BorderRadius.circular(50)),
            color: Theme.of(context).primaryColor,
            child: InkWell(
              splashColor: Theme.of(context).colorScheme.secondary, // splash color
              customBorder: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(50)),
              onTap: onTap, // button pressed
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(widget.iconData),
                  Text(
                    ' ${widget.label} ',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
