import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';


class ColumnWizardDisplay extends StatelessWidget {
  final ColumnWizard columnWizard;
  final Widget Function(ColumnWizard)? customBuildFunction;

  const ColumnWizardDisplay({required this.columnWizard, required this.customBuildFunction, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: SizeConfig.safeBlockVertical(context) * 2,
        ),
        columnWizardDisplayFactory(),
      ],
    );
  }

  Widget columnWizardDisplayFactory() {
    if(customBuildFunction != null) {
      return customBuildFunction!(columnWizard);
    }
    return ColumnWizardGenericDisplay(columnWizard: columnWizard);
  }
}
