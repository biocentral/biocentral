import 'package:biocentral/sdk/biocentral_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:biocentral/plugins/ppi/bloc/ppi_properties_bloc.dart';
import 'package:biocentral/plugins/ppi/domain/ppi_repository_properties.dart';

class PPIDatabaseBadges extends StatefulWidget {
  const PPIDatabaseBadges({
    super.key,
  });

  @override
  State<PPIDatabaseBadges> createState() => _PPIDatabaseBadgesState();
}

class _PPIDatabaseBadgesState extends State<PPIDatabaseBadges> {
  final Map<PPIRepositoryProperty, BadgeProperties> badgeMap = {
    PPIRepositoryProperty.unique:
        BadgeProperties('Unique', Colors.green, 'All interaction IDs in your dataset are unique!'),
    PPIRepositoryProperty.duplicates:
        BadgeProperties('Duplicates', Colors.red, 'Your dataset contains some duplicated interactions!'),
    PPIRepositoryProperty.hviDataset: BadgeProperties(
        'Human-Virus Interactions', Colors.purple, 'Your dataset exclusively contains human-virus interactions!',),
    PPIRepositoryProperty.mixedDataset:
        BadgeProperties('Mixed\nInteractions', Colors.cyan, 'Your dataset contains interactions from various species'),
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PPIPropertiesBloc, PPIPropertiesState>(
      builder: (context, state) {
        return Row(
          children: state.status != PPIPropertiesStatus.loaded
              ? [const CircularProgressIndicator()]
              : state.properties.map((property) {
                  return createBadge(property);
                }).toList(),
        );
      },
    );
  }

  Widget createBadge(PPIRepositoryProperty databaseProperty) {
    final BadgeProperties badgeProperties = badgeMap[databaseProperty]!;
    return SizedBox.fromSize(
      size: const Size(100, 40),
      child: BiocentralTooltip(
        message: badgeProperties.tooltip,
        child: ClipRect(
          child: Material(
            shape:
                ContinuousRectangleBorder(side: const BorderSide(width: 2.0), borderRadius: BorderRadius.circular(20)),
            color: badgeProperties.color,
            child: InkWell(
              splashColor: Theme.of(context).colorScheme.secondary,
              customBorder: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(50)),
              child: Align(
                  child: Text(
                    badgeProperties.text,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),),
            ),
          ),
        ),
      ),
    );
  }
}

class BadgeProperties {
  final String text;
  final MaterialColor color;
  final String tooltip;

  BadgeProperties(this.text, this.color, this.tooltip);
}
