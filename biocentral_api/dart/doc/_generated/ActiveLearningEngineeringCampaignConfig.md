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
**useDeltaEmbeddings** | **bool** | Use each sequence's embedding minus the wildtype embedding as model input (protein language model embedders only) | [optional] [default to false]
**allowedSubstitutions** | **BuiltList&lt;String&gt;** | Substitutions the generator may draw from, as wildtype-relative descriptors such as V39A. None allows any standard amino acid at any position. A position's alphabet is the wildtype residue plus every residue named for it, so reverting to the wildtype is always part of the design space. | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


