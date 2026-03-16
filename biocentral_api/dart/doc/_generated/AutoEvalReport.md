# biocentral_api.model.AutoEvalReport

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**embedderName** | **String** | Name of the embedder | 
**trainingDate** | **String** | Date of training | 
**supervisedResults** | [**BuiltMap&lt;String, SupervisedFrameworkReport&gt;**](SupervisedFrameworkReport.md) | Supervised autoeval results | 
**zeroshotResults** | [**BuiltMap&lt;String, ZeroShotFrameworkReport&gt;**](ZeroShotFrameworkReport.md) | Zero-Shot autoeval results | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


