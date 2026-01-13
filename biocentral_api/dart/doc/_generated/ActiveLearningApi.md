# biocentral_api.api.ActiveLearningApi

## Load the API package
```dart
import 'package:biocentral_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**activeLearningIterationApiV1ActiveLearningServiceIterationPost**](ActiveLearningApi.md#activelearningiterationapiv1activelearningserviceiterationpost) | **POST** /api/v1/active_learning_service/iteration | Run one active learning iteration
[**activeLearningSimulationApiV1ActiveLearningServiceSimulationPost**](ActiveLearningApi.md#activelearningsimulationapiv1activelearningservicesimulationpost) | **POST** /api/v1/active_learning_service/simulation | Run a simulated active learning campaign


# **activeLearningIterationApiV1ActiveLearningServiceIterationPost**
> StartTaskResponse activeLearningIterationApiV1ActiveLearningServiceIterationPost(activeLearningIterationRequest)

Run one active learning iteration

Submit an active learning iteration job

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getActiveLearningApi();
final ActiveLearningIterationRequest activeLearningIterationRequest = ; // ActiveLearningIterationRequest | 

try {
    final response = api.activeLearningIterationApiV1ActiveLearningServiceIterationPost(activeLearningIterationRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ActiveLearningApi->activeLearningIterationApiV1ActiveLearningServiceIterationPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **activeLearningIterationRequest** | [**ActiveLearningIterationRequest**](ActiveLearningIterationRequest.md)|  | 

### Return type

[**StartTaskResponse**](StartTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **activeLearningSimulationApiV1ActiveLearningServiceSimulationPost**
> StartTaskResponse activeLearningSimulationApiV1ActiveLearningServiceSimulationPost(activeLearningSimulationRequest)

Run a simulated active learning campaign

Submit an active learning simulation job

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getActiveLearningApi();
final ActiveLearningSimulationRequest activeLearningSimulationRequest = ; // ActiveLearningSimulationRequest | 

try {
    final response = api.activeLearningSimulationApiV1ActiveLearningServiceSimulationPost(activeLearningSimulationRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ActiveLearningApi->activeLearningSimulationApiV1ActiveLearningServiceSimulationPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **activeLearningSimulationRequest** | [**ActiveLearningSimulationRequest**](ActiveLearningSimulationRequest.md)|  | 

### Return type

[**StartTaskResponse**](StartTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

