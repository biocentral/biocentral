# biocentral_api.model.BiotrainerPrediction

## Load the model package

```dart
import 'package:biocentral_api/api.dart';
```

## Properties

| Name               | Type                                             | Description                                                    | Notes                         |
| ------------------ | ------------------------------------------------ | -------------------------------------------------------------- | ----------------------------- |
| **seqId**          | **String**                                       | Sequence identifier                                            |
| **prediction**     | [**Prediction1**](Prediction1.md)                |                                                                |
| **isAggregated**   | **bool**                                         | Whether the prediction is an aggregated per-residue prediction | [optional] [default to false] |
| **residueIndex**   | **int**                                          | Residue index for non-collapsed per-residue predictions        | [optional]                    |
| **rawPrediction**  | [**RawPrediction**](RawPrediction.md)            |                                                                | [optional]                    |
| **mcdPredictions** | [**BuiltList&lt;JsonObject&gt;**](JsonObject.md) | All Monte-Carlo-Dropout predictions                            | [optional]                    |
| **mcdMean**        | [**McdMean**](McdMean.md)                        |                                                                | [optional]                    |
| **mcdStd**         | [**McdStd**](McdStd.md)                          |                                                                | [optional]                    |
| **mcdLowerBound**  | [**McdLowerBound**](McdLowerBound.md)            |                                                                | [optional]                    |
| **mcdUpperBound**  | [**McdUpperBound**](McdUpperBound.md)            |                                                                | [optional]                    |
| **baldScore**      | **num**                                          | BALD score                                                     | [optional]                    |

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
