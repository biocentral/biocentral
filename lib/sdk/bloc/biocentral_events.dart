import 'package:bio_flutter/bio_flutter.dart';
import 'package:flutter/material.dart';

import 'package:biocentral/sdk/biocentral_sdk.dart';

abstract class BiocentralEvent {}

class BiocentralDatabaseUpdatedEvent extends BiocentralEvent {
  BiocentralDatabaseUpdatedEvent();
}

class BiocentralCommandStateChangedEvent extends BiocentralEvent {
  final BiocentralCommandState state;

  BiocentralCommandStateChangedEvent(this.state);
}

class BiocentralDatabaseSyncEvent extends BiocentralDatabaseUpdatedEvent {
  final Map<String, BioEntity> updatedEntities;
  final DatabaseImportMode importMode;

  BiocentralDatabaseSyncEvent(this.updatedEntities, this.importMode);
}

class BiocentralCommandExecutedEvent extends BiocentralEvent {
  BiocentralCommandExecutedEvent();
}

class BiocentralPluginTabSwitchedEvent extends BiocentralEvent {
  final Widget switchedTab;

  BiocentralPluginTabSwitchedEvent(this.switchedTab);
}
