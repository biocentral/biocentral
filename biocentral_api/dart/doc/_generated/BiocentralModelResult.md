# biocentral_api.model.BiocentralModelResult

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**modelResult** | [**BiotrainerModelResult**](BiotrainerModelResult.md) | Biotrainer Model Result containing config, training and test results and metadata | 
**loggingFile** | **String** | Logging output during model training | 
**checkpoints** | [**BuiltList&lt;BiotrainerCheckpoint&gt;**](BiotrainerCheckpoint.md) | List of bytes containing the checkpoint(s) of the model (name -> checkpoint) | 
**onnxCheckpoint** | [**BuiltList&lt;BiotrainerCheckpoint&gt;**](BiotrainerCheckpoint.md) | Bytes containing the ONNX-converted checkpoint(s) of the model (if available, name -> checkpoint) | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


