# biocentral_api.model.BootstrappedMetric

## Load the model package

```dart
import 'package:biocentral_api/api.dart';
```

## Properties

| Name                | Type       | Description                                 | Notes |
| ------------------- | ---------- | ------------------------------------------- | ----- |
| **name**            | **String** | Name of the metric                          |
| **mean**            | **num**    | Mean of the metric values                   |
| **lower**           | **num**    | Lower bound of the metric values            |
| **upper**           | **num**    | Upper bound of the metric values            |
| **iterations**      | **int**    | Number of iterations used for bootstrapping |
| **sampleSize**      | **int**    | Sample size used for bootstrapping          |
| **confidenceLevel** | **num**    | Confidence level used for bootstrapping     |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
