# biocentral_api.api.DefaultApi

## Load the API package
```dart
import 'package:biocentral_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**deepHealthCheckHealthDeepGet**](DefaultApi.md#deephealthcheckhealthdeepget) | **GET** /health/deep | Deep Health Check
[**healthCheckHealthGet**](DefaultApi.md#healthcheckhealthget) | **GET** /health | Health Check


# **deepHealthCheckHealthDeepGet**
> JsonObject deepHealthCheckHealthDeepGet()

Deep Health Check

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getDefaultApi();

try {
    final response = api.deepHealthCheckHealthDeepGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->deepHealthCheckHealthDeepGet: $e\n');
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

# **healthCheckHealthGet**
> JsonObject healthCheckHealthGet()

Health Check

### Example
```dart
import 'package:biocentral_api/api.dart';

final api = BiocentralApi().getDefaultApi();

try {
    final response = api.healthCheckHealthGet();
    print(response);
} on DioException catch (e) {
    print('Exception when calling DefaultApi->healthCheckHealthGet: $e\n');
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

