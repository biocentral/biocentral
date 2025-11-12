# biocentral_api.api.BayesianOptimizationApi

## Load the API package
```dart
import 'package:biocentral_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**trainAndInferenceApiV1BayesianOptimizationServiceTrainingPost**](BayesianOptimizationApi.md#trainandinferenceapiv1bayesianoptimizationservicetrainingpost) | **POST** /api/v1/bayesian_optimization_service/training | Start Bayesian optimization training


# **trainAndInferenceApiV1BayesianOptimizationServiceTrainingPost**
> StartTaskResponse trainAndInferenceApiV1BayesianOptimizationServiceTrainingPost(bayesianOptimizationRequest)

Start Bayesian optimization training

Submit a Bayesian optimization job with specified configuration and training data

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getBayesianOptimizationApi();
final BayesianOptimizationRequest bayesianOptimizationRequest = ; // BayesianOptimizationRequest | 

try {
    final response = api.trainAndInferenceApiV1BayesianOptimizationServiceTrainingPost(bayesianOptimizationRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling BayesianOptimizationApi->trainAndInferenceApiV1BayesianOptimizationServiceTrainingPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **bayesianOptimizationRequest** | [**BayesianOptimizationRequest**](BayesianOptimizationRequest.md)|  | 

### Return type

[**StartTaskResponse**](StartTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

