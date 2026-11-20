# biocentral_api.model.ActiveLearningEngineeringCampaignConfig

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**embedderName** | **String** | Name of the embedder model to use | 
**name** | **String** | Name of the active learning campaign | 
**modelType** | [**ActiveLearningModelType**](ActiveLearningModelType.md) | Type of model to use | 
**optimizationMode** | [**ActiveLearningOptimizationMode**](ActiveLearningOptimizationMode.md) | Optimization mode selection | 
**seed** | **int** | Random seed for reproducibility. | [optional] 
**wildtypeSequence** | **String** | Wildtype sequence to engineer | 
**useDeltaEmbeddings** | **bool** | Use each sequence's embedding minus the wildtype embedding as model input (only supported for residue-aware embedders) | [optional] [default to false]
**allowedSubstitutions** | [**BuiltList&lt;Mutation&gt;**](Mutation.md) | Wildtype-relative substitutions the generator may draw from. None allows any standard amino acid at any position. The design space always includes the wildtype residue at every position | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


