# biocentral_api.api.ProjectionsApi

## Load the API package
```dart
import 'package:biocentral_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**projectApiV1ProjectionServiceProjectPost**](ProjectionsApi.md#projectapiv1projectionserviceprojectpost) | **POST** /api/v1/projection_service/project | Calculate projections
[**projectionConfigApiV1ProjectionServiceProjectionConfigGet**](ProjectionsApi.md#projectionconfigapiv1projectionserviceprojectionconfigget) | **GET** /api/v1/projection_service/projection_config | Get Protspace config options


# **projectApiV1ProjectionServiceProjectPost**
> StartTaskResponse projectApiV1ProjectionServiceProjectPost(projectionRequest)

Calculate projections

Calculate projections for embeddings using Protspace

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getProjectionsApi();
final ProjectionRequest projectionRequest = ; // ProjectionRequest | 

try {
    final response = api.projectApiV1ProjectionServiceProjectPost(projectionRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling ProjectionsApi->projectApiV1ProjectionServiceProjectPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **projectionRequest** | [**ProjectionRequest**](ProjectionRequest.md)|  | 

### Return type

[**StartTaskResponse**](StartTaskResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **projectionConfigApiV1ProjectionServiceProjectionConfigGet**
> GetProjectionConfigResponse projectionConfigApiV1ProjectionServiceProjectionConfigGet()

Get Protspace config options

Get Protspace project configs by projection method

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getProjectionsApi();

try {
    final response = api.projectionConfigApiV1ProjectionServiceProjectionConfigGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling ProjectionsApi->projectionConfigApiV1ProjectionServiceProjectionConfigGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**GetProjectionConfigResponse**](GetProjectionConfigResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

