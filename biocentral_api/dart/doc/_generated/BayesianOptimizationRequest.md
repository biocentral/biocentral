# biocentral_api.model.BayesianOptimizationRequest

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**databaseHash** | **String** | Hash identifier for the training database | 
**modelType** | **String** | Type of model to use | 
**coefficient** | **num** | Coefficient value (must be non-negative) | 
**embedderName** | **String** | Name of embedder to use | 
**discrete** | **bool** | Whether to perform discrete optimization or continuous optimization | 
**optimizationMode** | **String** | Optimization mode selection | 
**targetLb** | **num** |  | [optional] 
**targetUb** | **num** |  | [optional] 
**targetValue** | **num** |  | [optional] 
**discreteLabels** | **BuiltList&lt;String&gt;** |  | 
**discreteTargets** | **BuiltList&lt;String&gt;** |  | 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


