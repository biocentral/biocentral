# biocentral_api.api.PpiApi

## Load the API package
```dart
import 'package:biocentral_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**autoDetectFormatByHeaderApiV1PpiServiceAutoDetectFormatPost**](PpiApi.md#autodetectformatbyheaderapiv1ppiserviceautodetectformatpost) | **POST** /api/v1/ppi_service/auto_detect_format | Auto Detect Format By Header
[**formatsApiV1PpiServiceFormatsGet**](PpiApi.md#formatsapiv1ppiserviceformatsget) | **GET** /api/v1/ppi_service/formats | Formats
[**importDatasetApiV1PpiServiceImportPost**](PpiApi.md#importdatasetapiv1ppiserviceimportpost) | **POST** /api/v1/ppi_service/import | Import Dataset
[**runTestApiV1PpiServiceDatasetTestsRunTestPost**](PpiApi.md#runtestapiv1ppiservicedatasettestsruntestpost) | **POST** /api/v1/ppi_service/dataset_tests/run_test | Run Test
[**testsApiV1PpiServiceDatasetTestsTestsGet**](PpiApi.md#testsapiv1ppiservicedatasetteststestsget) | **GET** /api/v1/ppi_service/dataset_tests/tests | Tests


# **autoDetectFormatByHeaderApiV1PpiServiceAutoDetectFormatPost**
> DetectedFormatResponse autoDetectFormatByHeaderApiV1PpiServiceAutoDetectFormatPost(autoDetectFormatRequest)

Auto Detect Format By Header

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getPpiApi();
final AutoDetectFormatRequest autoDetectFormatRequest = ; // AutoDetectFormatRequest | 

try {
    final response = api.autoDetectFormatByHeaderApiV1PpiServiceAutoDetectFormatPost(autoDetectFormatRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PpiApi->autoDetectFormatByHeaderApiV1PpiServiceAutoDetectFormatPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **autoDetectFormatRequest** | [**AutoDetectFormatRequest**](AutoDetectFormatRequest.md)|  | 

### Return type

[**DetectedFormatResponse**](DetectedFormatResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **formatsApiV1PpiServiceFormatsGet**
> JsonObject formatsApiV1PpiServiceFormatsGet()

Formats

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getPpiApi();

try {
    final response = api.formatsApiV1PpiServiceFormatsGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PpiApi->formatsApiV1PpiServiceFormatsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **importDatasetApiV1PpiServiceImportPost**
> ImportDatasetResponse importDatasetApiV1PpiServiceImportPost(importDatasetRequest)

Import Dataset

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getPpiApi();
final ImportDatasetRequest importDatasetRequest = ; // ImportDatasetRequest | 

try {
    final response = api.importDatasetApiV1PpiServiceImportPost(importDatasetRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PpiApi->importDatasetApiV1PpiServiceImportPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **importDatasetRequest** | [**ImportDatasetRequest**](ImportDatasetRequest.md)|  | 

### Return type

[**ImportDatasetResponse**](ImportDatasetResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **runTestApiV1PpiServiceDatasetTestsRunTestPost**
> RunTestResponse runTestApiV1PpiServiceDatasetTestsRunTestPost(runTestRequest)

Run Test

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getPpiApi();
final RunTestRequest runTestRequest = ; // RunTestRequest | 

try {
    final response = api.runTestApiV1PpiServiceDatasetTestsRunTestPost(runTestRequest);
    print(response);
} catch on DioException (e) {
    print('Exception when calling PpiApi->runTestApiV1PpiServiceDatasetTestsRunTestPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **runTestRequest** | [**RunTestRequest**](RunTestRequest.md)|  | 

### Return type

[**RunTestResponse**](RunTestResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **testsApiV1PpiServiceDatasetTestsTestsGet**
> JsonObject testsApiV1PpiServiceDatasetTestsTestsGet()

Tests

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getPpiApi();

try {
    final response = api.testsApiV1PpiServiceDatasetTestsTestsGet();
    print(response);
} catch on DioException (e) {
    print('Exception when calling PpiApi->testsApiV1PpiServiceDatasetTestsTestsGet: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**JsonObject**](JsonObject.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

