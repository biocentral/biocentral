import 'package:tutorial_system/tutorial_system.dart';

class BiocentralAssetDataset {
  final String name;
  final String path;
  final String docs;

  final TutorialID? tutorialID;

  BiocentralAssetDataset({required this.name, required this.path, required this.docs, this.tutorialID});
}
