import 'package:biocentral/sdk/biocentral_sdk.dart';

enum PredictionProtocol with ComparableEnum {
  residue_to_class,
  residues_to_class,
  sequence_to_class,
  sequence_to_value
}
