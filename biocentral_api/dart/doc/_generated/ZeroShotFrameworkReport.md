# biocentral_api.model.ZeroShotFrameworkReport

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**method** | [**ZeroShotMethod**](ZeroShotMethod.md) | Scoring method used | 
**aggregatedResults** | [**BuiltMap&lt;String, RankingResult&gt;**](RankingResult.md) | Accumulated autoeval task results (combined_task_name -> RankingResult) | 
**individualResults** | [**BuiltMap&lt;String, RankingResult&gt;**](RankingResult.md) | Individual autoeval task results (dataset_name -> RankingResult) | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


