# biocentral_api.model.ModelOutput

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**name** | **String** | Name of the output | 
**description** | **String** | Description of the output | 
**outputType** | [**OutputType**](OutputType.md) | Type of output | 
**valueType** | **String** | Type of output values | 
**classes** | [**BuiltList&lt;OutputClass&gt;**](OutputClass.md) | List of output classes for categorical outputs | [optional] 
**valueRange** | [**BuiltList&lt;JsonObject&gt;**](JsonObject.md) | Value range of predictions for continous outputs | [optional] 
**unit** | **String** | Optional unit for numerical outputs | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


