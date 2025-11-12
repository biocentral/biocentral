# biocentral_api.api.PlmEvalApi

## Load the API package
```dart
import 'package:biocentral_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**autoevalApiV1PlmEvalServiceAutoevalPost**](PlmEvalApi.md#autoevalapiv1plmevalserviceautoevalpost) | **POST** /api/v1/plm_eval_service/autoeval | Automated Protein Language Model Evaluation
[**plmEvalInformationApiV1PlmEvalServicePlmEvalInformationGet**](PlmEvalApi.md#plmevalinformationapiv1plmevalserviceplmevalinformationget) | **GET** /api/v1/plm_eval_service/plm_eval_information | Get PLM eval information
[**validateApiV1PlmEvalServiceValidateModelIdPost**](PlmEvalApi.md#validateapiv1plmevalservicevalidatemodelidpost) | **POST** /api/v1/plm_eval_service/validate_model_id | Validate model ID


# **autoevalApiV1PlmEvalServiceAutoevalPost**
> StartTaskResponse autoevalApiV1PlmEvalServiceAutoevalPost(pLMEvalAutoevalRequest)

Automated Protein Language Model Evaluation

Automated protein language model evaluation on pre-defined, curated datasets and tasks

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getPlmEvalApi();
final PLMEvalAutoevalRequest pLMEvalAutoevalRequest = ; // PLMEvalAutoevalRequest | 

try {
    final response = api.autoevalApiV1PlmEvalServiceAutoevalPost(pLMEvalAutoevalRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlmEvalApi->autoevalApiV1PlmEvalServiceAutoevalPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pLMEvalAutoevalRequest** | [**PLMEvalAutoevalRequest**](PLMEvalAutoevalRequest.md)|  | 

### Return type

[**StartTaskResponse**](StartTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **plmEvalInformationApiV1PlmEvalServicePlmEvalInformationGet**
> PLMEvalInformationResponse plmEvalInformationApiV1PlmEvalServicePlmEvalInformationGet()

Get PLM eval information

Get information about PLM eval datasets and process

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getPlmEvalApi();

try {
    final response = api.plmEvalInformationApiV1PlmEvalServicePlmEvalInformationGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlmEvalApi->plmEvalInformationApiV1PlmEvalServicePlmEvalInformationGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**PLMEvalInformationResponse**](PLMEvalInformationResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **validateApiV1PlmEvalServiceValidateModelIdPost**
> PLMEvalValidateResponse validateApiV1PlmEvalServiceValidateModelIdPost(pLMEvalValidateRequest)

Validate model ID

Validate if the given model id exists on huggingface and can be used for plm_eval

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getPlmEvalApi();
final PLMEvalValidateRequest pLMEvalValidateRequest = ; // PLMEvalValidateRequest | 

try {
    final response = api.validateApiV1PlmEvalServiceValidateModelIdPost(pLMEvalValidateRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PlmEvalApi->validateApiV1PlmEvalServiceValidateModelIdPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **pLMEvalValidateRequest** | [**PLMEvalValidateRequest**](PLMEvalValidateRequest.md)|  | 

### Return type

[**PLMEvalValidateResponse**](PLMEvalValidateResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

