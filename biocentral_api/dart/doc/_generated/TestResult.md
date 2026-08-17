# biocentral_api.model.TestResult

## Load the model package
```dart
import 'package:biocentral_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**inferenceResult** | [**BiotrainerInferenceResult**](BiotrainerInferenceResult.md) | Plain test inference result | [optional] 
**bootstrappedMetrics** | [**BuiltList&lt;BootstrappedMetric&gt;**](BootstrappedMetric.md) | Bootstrapped test metrics | [optional] 
**baselines** | [**BuiltMap&lt;String, BuiltList&lt;BootstrappedMetric&gt;&gt;**](BuiltList.md) | Bootstrapped baselines by method name | [optional] 
**sanityCheckWarnings** | **BuiltList&lt;String&gt;** | Warnings from sanity checks | [optional] 

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


