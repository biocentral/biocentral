# biocentral_api.api.CustomModelsApi

## Load the API package
```dart
import 'package:biocentral_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**configOptionsApiV1CustomModelsServiceConfigOptionsProtocolGet**](CustomModelsApi.md#configoptionsapiv1custommodelsserviceconfigoptionsprotocolget) | **GET** /api/v1/custom_models_service/config_options/{protocol} | Get configuration options for a protocol
[**modelFilesApiV1CustomModelsServiceModelFilesPost**](CustomModelsApi.md#modelfilesapiv1custommodelsservicemodelfilespost) | **POST** /api/v1/custom_models_service/model_files | Retrieve model files
[**protocolsApiV1CustomModelsServiceProtocolsGet**](CustomModelsApi.md#protocolsapiv1custommodelsserviceprotocolsget) | **GET** /api/v1/custom_models_service/protocols | Get available protocols
[**startInferenceApiV1CustomModelsServiceStartInferencePost**](CustomModelsApi.md#startinferenceapiv1custommodelsservicestartinferencepost) | **POST** /api/v1/custom_models_service/start_inference | Start model inference
[**startTrainingApiV1CustomModelsServiceStartTrainingPost**](CustomModelsApi.md#starttrainingapiv1custommodelsservicestarttrainingpost) | **POST** /api/v1/custom_models_service/start_training | Start model training
[**verifyConfigApiV1CustomModelsServiceVerifyConfigPost**](CustomModelsApi.md#verifyconfigapiv1custommodelsserviceverifyconfigpost) | **POST** /api/v1/custom_models_service/verify_config/ | Verify configuration


# **configOptionsApiV1CustomModelsServiceConfigOptionsProtocolGet**
> ConfigOptionsResponse configOptionsApiV1CustomModelsServiceConfigOptionsProtocolGet(protocol)

Get configuration options for a protocol

Retrieve available configuration options for a specific biotrainer protocol

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getCustomModelsApi();
final String protocol = protocol_example; // String | 

try {
    final response = api.configOptionsApiV1CustomModelsServiceConfigOptionsProtocolGet(protocol);
    print(response);
} catch on DioException (e) {
    print('Exception when calling CustomModelsApi->configOptionsApiV1CustomModelsServiceConfigOptionsProtocolGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **protocol** | **String**|  | 

### Return type

[**ConfigOptionsResponse**](ConfigOptionsResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **modelFilesApiV1CustomModelsServiceModelFilesPost**
> BuiltMap<String, JsonObject> modelFilesApiV1CustomModelsServiceModelFilesPost(modelFilesRequest)

Retrieve model files

Get trained model files after training completion

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getCustomModelsApi();
final ModelFilesRequest modelFilesRequest = ; // ModelFilesRequest | 

try {
    final response = api.modelFilesApiV1CustomModelsServiceModelFilesPost(modelFilesRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling CustomModelsApi->modelFilesApiV1CustomModelsServiceModelFilesPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **modelFilesRequest** | [**ModelFilesRequest**](ModelFilesRequest.md)|  | 

### Return type

[**BuiltMap&lt;String, JsonObject&gt;**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **protocolsApiV1CustomModelsServiceProtocolsGet**
> ProtocolsResponse protocolsApiV1CustomModelsServiceProtocolsGet()

Get available protocols

Retrieve list of all available biotrainer protocols

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getCustomModelsApi();

try {
    final response = api.protocolsApiV1CustomModelsServiceProtocolsGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling CustomModelsApi->protocolsApiV1CustomModelsServiceProtocolsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**ProtocolsResponse**](ProtocolsResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startInferenceApiV1CustomModelsServiceStartInferencePost**
> StartTaskResponse startInferenceApiV1CustomModelsServiceStartInferencePost(startInferenceRequest)

Start model inference

Submit sequences for prediction using a trained model

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getCustomModelsApi();
final StartInferenceRequest startInferenceRequest = ; // StartInferenceRequest | 

try {
    final response = api.startInferenceApiV1CustomModelsServiceStartInferencePost(startInferenceRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling CustomModelsApi->startInferenceApiV1CustomModelsServiceStartInferencePost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **startInferenceRequest** | [**StartInferenceRequest**](StartInferenceRequest.md)|  | 

### Return type

[**StartTaskResponse**](StartTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startTrainingApiV1CustomModelsServiceStartTrainingPost**
> StartTaskResponse startTrainingApiV1CustomModelsServiceStartTrainingPost(startTrainingRequest)

Start model training

Submit a new model training job with specified configuration and training data

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getCustomModelsApi();
final StartTrainingRequest startTrainingRequest = ; // StartTrainingRequest | 

try {
    final response = api.startTrainingApiV1CustomModelsServiceStartTrainingPost(startTrainingRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling CustomModelsApi->startTrainingApiV1CustomModelsServiceStartTrainingPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **startTrainingRequest** | [**StartTrainingRequest**](StartTrainingRequest.md)|  | 

### Return type

[**StartTaskResponse**](StartTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **verifyConfigApiV1CustomModelsServiceVerifyConfigPost**
> ConfigVerificationResponse verifyConfigApiV1CustomModelsServiceVerifyConfigPost(configVerificationRequest)

Verify configuration

Validate a biotrainer configuration dict

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getCustomModelsApi();
final ConfigVerificationRequest configVerificationRequest = ; // ConfigVerificationRequest | 

try {
    final response = api.verifyConfigApiV1CustomModelsServiceVerifyConfigPost(configVerificationRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling CustomModelsApi->verifyConfigApiV1CustomModelsServiceVerifyConfigPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **configVerificationRequest** | [**ConfigVerificationRequest**](ConfigVerificationRequest.md)|  | 

### Return type

[**ConfigVerificationResponse**](ConfigVerificationResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

