# biocentral_api.model.ClusteringRequest

## Load the model package

```dart
import 'package:biocentral_api/api.dart';
```

## Properties

| Name                          | Type                               | Description                                                          | Notes                       |
| ----------------------------- | ---------------------------------- | -------------------------------------------------------------------- | --------------------------- |
| **sequenceData**              | **BuiltMap&lt;String, String&gt;** | Dictionary mapping sequence IDs to their amino acid sequence strings |
| **sequenceIdentityThreshold** | **num**                            | Sequence identity threshold for clustering (between 0.0 and 1.0)     | [optional] [default to 0.3] |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
