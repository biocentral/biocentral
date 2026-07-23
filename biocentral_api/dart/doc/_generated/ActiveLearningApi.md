# biocentral_api.api.ActiveLearningApi

## Load the API package
```dart
import 'package:biocentral_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**activeLearningEngineeringIterationApiV1ActiveLearningServiceEngineeringIterationPost**](ActiveLearningApi.md#activelearningengineeringiterationapiv1activelearningserviceengineeringiterationpost) | **POST** /api/v1/active_learning_service/engineering_iteration | Run one active learning engineering iteration
[**activeLearningScreeningIterationApiV1ActiveLearningServiceScreeningIterationPost**](ActiveLearningApi.md#activelearningscreeningiterationapiv1activelearningservicescreeningiterationpost) | **POST** /api/v1/active_learning_service/screening_iteration | Run one active learning screening iteration
[**activeLearningScreeningSimulationApiV1ActiveLearningServiceScreeningSimulationPost**](ActiveLearningApi.md#activelearningscreeningsimulationapiv1activelearningservicescreeningsimulationpost) | **POST** /api/v1/active_learning_service/screening_simulation | Run a simulated active learning screening campaign


# **activeLearningEngineeringIterationApiV1ActiveLearningServiceEngineeringIterationPost**
> StartTaskResponse activeLearningEngineeringIterationApiV1ActiveLearningServiceEngineeringIterationPost(activeLearningEngineeringIterationRequest)

Run one active learning engineering iteration

Submit an active learning engineering iteration job

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getActiveLearningApi();
final ActiveLearningEngineeringIterationRequest activeLearningEngineeringIterationRequest = ; // ActiveLearningEngineeringIterationRequest | 

try {
    final response = api.activeLearningEngineeringIterationApiV1ActiveLearningServiceEngineeringIterationPost(activeLearningEngineeringIterationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ActiveLearningApi->activeLearningEngineeringIterationApiV1ActiveLearningServiceEngineeringIterationPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **activeLearningEngineeringIterationRequest** | [**ActiveLearningEngineeringIterationRequest**](ActiveLearningEngineeringIterationRequest.md)|  | 

### Return type

[**StartTaskResponse**](StartTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **activeLearningScreeningIterationApiV1ActiveLearningServiceScreeningIterationPost**
> StartTaskResponse activeLearningScreeningIterationApiV1ActiveLearningServiceScreeningIterationPost(activeLearningScreeningIterationRequest)

Run one active learning screening iteration

Submit an active learning screening iteration job

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getActiveLearningApi();
final ActiveLearningScreeningIterationRequest activeLearningScreeningIterationRequest = ; // ActiveLearningScreeningIterationRequest | 

try {
    final response = api.activeLearningScreeningIterationApiV1ActiveLearningServiceScreeningIterationPost(activeLearningScreeningIterationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ActiveLearningApi->activeLearningScreeningIterationApiV1ActiveLearningServiceScreeningIterationPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **activeLearningScreeningIterationRequest** | [**ActiveLearningScreeningIterationRequest**](ActiveLearningScreeningIterationRequest.md)|  | 

### Return type

[**StartTaskResponse**](StartTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **activeLearningScreeningSimulationApiV1ActiveLearningServiceScreeningSimulationPost**
> StartTaskResponse activeLearningScreeningSimulationApiV1ActiveLearningServiceScreeningSimulationPost(activeLearningScreeningSimulationRequest)

Run a simulated active learning screening campaign

Submit an active learning screening simulation job

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getActiveLearningApi();
final ActiveLearningScreeningSimulationRequest activeLearningScreeningSimulationRequest = ; // ActiveLearningScreeningSimulationRequest | 

try {
    final response = api.activeLearningScreeningSimulationApiV1ActiveLearningServiceScreeningSimulationPost(activeLearningScreeningSimulationRequest);
    print(response);
} on DioException catch (e) {
    print('Exception when calling ActiveLearningApi->activeLearningScreeningSimulationApiV1ActiveLearningServiceScreeningSimulationPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **activeLearningScreeningSimulationRequest** | [**ActiveLearningScreeningSimulationRequest**](ActiveLearningScreeningSimulationRequest.md)|  | 

### Return type

[**StartTaskResponse**](StartTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

